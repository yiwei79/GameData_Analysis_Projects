<?php
/**
 * Database Configuration for Delivery 3 Analytics System
 *
 * UPC Database Configuration
 * - Host: citmalumnes.upc.es
 * - Schema: yiweiy
 * - Table Prefix: delivery3_
 */

// Database connection parameters
define('DB_HOST', 'citmalumnes.upc.es');  // UPC Database host
define('DB_USER', 'yiweiy');                // UPC MySQL username
define('DB_PASS', '5DNmxr2aCxAr');          // UPC MySQL password
define('DB_NAME', 'yiweiy');                // Database schema name
define('DB_PORT', 3306);                    // MySQL port

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
