<?php
/**
 * Database Connection Test Script
 *
 * Use this to verify your MySQL connection is configured correctly
 * UPC Server: https://citmalumnes.upc.es/~yiweiy/delivery3_backend/test_connection.php
 *
 * Expected success response:
 * {
 *   "success": true,
 *   "message": "Database connected successfully",
 *   "server_info": "MySQL version info",
 *   "database": "test",
 *   "tables": ["delivery3_sessions", "delivery3_player_positions", ...]
 * }
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once 'config.php';

try {
    // Attempt connection
    $conn = getDBConnection();

    // Test query
    $result = $conn->query("SELECT COUNT(*) as session_count FROM delivery3_sessions");

    if ($result) {
        $row = $result->fetch_assoc();
        $sessionCount = $row['session_count'];

        echo json_encode([
            'success' => true,
            'message' => 'Database connected successfully',
            'server_info' => $conn->server_info,
            'database' => DB_NAME,
            'host' => DB_HOST,
            'port' => DB_PORT,
            'session_count' => $sessionCount,
            'tables' => getTableList($conn)
        ]);
    } else {
        throw new Exception('Test query failed: ' . $conn->error);
    }

    closeDBConnection($conn);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Database connection failed',
        'details' => $e->getMessage(),
        'config' => [
            'host' => DB_HOST,
            'port' => DB_PORT,
            'database' => DB_NAME,
            'user' => DB_USER
        ]
    ]);
}

/**
 * Get list of delivery3_ tables in the database
 *
 * @param mysqli $conn Database connection
 * @return array Table names
 */
function getTableList($conn) {
    $tables = [];
    $result = $conn->query("SHOW TABLES LIKE 'delivery3_%'");

    if ($result) {
        while ($row = $result->fetch_array()) {
            $tables[] = $row[0];
        }
    }

    return $tables;
}
?>
