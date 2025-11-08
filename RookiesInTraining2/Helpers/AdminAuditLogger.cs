using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;

namespace RookiesInTraining2.Helpers
{
    public static class AdminAuditLogger
    {
        private static string ConnStr => ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

        public static void LogAction(string adminSlug, string actionType, string targetType = null, 
            string targetSlug = null, string details = null)
        {
            try
            {
                string ipAddress = HttpContext.Current?.Request?.UserHostAddress;

                using (var con = new SqlConnection(ConnStr))
                using (var cmd = con.CreateCommand())
                {
                    con.Open();
                    cmd.CommandText = @"
                        INSERT INTO dbo.AdminLogs
                        (admin_slug, action_type, target_type, target_slug, details, ip_address, created_at)
                        VALUES
                        (@adminSlug, @actionType, @targetType, @targetSlug, @details, @ipAddress, SYSUTCDATETIME())";

                    cmd.Parameters.AddWithValue("@adminSlug", adminSlug);
                    cmd.Parameters.AddWithValue("@actionType", actionType);
                    cmd.Parameters.AddWithValue("@targetType", (object)targetType ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@targetSlug", (object)targetSlug ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@details", (object)details ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ipAddress", (object)ipAddress ?? DBNull.Value);

                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                // Log error but don't throw - audit logging should not break the main flow
                System.Diagnostics.Debug.WriteLine($"[AdminAuditLogger] Error logging action: {ex.Message}");
            }
        }
    }
}

