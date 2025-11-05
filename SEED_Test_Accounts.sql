USE [RookiesDatabase];
GO

-- Insert test accounts with SHA256 hashed passwords
-- Password: "password123" -> SHA256 hash
DECLARE @PasswordHash NVARCHAR(255) = 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f';

INSERT INTO Users (user_slug, full_name, display_name, email, password_hash, role, role_global)
VALUES 
('teacher-admin', 'Teacher Admin', 'Teacher Admin', 'teacher@example.com', @PasswordHash, 'teacher', 'teacher'),
('student-demo', 'Demo Student', 'Demo Student', 'student@example.com', @PasswordHash, 'student', 'student'),
('admin-super', 'Super Admin', 'Super Admin', 'admin@example.com', @PasswordHash, 'admin', 'admin');

PRINT '✅ Created 3 test accounts with hashed passwords';
PRINT '';
PRINT '========================================';
PRINT 'Login Credentials:';
PRINT '========================================';
PRINT '  👨‍🏫 Teacher: teacher@example.com / password123';
PRINT '  👨‍🎓 Student: student@example.com / password123';
PRINT '  👑 Admin:   admin@example.com / password123';
PRINT '';
PRINT '🔒 Passwords are securely hashed with SHA256';
PRINT '';
GO
