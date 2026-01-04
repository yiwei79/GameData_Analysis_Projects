<?php
/**
 * Analytics Data Receiver Endpoint
 *
 * Receives JSON analytics data from Unity via HTTP POST
 * Routes requests by event_type to appropriate handlers
 *
 * Supported event types:
 * - session_start: Initialize new gameplay session
 * - session_end: Finalize session with end time and duration
 * - positions_batch: Bulk insert player position samples
 * - death: Record player or enemy death event
 * - pickup: Record item collection event
 * - combat: Record damage dealt event
 */

// Set headers for JSON response and CORS
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed. Use POST.']);
    exit();
}

require_once 'config.php';

// Get JSON from request body
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Validate JSON
if (!$data) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => 'Invalid JSON payload']);
    exit();
}

// Get database connection
$conn = getDBConnection();
$event_type = $data['event_type'] ?? '';

// Route by event type
try {
    switch ($event_type) {
        case 'session_start':
            handleSessionStart($conn, $data);
            break;

        case 'session_end':
            handleSessionEnd($conn, $data);
            break;

        case 'positions_batch':
            handlePositionsBatch($conn, $data);
            break;

        case 'death':
            handleDeath($conn, $data);
            break;

        case 'pickup':
            handlePickup($conn, $data);
            break;

        case 'combat':
            handleCombat($conn, $data);
            break;

        default:
            http_response_code(400);
            echo json_encode(['success' => false, 'error' => 'Unknown event type: ' . $event_type]);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server error', 'details' => $e->getMessage()]);
    logError("Error handling event type '$event_type': " . $e->getMessage());
} finally {
    closeDBConnection($conn);
}

// ============================================================================
// Event Handlers
// ============================================================================

/**
 * Handle session start event
 *
 * @param mysqli $conn Database connection
 * @param array $data Event data
 */
function handleSessionStart($conn, $data) {
    // Validate required fields
    if (!isset($data['session_id']) || !isset($data['start_time'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Missing required fields: session_id, start_time']);
        return;
    }

    $stmt = $conn->prepare("INSERT INTO sessions (session_id, start_time) VALUES (?, ?)");

    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $stmt->bind_param("ss", $data['session_id'], $data['start_time']);

    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'session_id' => $data['session_id'],
            'message' => 'Session started'
        ]);
    } else {
        throw new Exception('Execute failed: ' . $stmt->error);
    }

    $stmt->close();
}

/**
 * Handle session end event
 *
 * @param mysqli $conn Database connection
 * @param array $data Event data
 */
function handleSessionEnd($conn, $data) {
    // Validate required fields
    if (!isset($data['session_id']) || !isset($data['end_time']) || !isset($data['duration_seconds'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Missing required fields: session_id, end_time, duration_seconds']);
        return;
    }

    $stmt = $conn->prepare(
        "UPDATE sessions SET end_time = ?, duration_seconds = ? WHERE session_id = ?"
    );

    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $stmt->bind_param("sis", $data['end_time'], $data['duration_seconds'], $data['session_id']);

    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'session_id' => $data['session_id'],
            'message' => 'Session ended',
            'affected_rows' => $stmt->affected_rows
        ]);
    } else {
        throw new Exception('Execute failed: ' . $stmt->error);
    }

    $stmt->close();
}

/**
 * Handle batch position samples
 *
 * @param mysqli $conn Database connection
 * @param array $data Event data
 */
function handlePositionsBatch($conn, $data) {
    // Validate required fields
    if (!isset($data['session_id']) || !isset($data['positions']) || !is_array($data['positions'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Missing or invalid fields: session_id, positions']);
        return;
    }

    $stmt = $conn->prepare(
        "INSERT INTO player_positions (session_id, position_x, position_y, position_z, speed, timestamp)
         VALUES (?, ?, ?, ?, ?, ?)"
    );

    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $count = 0;
    foreach ($data['positions'] as $pos) {
        // Validate position data
        if (!isset($pos['x']) || !isset($pos['y']) || !isset($pos['z']) || !isset($pos['timestamp'])) {
            continue; // Skip invalid positions
        }

        $speed = $pos['speed'] ?? 0.0;

        $stmt->bind_param(
            "sddddd",
            $data['session_id'],
            $pos['x'],
            $pos['y'],
            $pos['z'],
            $speed,
            $pos['timestamp']
        );

        if ($stmt->execute()) {
            $count++;
        }
    }

    echo json_encode([
        'success' => true,
        'session_id' => $data['session_id'],
        'inserted' => $count,
        'total' => count($data['positions'])
    ]);

    $stmt->close();
}

/**
 * Handle death event
 *
 * @param mysqli $conn Database connection
 * @param array $data Event data
 */
function handleDeath($conn, $data) {
    // Support both direct fields and nested 'data' object
    $deathData = $data['data'] ?? $data;

    // Validate required fields
    if (!isset($deathData['session_id']) || !isset($deathData['entity_type']) ||
        !isset($deathData['x']) || !isset($deathData['y']) || !isset($deathData['z']) ||
        !isset($deathData['timestamp'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Missing required fields for death event']);
        return;
    }

    $stmt = $conn->prepare(
        "INSERT INTO death_events (session_id, entity_type, position_x, position_y, position_z, cause, timestamp)
         VALUES (?, ?, ?, ?, ?, ?, ?)"
    );

    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $cause = $deathData['cause'] ?? 'Unknown';

    $stmt->bind_param(
        "ssdddsd",
        $deathData['session_id'],
        $deathData['entity_type'],
        $deathData['x'],
        $deathData['y'],
        $deathData['z'],
        $cause,
        $deathData['timestamp']
    );

    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'event_id' => $conn->insert_id,
            'message' => 'Death event recorded'
        ]);
    } else {
        throw new Exception('Execute failed: ' . $stmt->error);
    }

    $stmt->close();
}

/**
 * Handle pickup event
 *
 * @param mysqli $conn Database connection
 * @param array $data Event data
 */
function handlePickup($conn, $data) {
    // Support both direct fields and nested 'data' object
    $pickupData = $data['data'] ?? $data;

    // Validate required fields
    if (!isset($pickupData['session_id']) || !isset($pickupData['item_name']) ||
        !isset($pickupData['x']) || !isset($pickupData['y']) || !isset($pickupData['z']) ||
        !isset($pickupData['timestamp'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Missing required fields for pickup event']);
        return;
    }

    $stmt = $conn->prepare(
        "INSERT INTO pickup_events (session_id, item_name, position_x, position_y, position_z, timestamp)
         VALUES (?, ?, ?, ?, ?, ?)"
    );

    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $stmt->bind_param(
        "ssdddd",
        $pickupData['session_id'],
        $pickupData['item_name'],
        $pickupData['x'],
        $pickupData['y'],
        $pickupData['z'],
        $pickupData['timestamp']
    );

    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'event_id' => $conn->insert_id,
            'message' => 'Pickup event recorded'
        ]);
    } else {
        throw new Exception('Execute failed: ' . $stmt->error);
    }

    $stmt->close();
}

/**
 * Handle combat event
 *
 * @param mysqli $conn Database connection
 * @param array $data Event data
 */
function handleCombat($conn, $data) {
    // Support both direct fields and nested 'data' object
    $combatData = $data['data'] ?? $data;

    // Validate required fields
    if (!isset($combatData['session_id']) || !isset($combatData['attacker']) ||
        !isset($combatData['target']) || !isset($combatData['damage_amount']) ||
        !isset($combatData['x']) || !isset($combatData['y']) || !isset($combatData['z']) ||
        !isset($combatData['timestamp'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Missing required fields for combat event']);
        return;
    }

    $stmt = $conn->prepare(
        "INSERT INTO combat_events (session_id, attacker, target, damage_amount, position_x, position_y, position_z, timestamp)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    );

    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $stmt->bind_param(
        "sssdddd",
        $combatData['session_id'],
        $combatData['attacker'],
        $combatData['target'],
        $combatData['damage_amount'],
        $combatData['x'],
        $combatData['y'],
        $combatData['z'],
        $combatData['timestamp']
    );

    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'event_id' => $conn->insert_id,
            'message' => 'Combat event recorded'
        ]);
    } else {
        throw new Exception('Execute failed: ' . $stmt->error);
    }

    $stmt->close();
}
?>
