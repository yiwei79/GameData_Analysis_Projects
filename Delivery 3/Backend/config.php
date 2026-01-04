<?php
/**
 * Database Configuration for Delivery 3 Analytics System
 *
 * Update DB_USER and DB_PASS according to your local MySQL setup:
 * - XAMPP (Windows): Usually 'root' with no password
 * - MAMP (macOS): Usually 'root' with password 'root'
 * - Custom setup: Use your configured credentials
 */

// Database connection parameters
define('DB_HOST', '127.0.0.1');
define('DB_USER', 'root');
define('DB_PASS', '456210');                    // Your MySQL password
define('DB_NAME', 'delivery3_analytics');
define('DB_PORT', 3306);                        // Your existing MySQL port

/**
 * Create and return a database connection
 *
 * @return mysqli Database connection object
 * @throws Exception if connection fails
 */
function getDBConnection() {
    // Create connection
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT);

    // Check connection
    if ($conn->connect_error) {
        http_response_code(500);
        die(json_encode([
            'success' => false,
            'error' => 'Database connection failed',
            'details' => $conn->connect_error
        ]));
    }

    // Set character set to UTF-8
    if (!$conn->set_charset('utf8mb4')) {
        http_response_code(500);
        die(json_encode([
            'success' => false,
            'error' => 'Failed to set charset',
            'details' => $conn->error
        ]));
    }

    return $conn;
}

/**
 * Close database connection safely
 *
 * @param mysqli $conn Connection to close
 */
function closeDBConnection($conn) {
    if ($conn && $conn instanceof mysqli) {
        $conn->close();
    }
}

/**
 * Log error to file (for debugging)
 *
 * @param string $message Error message
 */
function logError($message) {
    $logFile = __DIR__ . '/error_log.txt';
    $timestamp = date('Y-m-d H:i:s');
    $logMessage = "[$timestamp] $message\n";
    file_put_contents($logFile, $logMessage, FILE_APPEND);
}
?>
