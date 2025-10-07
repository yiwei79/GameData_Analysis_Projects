<?php
/**
 * Analytics Data Receiver - Main API Endpoint
 * =====================================================
 * Receives events from Unity and stores them in MySQL
 * Handles 4 event types: new_player, new_session, end_session, purchase
 * =====================================================
 */

// Enable error reporting for debugging (comment out in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// CORS headers - allow Unity to connect from any origin
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Include database configuration
require_once 'config.php';

// Get database connection
$conn = getDatabaseConnection();

// Read JSON from Unity POST request
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Validate JSON
if ($data === null) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Invalid JSON format',
        'received' => $json
    ]);
    exit;
}

// Validate event_type field exists
if (!isset($data['event_type'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Missing event_type field'
    ]);
    exit;
}

// Route to appropriate handler based on event type
$response = [];

switch ($data['event_type']) {
    case 'new_player':
        $response = handleNewPlayer($conn, $data);
        break;

    case 'new_session':
        $response = handleNewSession($conn, $data);
        break;

    case 'end_session':
        $response = handleEndSession($conn, $data);
        break;

    case 'purchase':
        $response = handlePurchase($conn, $data);
        break;

    default:
        http_response_code(400);
        $response = [
            'success' => false,
            'error' => 'Unknown event_type: ' . $data['event_type'],
            'valid_types' => ['new_player', 'new_session', 'end_session', 'purchase']
        ];
}

// Close database connection
$conn->close();

// Return JSON response to Unity
echo json_encode($response);
exit;


// =====================================================
// EVENT HANDLERS
// =====================================================

/**
 * Handle new player creation
 * Inserts player into users table
 * Returns the new user_id for Unity to track
 */
function handleNewPlayer($conn, $data) {
    // Validate required fields
    $required = ['username', 'country', 'age', 'gender', 'registration_date'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return [
                'success' => false,
                'error' => "Missing required field: $field"
            ];
        }
    }

    // Prepare INSERT statement (prevents SQL injection)
    $stmt = $conn->prepare(
        "INSERT INTO users (username, country, age, gender, registration_date)
         VALUES (?, ?, ?, ?, ?)"
    );

    if (!$stmt) {
        return [
            'success' => false,
            'error' => 'Database prepare failed: ' . $conn->error
        ];
    }

    // Bind parameters
    // s = string, i = integer, d = double/float
    $stmt->bind_param(
        "ssids",
        $data['username'],
        $data['country'],
        $data['age'],
        $data['gender'],
        $data['registration_date']
    );

    // Execute query
    if ($stmt->execute()) {
        $newUserId = $stmt->insert_id;
        $stmt->close();
        return [
            'success' => true,
            'user_id' => $newUserId,
            'message' => 'Player created successfully'
        ];
    } else {
        $error = $stmt->error;
        $stmt->close();
        return [
            'success' => false,
            'error' => 'Insert failed: ' . $error
        ];
    }
}

/**
 * Handle new session start
 * Inserts session into sessions table
 * Returns the new session_id for Unity to track
 */
function handleNewSession($conn, $data) {
    // Validate required fields
    $required = ['user_id', 'start_time'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return [
                'success' => false,
                'error' => "Missing required field: $field"
            ];
        }
    }

    // Verify user exists
    $checkStmt = $conn->prepare("SELECT user_id FROM users WHERE user_id = ?");
    $checkStmt->bind_param("i", $data['user_id']);
    $checkStmt->execute();
    $checkStmt->store_result();

    if ($checkStmt->num_rows === 0) {
        $checkStmt->close();
        return [
            'success' => false,
            'error' => 'User ID does not exist: ' . $data['user_id']
        ];
    }
    $checkStmt->close();

    // Prepare INSERT statement
    $stmt = $conn->prepare(
        "INSERT INTO sessions (user_id, start_time)
         VALUES (?, ?)"
    );

    if (!$stmt) {
        return [
            'success' => false,
            'error' => 'Database prepare failed: ' . $conn->error
        ];
    }

    $stmt->bind_param(
        "is",
        $data['user_id'],
        $data['start_time']
    );

    if ($stmt->execute()) {
        $newSessionId = $stmt->insert_id;
        $stmt->close();
        return [
            'success' => true,
            'session_id' => $newSessionId,
            'message' => 'Session started successfully'
        ];
    } else {
        $error = $stmt->error;
        $stmt->close();
        return [
            'success' => false,
            'error' => 'Insert failed: ' . $error
        ];
    }
}

/**
 * Handle session end
 * Updates existing session with end_time and duration
 */
function handleEndSession($conn, $data) {
    // Validate required fields
    $required = ['session_id', 'end_time', 'duration_seconds'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return [
                'success' => false,
                'error' => "Missing required field: $field"
            ];
        }
    }

    // Verify session exists
    $checkStmt = $conn->prepare("SELECT session_id FROM sessions WHERE session_id = ?");
    $checkStmt->bind_param("i", $data['session_id']);
    $checkStmt->execute();
    $checkStmt->store_result();

    if ($checkStmt->num_rows === 0) {
        $checkStmt->close();
        return [
            'success' => false,
            'error' => 'Session ID does not exist: ' . $data['session_id']
        ];
    }
    $checkStmt->close();

    // Prepare UPDATE statement
    $stmt = $conn->prepare(
        "UPDATE sessions
         SET end_time = ?, duration_seconds = ?
         WHERE session_id = ?"
    );

    if (!$stmt) {
        return [
            'success' => false,
            'error' => 'Database prepare failed: ' . $conn->error
        ];
    }

    $stmt->bind_param(
        "sii",
        $data['end_time'],
        $data['duration_seconds'],
        $data['session_id']
    );

    if ($stmt->execute()) {
        $stmt->close();
        return [
            'success' => true,
            'message' => 'Session ended successfully'
        ];
    } else {
        $error = $stmt->error;
        $stmt->close();
        return [
            'success' => false,
            'error' => 'Update failed: ' . $error
        ];
    }
}

/**
 * Handle purchase event
 * Inserts purchase into purchases table
 * Returns the new purchase_id
 */
function handlePurchase($conn, $data) {
    // Validate required fields
    $required = ['session_id', 'user_id', 'item_id', 'amount', 'purchase_date'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return [
                'success' => false,
                'error' => "Missing required field: $field"
            ];
        }
    }

    // Verify session exists
    $checkStmt = $conn->prepare("SELECT session_id FROM sessions WHERE session_id = ?");
    $checkStmt->bind_param("i", $data['session_id']);
    $checkStmt->execute();
    $checkStmt->store_result();

    if ($checkStmt->num_rows === 0) {
        $checkStmt->close();
        return [
            'success' => false,
            'error' => 'Session ID does not exist: ' . $data['session_id']
        ];
    }
    $checkStmt->close();

    // Verify item exists
    $checkStmt = $conn->prepare("SELECT item_id FROM items WHERE item_id = ?");
    $checkStmt->bind_param("i", $data['item_id']);
    $checkStmt->execute();
    $checkStmt->store_result();

    if ($checkStmt->num_rows === 0) {
        $checkStmt->close();
        return [
            'success' => false,
            'error' => 'Item ID does not exist: ' . $data['item_id']
        ];
    }
    $checkStmt->close();

    // Prepare INSERT statement
    $stmt = $conn->prepare(
        "INSERT INTO purchases (session_id, user_id, item_id, amount, purchase_date)
         VALUES (?, ?, ?, ?, ?)"
    );

    if (!$stmt) {
        return [
            'success' => false,
            'error' => 'Database prepare failed: ' . $conn->error
        ];
    }

    $stmt->bind_param(
        "iiids",
        $data['session_id'],
        $data['user_id'],
        $data['item_id'],
        $data['amount'],
        $data['purchase_date']
    );

    if ($stmt->execute()) {
        $newPurchaseId = $stmt->insert_id;
        $stmt->close();
        return [
            'success' => true,
            'purchase_id' => $newPurchaseId,
            'message' => 'Purchase recorded successfully'
        ];
    } else {
        $error = $stmt->error;
        $stmt->close();
        return [
            'success' => false,
            'error' => 'Insert failed: ' . $error
        ];
    }
}
?>
