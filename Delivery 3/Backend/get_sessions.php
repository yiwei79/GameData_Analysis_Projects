<?php
/**
 * Get Sessions List Endpoint
 *
 * Returns a list of all recorded gameplay sessions
 * Used by Unity Editor to populate session dropdown
 *
 * Method: GET
 * Response: JSON array of session objects
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'config.php';

try {
    $conn = getDBConnection();

    // Query to get all sessions ordered by most recent first
    $query = "SELECT session_id, start_time, end_time, duration_seconds
              FROM delivery3_sessions
              ORDER BY start_time DESC";

    $result = $conn->query($query);

    if (!$result) {
        throw new Exception('Query failed: ' . $conn->error);
    }

    $sessions = [];
    while ($row = $result->fetch_assoc()) {
        $sessions[] = [
            'session_id' => $row['session_id'],
            'start_time' => $row['start_time'],
            'end_time' => $row['end_time'],
            'duration_seconds' => (int)$row['duration_seconds']
        ];
    }

    echo json_encode([
        'success' => true,
        'count' => count($sessions),
        'sessions' => $sessions
    ]);

    closeDBConnection($conn);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to fetch sessions',
        'details' => $e->getMessage()
    ]);
    logError("Error fetching sessions: " . $e->getMessage());
}
?>
