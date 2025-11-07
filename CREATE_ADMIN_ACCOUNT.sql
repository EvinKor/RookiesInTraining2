-- =============================================
-- CREATE ADMIN ACCOUNT
-- Email: admin@gmail.com
-- Password: 12345
-- =============================================

USE [RookiesDatabase];
GO

-- Check if admin account already exists
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE email = 'admin@gmail.com' AND is_deleted = 0)
BEGIN
    -- Insert admin account
    -- Password hash for "12345" using SHA256: 5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5
    INSERT INTO dbo.Users
    (
        user_slug,
        full_name,
        display_name,
        email,
        password_hash,
        role,
        role_global,
        avatar_url,
        created_at,
        updated_at,
        is_deleted
    )
    VALUES
    (
        'admin',
        'System Administrator',
        'System Administrator',
        'admin@gmail.com',
        '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', -- SHA256 hash of "12345"
        'admin',
        'admin',
        NULL,
        SYSUTCDATETIME(),
        SYSUTCDATETIME(),
        0
    );

    PRINT '✅ Admin account created successfully!';
    PRINT '   Email: admin@gmail.com';
    PRINT '   Password: 12345';
END
ELSE
BEGIN
    -- Update existing admin account to ensure correct password and role
    UPDATE dbo.Users
    SET 
        password_hash = '5994471abb01112afcc18159f6cc74b4f511b99806da59b3caf5a9c173cacfc5', -- SHA256 hash of "12345"
        role = 'admin',
        role_global = 'admin',
        is_deleted = 0,
        updated_at = SYSUTCDATETIME()
    WHERE email = 'admin@gmail.com';

    PRINT '✅ Admin account updated successfully!';
    PRINT '   Email: admin@gmail.com';
    PRINT '   Password: 12345';
END
GO

PRINT '';
PRINT 'You can now login with:';
PRINT '   Email: admin@gmail.com';
PRINT '   Password: 12345';
GO


