<?php
/**
 * Database Configuration
 * =====================================================
 * IMPORTANT: Update these values with your actual database credentials
 * SECURITY: Never commit this file with real passwords to version control
 * =====================================================
 */

// Database connection parameters
// For UPC server, host is typically 'localhost' since PHP and MySQL are on same server
define('DB_HOST', 'localhost');

define('DB_NAME', 'UPC_Database');

// TODO: Replace with your actual database username
define('DB_USER', 'yiweiy');

// TODO: Replace with your actual database password
define('DB_PASS', '5DNmxr2aCxAr');

/**
 * Get a database connection using mysqli
 * Returns a mysqli connection object
 * Dies with JSON error if connection fails
 */
function getDatabaseConnection() {
    // Create connection
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

    // Check connection
    if ($conn->connect_error) {
        http_response_code(500);
        die(json_encode([
            'success' => false,
            'error' => 'Database connection failed',
            'details' => 'Check your credentials in config.php'
        ]));
    }

    // Set character set to utf8mb4 for full Unicode support
    $conn->set_charset("utf8mb4");

    return $conn;
}

echo "Database connection successful";

/**
 * Example test script to verify database connection
 * Uncomment the code below and access this file directly to test
 */
/*
header('Content-Type: application/json');
$conn = getDatabaseConnection();
echo json_encode([
    'success' => true,
    'message' => 'Database connection successful',
    'database' => DB_NAME,
    'host' => DB_HOST
]);
$conn->close();
*/
?>
