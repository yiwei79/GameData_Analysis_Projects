<?php
/**
 * Get Session Data Endpoint
 *
 * Returns complete analytics data for a specific session
 * Includes: session info, positions, deaths, pickups, combat events
 *
 * Method: GET
 * Parameter: session_id (required)
 * Example: get_session_data.php?session_id=abc-123-def-456
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

// Get session_id from query parameter
$session_id = $_GET['session_id'] ?? '';

if (empty($session_id)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Missing required parameter: session_id'
    ]);
    exit();
}

try {
    $conn = getDBConnection();

    // Get session info
    $sessionInfo = getSessionInfo($conn, $session_id);

    if (!$sessionInfo) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'error' => 'Session not found: ' . $session_id
        ]);
        closeDBConnection($conn);
        exit();
    }

    // Get all related data
    $positions = getPositions($conn, $session_id);
    $deaths = getDeaths($conn, $session_id);
    $pickups = getPickups($conn, $session_id);
    $combat = getCombat($conn, $session_id);

    // Build response
    $response = [
        'success' => true,
        'session_id' => $session_id,
        'info' => $sessionInfo,
        'positions' => $positions,
        'deaths' => $deaths,
        'pickups' => $pickups,
        'combat' => $combat,
        'stats' => [
            'total_positions' => count($positions),
            'total_deaths' => count($deaths),
            'total_pickups' => count($pickups),
            'total_combat' => count($combat)
        ]
    ];

    echo json_encode($response);

    closeDBConnection($conn);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to fetch session data',
        'details' => $e->getMessage()
    ]);
    logError("Error fetching session data for '$session_id': " . $e->getMessage());
}

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Get session information
 *
 * @param mysqli $conn Database connection
 * @param string $session_id Session UUID
 * @return array|null Session info or null if not found
 */
function getSessionInfo($conn, $session_id) {
    $stmt = $conn->prepare(
        "SELECT session_id, start_time, end_time, duration_seconds
         FROM sessions
         WHERE session_id = ?"
    );

    $stmt->bind_param("s", $session_id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        $stmt->close();
        return [
            'session_id' => $row['session_id'],
            'start_time' => $row['start_time'],
            'end_time' => $row['end_time'],
            'duration_seconds' => (int)$row['duration_seconds']
        ];
    }

    $stmt->close();
    return null;
}

/**
 * Get player position samples
 *
 * @param mysqli $conn Database connection
 * @param string $session_id Session UUID
 * @return array Array of position objects
 */
function getPositions($conn, $session_id) {
    $stmt = $conn->prepare(
        "SELECT position_x, position_y, position_z, speed, timestamp
         FROM player_positions
         WHERE session_id = ?
         ORDER BY timestamp ASC"
    );

    $stmt->bind_param("s", $session_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $positions = [];
    while ($row = $result->fetch_assoc()) {
        $positions[] = [
            'x' => (float)$row['position_x'],
            'y' => (float)$row['position_y'],
            'z' => (float)$row['position_z'],
            'speed' => (float)$row['speed'],
            'timestamp' => (float)$row['timestamp']
        ];
    }

    $stmt->close();
    return $positions;
}

/**
 * Get death events
 *
 * @param mysqli $conn Database connection
 * @param string $session_id Session UUID
 * @return array Array of death event objects
 */
function getDeaths($conn, $session_id) {
    $stmt = $conn->prepare(
        "SELECT entity_type, position_x, position_y, position_z, cause, timestamp
         FROM death_events
         WHERE session_id = ?
         ORDER BY timestamp ASC"
    );

    $stmt->bind_param("s", $session_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $deaths = [];
    while ($row = $result->fetch_assoc()) {
        $deaths[] = [
            'entity_type' => $row['entity_type'],
            'x' => (float)$row['position_x'],
            'y' => (float)$row['position_y'],
            'z' => (float)$row['position_z'],
            'cause' => $row['cause'],
            'timestamp' => (float)$row['timestamp']
        ];
    }

    $stmt->close();
    return $deaths;
}

/**
 * Get pickup events
 *
 * @param mysqli $conn Database connection
 * @param string $session_id Session UUID
 * @return array Array of pickup event objects
 */
function getPickups($conn, $session_id) {
    $stmt = $conn->prepare(
        "SELECT item_name, position_x, position_y, position_z, timestamp
         FROM pickup_events
         WHERE session_id = ?
         ORDER BY timestamp ASC"
    );

    $stmt->bind_param("s", $session_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $pickups = [];
    while ($row = $result->fetch_assoc()) {
        $pickups[] = [
            'item_name' => $row['item_name'],
            'x' => (float)$row['position_x'],
            'y' => (float)$row['position_y'],
            'z' => (float)$row['position_z'],
            'timestamp' => (float)$row['timestamp']
        ];
    }

    $stmt->close();
    return $pickups;
}

/**
 * Get combat events
 *
 * @param mysqli $conn Database connection
 * @param string $session_id Session UUID
 * @return array Array of combat event objects
 */
function getCombat($conn, $session_id) {
    $stmt = $conn->prepare(
        "SELECT attacker, target, damage_amount, position_x, position_y, position_z, timestamp
         FROM combat_events
         WHERE session_id = ?
         ORDER BY timestamp ASC"
    );

    $stmt->bind_param("s", $session_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $combat = [];
    while ($row = $result->fetch_assoc()) {
        $combat[] = [
            'attacker' => $row['attacker'],
            'target' => $row['target'],
            'damage_amount' => (float)$row['damage_amount'],
            'x' => (float)$row['position_x'],
            'y' => (float)$row['position_y'],
            'z' => (float)$row['position_z'],
            'timestamp' => (float)$row['timestamp']
        ];
    }

    $stmt->close();
    return $combat;
}
?>
