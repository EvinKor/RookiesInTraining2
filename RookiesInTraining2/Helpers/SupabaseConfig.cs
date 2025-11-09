using System;
using System.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace RookiesInTraining2.Helpers
{
    /// <summary>
    /// Supabase configuration and helper class for multiplayer game features
    /// </summary>
    public static class SupabaseConfig
    {
        // These will be set from Web.config
        public static string SupabaseUrl => ConfigurationManager.AppSettings["SupabaseUrl"];
        public static string SupabaseKey => ConfigurationManager.AppSettings["SupabaseKey"];
        public static string SupabaseServiceKey => ConfigurationManager.AppSettings["SupabaseServiceKey"];

        private static HttpClient _httpClient;

        static SupabaseConfig()
        {
            _httpClient = new HttpClient();
            _httpClient.DefaultRequestHeaders.Add("apikey", SupabaseKey);
            _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", SupabaseKey);
        }

        /// <summary>
        /// Make a GET request to Supabase
        /// </summary>
        public static async Task<string> GetAsync(string table, string query = "")
        {
            try
            {
                string url = $"{SupabaseUrl}/rest/v1/{table}{query}";
                var response = await _httpClient.GetAsync(url);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsStringAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Supabase GET Error] {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Make a POST request to Supabase
        /// </summary>
        public static async Task<string> PostAsync(string table, object data)
        {
            try
            {
                string url = $"{SupabaseUrl}/rest/v1/{table}";
                string json = JsonConvert.SerializeObject(data);
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                
                var response = await _httpClient.PostAsync(url, content);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsStringAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Supabase POST Error] {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Make a PATCH request to Supabase
        /// </summary>
        public static async Task<string> PatchAsync(string table, string filter, object data)
        {
            try
            {
                string url = $"{SupabaseUrl}/rest/v1/{table}?{filter}";
                string json = JsonConvert.SerializeObject(data);
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                
                var request = new HttpRequestMessage(new HttpMethod("PATCH"), url)
                {
                    Content = content
                };
                
                var response = await _httpClient.SendAsync(request);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsStringAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Supabase PATCH Error] {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Make a DELETE request to Supabase
        /// </summary>
        public static async Task<string> DeleteAsync(string table, string filter)
        {
            try
            {
                string url = $"{SupabaseUrl}/rest/v1/{table}?{filter}";
                var response = await _httpClient.DeleteAsync(url);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsStringAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Supabase DELETE Error] {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Call a Supabase function
        /// </summary>
        public static async Task<string> CallFunctionAsync(string functionName, object parameters = null)
        {
            try
            {
                string url = $"{SupabaseUrl}/rest/v1/rpc/{functionName}";
                string json = parameters != null ? JsonConvert.SerializeObject(parameters) : "{}";
                var content = new StringContent(json, Encoding.UTF8, "application/json");
                
                var response = await _httpClient.PostAsync(url, content);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsStringAsync();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Supabase Function Error] {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Check if Supabase is configured
        /// </summary>
        public static bool IsConfigured()
        {
            return !string.IsNullOrEmpty(SupabaseUrl) && !string.IsNullOrEmpty(SupabaseKey);
        }
    }
}

