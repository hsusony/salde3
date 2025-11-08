<?php
/**
 * Application Constants
 */

// Application Info
define('APP_NAME', 'Sales Management System');
define('APP_VERSION', '1.0.0');
define('APP_ENV', 'production'); // development, production

// API Settings
define('API_PREFIX', '/api');
define('API_VERSION', 'v1');

// Pagination
define('DEFAULT_PAGE_SIZE', 20);
define('MAX_PAGE_SIZE', 100);

// Cache
define('CACHE_ENABLED', true);
define('CACHE_TTL', 300); // 5 minutes

// Security
define('JWT_SECRET', 'your-secret-key-change-this-in-production'); // CHANGE THIS!
define('JWT_ALGORITHM', 'HS256');
define('JWT_EXPIRATION', 86400); // 24 hours
define('PASSWORD_HASH_ALGO', PASSWORD_BCRYPT);
define('PASSWORD_COST', 10);

// Rate Limiting
define('RATE_LIMIT_ENABLED', true);
define('RATE_LIMIT_REQUESTS', 100); // requests per minute
define('RATE_LIMIT_PERIOD', 60); // seconds

// File Upload
define('MAX_UPLOAD_SIZE', 5242880); // 5MB
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png', 'pdf']);

// Backup
define('BACKUP_PATH', __DIR__ . '/../backups/');
define('MAX_BACKUPS', 10);

// Logging
define('LOG_PATH', __DIR__ . '/../logs/');
define('LOG_LEVEL', 'info'); // debug, info, warning, error

// Database
define('DB_TIMEOUT', 30);
define('DB_CHARSET', 'UTF-8');
