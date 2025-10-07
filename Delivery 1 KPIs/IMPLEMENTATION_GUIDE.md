# Delivery 1 KPIs - Complete Implementation Guide

**Project**: Game Analytics Pipeline
**Duration**: 2 Weeks
**Goal**: Build Unity → PHP → MySQL → R analytics pipeline

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Week 1: Backend Setup](#week-1-backend-setup)
3. [Week 2: Unity Implementation](#week-2-unity-implementation)
4. [Testing & Debugging](#testing--debugging)
5. [Part 2 Preview: KPI Analysis](#part-2-preview-kpi-analysis)
6. [Final Deliverables](#final-deliverables)

---

## Project Overview

### Architecture

```
Unity Simulator → AnalyticsManager → PHP Backend → MySQL Database
                                                          ↓
                                                    SQL Queries
                                                          ↓
                                                    R Analysis
```

### Key Constraint

**⚠️ CRITICAL**: Never modify `Simulator.cs` - it's a provided simulation engine. Subscribe to its 4 events instead:
- `OnNewPlayer(string name, string country, int age, float gender, DateTime date)`
- `OnNewSession(DateTime startTime, uint id)`
- `OnEndSession(DateTime endTime, uint id)`
- `OnBuyItem(int itemId, DateTime purchaseDate, uint id)`

### Timeline

- **Week 1**: Database + PHP Backend + Testing
- **Week 2**: Unity Scripts + Integration + Documentation

---

## Week 1: Backend Setup

### Day 1-2: Database Setup with SQL Workbench

#### Step 1.1: Connect to Database ✓
You already have SQL Workbench connected to your UPC database.

#### Step 1.2: Create Tables

Open SQL Workbench and execute these commands **one by one**:

```sql
-- Table 1: Users (stores player demographics)
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender FLOAT NOT NULL,
    registration_date DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_registration_date (registration_date),
    INDEX idx_country (country)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Verify**: Run `SHOW TABLES;` - you should see `users` listed.

```sql
-- Table 2: Sessions (tracks gameplay sessions)
CREATE TABLE sessions (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME DEFAULT NULL,
    duration_seconds INT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_start_time (start_time),
    INDEX idx_user_start (user_id, start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

```sql
-- Table 3: Items (purchasable items catalog)
CREATE TABLE items (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

```sql
-- Table 4: Purchases (tracks in-game purchases)
CREATE TABLE purchases (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    session_id INT NOT NULL,
    user_id INT NOT NULL,
    item_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    purchase_date DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_purchase_date (purchase_date),
    INDEX idx_session_id (session_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

```sql
-- Insert the 5 items (matching Simulator's GetItem() probabilities)
INSERT INTO items (item_id, item_name, price, category) VALUES
(1, 'Bronze Pack', 0.99, 'starter'),
(2, 'Silver Pack', 4.99, 'standard'),
(3, 'Gold Pack', 9.99, 'premium'),
(4, 'Platinum Pack', 19.99, 'premium'),
(5, 'Diamond Pack', 49.99, 'exclusive');
```

#### Step 1.3: Verify Setup

```sql
-- Should show 0 rows (empty table)
SELECT * FROM users;

-- Should show 5 items
SELECT * FROM items;

-- Test INSERT manually
INSERT INTO users (username, country, age, gender, registration_date)
VALUES ('TestPlayer', 'Spain', 25, 0.5, '2022-01-01 12:00:00');

-- Should show 1 row now with user_id = 1
SELECT * FROM users;

-- Clean up test data
DELETE FROM users WHERE username = 'TestPlayer';
```

**✅ Checkpoint**: You have 4 tables, items table has 5 rows, you can INSERT and SELECT data.

---

### Day 3-4: PHP Upload Access

#### Step 2.1: Verify File Upload Method

**Option A: Web File Manager**
1. Go to `https://citmalumnes.upc.es/`
2. Log in with your UPC credentials
3. Look for "File Manager" or "cPanel"
4. Navigate to `public_html` or `www` folder

**Option B: FTP with FileZilla**
1. Download FileZilla: https://filezilla-project.org/
2. Open FileZilla and connect:
   - **Host**: `ftp.citmalumnes.upc.es` (or `citmalumnes.upc.es`)
   - **Username**: Your UPC username
   - **Password**: Your UPC password
   - **Port**: 21
3. Once connected, find the `public_html` folder

**Option C: Ask Instructor**
Email: "What's the procedure to upload PHP files to citmalumnes.upc.es?"

#### Step 2.2: Create Test PHP File

On your Mac, create a file called `test.php`:

```php
<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

echo json_encode([
    'status' => 'success',
    'message' => 'PHP is working!',
    'timestamp' => date('Y-m-d H:i:s')
]);
?>
```

#### Step 2.3: Upload and Test

1. Upload `test.php` to your `public_html` folder
2. Open browser: `https://citmalumnes.upc.es/~yourUsername/test.php`
3. Expected output:
   ```json
   {"status":"success","message":"PHP is working!","timestamp":"2025-10-07 15:30:00"}
   ```

**✅ Checkpoint**: You can upload PHP files and access them via browser.

---

### Day 5-7: Create PHP Backend

#### Step 3.1: Get Database Credentials

You need:
- **Host**: Usually `localhost`
- **Database Name**: Check SQL Workbench connection settings
- **Username**: Your database username
- **Password**: Your database password

#### Step 3.2: Create `config.php`

Create this file locally on your Mac:

```php
<?php
// Database Configuration
// IMPORTANT: Keep this file secure, never commit passwords to git!

define('DB_HOST', 'localhost');
define('DB_NAME', 'your_database_name'); // ⚠️ CHANGE THIS
define('DB_USER', 'your_username');      // ⚠️ CHANGE THIS
define('DB_PASS', 'your_password');      // ⚠️ CHANGE THIS

// Function to get database connection
function getDatabaseConnection() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

    if ($conn->connect_error) {
        http_response_code(500);
        die(json_encode([
            'success' => false,
            'error' => 'Database connection failed'
        ]));
    }

    $conn->set_charset("utf8mb4");
    return $conn;
}
?>
```

**⚠️ Replace**: Change `your_database_name`, `your_username`, `your_password` with your actual credentials.

#### Step 3.3: Create `receive_analytics.php`

This is the main backend script:

```php
<?php
// Analytics Data Receiver
// Receives events from Unity and stores them in MySQL database

// Enable error reporting for debugging (remove in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// CORS headers (allow Unity to connect)
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Include database configuration
require_once 'config.php';

// Get database connection
$conn = getDatabaseConnection();

// Read JSON from Unity
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Check if JSON is valid
if ($data === null) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Invalid JSON'
    ]);
    exit;
}

// Check event_type exists
if (!isset($data['event_type'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Missing event_type'
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
            'error' => 'Unknown event_type: ' . $data['event_type']
        ];
}

// Close connection
$conn->close();

// Return response to Unity
echo json_encode($response);


// ===========================
// EVENT HANDLERS
// ===========================

function handleNewPlayer($conn, $data) {
    // Validate required fields
    $required = ['username', 'country', 'age', 'gender', 'registration_date'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return ['success' => false, 'error' => "Missing field: $field"];
        }
    }

    // Prepare INSERT statement
    $stmt = $conn->prepare(
        "INSERT INTO users (username, country, age, gender, registration_date)
         VALUES (?, ?, ?, ?, ?)"
    );

    if (!$stmt) {
        return ['success' => false, 'error' => 'Prepare failed: ' . $conn->error];
    }

    // Bind parameters (s=string, i=integer, d=double/float)
    $stmt->bind_param(
        "ssids",
        $data['username'],
        $data['country'],
        $data['age'],
        $data['gender'],
        $data['registration_date']
    );

    // Execute
    if ($stmt->execute()) {
        $newUserId = $stmt->insert_id;
        $stmt->close();
        return [
            'success' => true,
            'user_id' => $newUserId,
            'message' => 'Player created'
        ];
    } else {
        $error = $stmt->error;
        $stmt->close();
        return ['success' => false, 'error' => 'Insert failed: ' . $error];
    }
}

function handleNewSession($conn, $data) {
    // Validate required fields
    $required = ['user_id', 'start_time'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return ['success' => false, 'error' => "Missing field: $field"];
        }
    }

    // Prepare INSERT statement
    $stmt = $conn->prepare(
        "INSERT INTO sessions (user_id, start_time)
         VALUES (?, ?)"
    );

    if (!$stmt) {
        return ['success' => false, 'error' => 'Prepare failed: ' . $conn->error];
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
            'message' => 'Session started'
        ];
    } else {
        $error = $stmt->error;
        $stmt->close();
        return ['success' => false, 'error' => 'Insert failed: ' . $error];
    }
}

function handleEndSession($conn, $data) {
    // Validate required fields
    $required = ['session_id', 'end_time', 'duration_seconds'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return ['success' => false, 'error' => "Missing field: $field"];
        }
    }

    // Prepare UPDATE statement
    $stmt = $conn->prepare(
        "UPDATE sessions
         SET end_time = ?, duration_seconds = ?
         WHERE session_id = ?"
    );

    if (!$stmt) {
        return ['success' => false, 'error' => 'Prepare failed: ' . $conn->error];
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
            'message' => 'Session ended'
        ];
    } else {
        $error = $stmt->error;
        $stmt->close();
        return ['success' => false, 'error' => 'Update failed: ' . $error];
    }
}

function handlePurchase($conn, $data) {
    // Validate required fields
    $required = ['session_id', 'user_id', 'item_id', 'amount', 'purchase_date'];
    foreach ($required as $field) {
        if (!isset($data[$field])) {
            return ['success' => false, 'error' => "Missing field: $field"];
        }
    }

    // Prepare INSERT statement
    $stmt = $conn->prepare(
        "INSERT INTO purchases (session_id, user_id, item_id, amount, purchase_date)
         VALUES (?, ?, ?, ?, ?)"
    );

    if (!$stmt) {
        return ['success' => false, 'error' => 'Prepare failed: ' . $conn->error];
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
            'message' => 'Purchase recorded'
        ];
    } else {
        $error = $stmt->error;
        $stmt->close();
        return ['success' => false, 'error' => 'Insert failed: ' . $error];
    }
}
?>
```

#### Step 3.4: Upload PHP Files

1. Upload both `config.php` and `receive_analytics.php` to `public_html`
2. Ensure they're in the same directory

#### Step 3.5: Test PHP Backend with curl

Open Terminal on your Mac and test each event type:

**Test 1: New Player**
```bash
curl -X POST https://citmalumnes.upc.es/~yourUsername/receive_analytics.php \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "new_player",
    "username": "CurlTestPlayer",
    "country": "Spain",
    "age": 30,
    "gender": 0.5,
    "registration_date": "2022-01-15 10:00:00"
  }'
```

**Expected**: `{"success":true,"user_id":1,"message":"Player created"}`

**Verify in SQL Workbench**: `SELECT * FROM users;` should show the new player.

**Test 2: New Session** (use user_id from previous test)
```bash
curl -X POST https://citmalumnes.upc.es/~yourUsername/receive_analytics.php \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "new_session",
    "user_id": 1,
    "start_time": "2022-01-15 10:05:00"
  }'
```

**Expected**: `{"success":true,"session_id":1,"message":"Session started"}`

**Test 3: End Session**
```bash
curl -X POST https://citmalumnes.upc.es/~yourUsername/receive_analytics.php \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "end_session",
    "session_id": 1,
    "end_time": "2022-01-15 10:20:00",
    "duration_seconds": 900
  }'
```

**Test 4: Purchase**
```bash
curl -X POST https://citmalumnes.upc.es/~yourUsername/receive_analytics.php \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "purchase",
    "session_id": 1,
    "user_id": 1,
    "item_id": 2,
    "amount": 4.99,
    "purchase_date": "2022-01-15 10:15:00"
  }'
```

**✅ Checkpoint**: All 4 curl tests return success, data appears in SQL Workbench.

---

## Week 2: Unity Implementation

### Day 8-10: Unity Scripts

#### Step 4.1: Create `Item.cs`

In Unity, navigate to `Assets/_Scripts/` and create `Item.cs`:

```csharp
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Represents an in-game purchasable item
/// Matches the items table in database
/// </summary>
[System.Serializable]
public class Item
{
    public int itemId;
    public string itemName;
    public float price;
    public string category;

    public Item(int id, string name, float price, string category = "standard")
    {
        this.itemId = id;
        this.itemName = name;
        this.price = price;
        this.category = category;
    }

    // Static catalog matching database
    public static readonly Dictionary<int, Item> Catalog = new Dictionary<int, Item>
    {
        { 1, new Item(1, "Bronze Pack", 0.99f, "starter") },
        { 2, new Item(2, "Silver Pack", 4.99f, "standard") },
        { 3, new Item(3, "Gold Pack", 9.99f, "premium") },
        { 4, new Item(4, "Platinum Pack", 19.99f, "premium") },
        { 5, new Item(5, "Diamond Pack", 49.99f, "exclusive") }
    };

    public static Item GetItem(int itemId)
    {
        return Catalog.ContainsKey(itemId) ? Catalog[itemId] : null;
    }
}
```

#### Step 4.2: Create `AnalyticsManager.cs`

Create `Assets/_Scripts/AnalyticsManager.cs`:

```csharp
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

/// <summary>
/// Analytics Manager - Collects gameplay events and sends to backend
/// Implements non-intrusive, asynchronous data transmission
/// CRITICAL: This script subscribes to Simulator events without modifying Simulator.cs
/// </summary>
public class AnalyticsManager : MonoBehaviour
{
    [Header("Server Configuration")]
    [Tooltip("Your UPC PHP endpoint URL")]
    [SerializeField] private string serverUrl = "https://citmalumnes.upc.es/~yourUsername/receive_analytics.php";

    [Header("Debug Settings")]
    [SerializeField] private bool enableLogging = true;
    [SerializeField] private bool enableDetailedLogging = false;

    // ID mappings: Simulator IDs → Database IDs
    private Dictionary<string, int> playerNameToDbId = new Dictionary<string, int>();
    private Dictionary<int, int> dbUserIdToCurrentDbSessionId = new Dictionary<int, int>();
    private Dictionary<DateTime, DateTime> sessionStartTimes = new Dictionary<DateTime, DateTime>();

    #region Unity Lifecycle

    private void OnEnable()
    {
        // Subscribe to Simulator events
        Simulator.OnNewPlayer += HandleNewPlayer;
        Simulator.OnNewSession += HandleNewSession;
        Simulator.OnEndSession += HandleEndSession;
        Simulator.OnBuyItem += HandleBuyItem;

        Log("AnalyticsManager enabled and listening to events");
    }

    private void OnDisable()
    {
        // Unsubscribe from events
        Simulator.OnNewPlayer -= HandleNewPlayer;
        Simulator.OnNewSession -= HandleNewSession;
        Simulator.OnEndSession -= HandleEndSession;
        Simulator.OnBuyItem -= HandleBuyItem;

        Log("AnalyticsManager disabled");
    }

    #endregion

    #region Event Handlers

    /// <summary>
    /// Handles OnNewPlayer event from Simulator
    /// Creates a new user in the database and stores the mapping
    /// </summary>
    private void HandleNewPlayer(string name, string country, int age, float gender, DateTime registrationDate)
    {
        Log($"[EVENT] New Player: {name} from {country}, age {age}");
        StartCoroutine(SendNewPlayer(name, country, age, gender, registrationDate));
    }

    /// <summary>
    /// Handles OnNewSession event from Simulator
    /// Creates a new session in the database
    /// Note: The uint parameter is used as an internal identifier by Simulator
    /// </summary>
    private void HandleNewSession(DateTime startTime, uint simulatorPlayerId)
    {
        Log($"[EVENT] New Session for simulator player ID: {simulatorPlayerId}");
        StartCoroutine(SendNewSession(simulatorPlayerId, startTime));
    }

    /// <summary>
    /// Handles OnEndSession event from Simulator
    /// Updates the session with end time and duration
    /// </summary>
    private void HandleEndSession(DateTime endTime, uint simulatorIdentifier)
    {
        Log($"[EVENT] End Session for identifier: {simulatorIdentifier}");
        StartCoroutine(SendEndSession(simulatorIdentifier, endTime));
    }

    /// <summary>
    /// Handles OnBuyItem event from Simulator
    /// Records a purchase in the database
    /// </summary>
    private void HandleBuyItem(int itemId, DateTime purchaseDate, uint simulatorSessionIdentifier)
    {
        Log($"[EVENT] Purchase: Item {itemId}");

        Item item = Item.GetItem(itemId);
        if (item == null)
        {
            LogError($"Unknown item ID: {itemId}");
            return;
        }

        StartCoroutine(SendPurchase(itemId, item.price, purchaseDate, simulatorSessionIdentifier));
    }

    #endregion

    #region HTTP Senders

    /// <summary>
    /// Sends new player data to PHP backend
    /// Waits for response to get database-generated user_id
    /// </summary>
    private IEnumerator SendNewPlayer(string username, string country, int age, float gender, DateTime registrationDate)
    {
        // Create JSON data
        var data = new PlayerEventData
        {
            event_type = "new_player",
            username = username,
            country = country,
            age = age,
            gender = gender,
            registration_date = registrationDate.ToString("yyyy-MM-dd HH:mm:ss")
        };

        string jsonData = JsonUtility.ToJson(data);
        LogDetailed($"Sending: {jsonData}");

        // Send HTTP POST
        yield return StartCoroutine(SendPostRequest(jsonData, (response) => {
            // Parse response to get user_id
            var responseObj = JsonUtility.FromJson<PlayerResponse>(response);
            if (responseObj != null && responseObj.success)
            {
                playerNameToDbId[username] = responseObj.user_id;
                Log($"✓ Player '{username}' created with DB ID: {responseObj.user_id}");
            }
            else
            {
                LogError($"Failed to create player: {response}");
            }
        }));
    }

    /// <summary>
    /// Sends new session data to PHP backend
    /// Stores session_id mapping for later updates
    /// </summary>
    private IEnumerator SendNewSession(uint simulatorPlayerId, DateTime startTime)
    {
        // Find the database user_id
        // Strategy: Use the most recently created user
        // In production, you'd have more sophisticated ID tracking
        int dbUserId = GetLastUserId();

        if (dbUserId == 0)
        {
            LogError("Cannot start session: No user ID available");
            yield break;
        }

        var data = new SessionStartEventData
        {
            event_type = "new_session",
            user_id = dbUserId,
            start_time = startTime.ToString("yyyy-MM-dd HH:mm:ss")
        };

        string jsonData = JsonUtility.ToJson(data);
        LogDetailed($"Sending: {jsonData}");

        yield return StartCoroutine(SendPostRequest(jsonData, (response) => {
            var responseObj = JsonUtility.FromJson<SessionResponse>(response);
            if (responseObj != null && responseObj.success)
            {
                // Map this user to this session
                dbUserIdToCurrentDbSessionId[dbUserId] = responseObj.session_id;
                sessionStartTimes[startTime] = startTime;
                Log($"✓ Session {responseObj.session_id} started for user {dbUserId}");
            }
            else
            {
                LogError($"Failed to start session: {response}");
            }
        }));
    }

    /// <summary>
    /// Sends session end data to PHP backend
    /// Updates existing session with end time and duration
    /// </summary>
    private IEnumerator SendEndSession(uint simulatorIdentifier, DateTime endTime)
    {
        int sessionId = GetCurrentSessionId();

        if (sessionId == 0)
        {
            LogError("Cannot end session: No session ID available");
            yield break;
        }

        // Calculate duration (simplified - using 5 minutes default)
        // In production, track actual start time and calculate difference
        int durationSeconds = 300;

        var data = new SessionEndEventData
        {
            event_type = "end_session",
            session_id = sessionId,
            end_time = endTime.ToString("yyyy-MM-dd HH:mm:ss"),
            duration_seconds = durationSeconds
        };

        string jsonData = JsonUtility.ToJson(data);
        LogDetailed($"Sending: {jsonData}");

        yield return StartCoroutine(SendPostRequest(jsonData, (response) => {
            var responseObj = JsonUtility.FromJson<BaseResponse>(response);
            if (responseObj != null && responseObj.success)
            {
                Log($"✓ Session {sessionId} ended");
            }
            else
            {
                LogError($"Failed to end session: {response}");
            }
        }));
    }

    /// <summary>
    /// Sends purchase data to PHP backend
    /// Records item purchase with price
    /// </summary>
    private IEnumerator SendPurchase(int itemId, float amount, DateTime purchaseDate, uint simulatorSessionIdentifier)
    {
        int sessionId = GetCurrentSessionId();
        int userId = GetLastUserId();

        if (sessionId == 0 || userId == 0)
        {
            LogError("Cannot record purchase: No session/user ID available");
            yield break;
        }

        var data = new PurchaseEventData
        {
            event_type = "purchase",
            session_id = sessionId,
            user_id = userId,
            item_id = itemId,
            amount = amount,
            purchase_date = purchaseDate.ToString("yyyy-MM-dd HH:mm:ss")
        };

        string jsonData = JsonUtility.ToJson(data);
        LogDetailed($"Sending: {jsonData}");

        yield return StartCoroutine(SendPostRequest(jsonData, (response) => {
            var responseObj = JsonUtility.FromJson<PurchaseResponse>(response);
            if (responseObj != null && responseObj.success)
            {
                Log($"✓ Purchase recorded (Item {itemId}, ${amount})");
            }
            else
            {
                LogError($"Failed to record purchase: {response}");
            }
        }));
    }

    /// <summary>
    /// Generic POST request sender using UnityWebRequest
    /// Handles JSON serialization, HTTP headers, and async execution
    /// </summary>
    private IEnumerator SendPostRequest(string jsonData, System.Action<string> onSuccess)
    {
        using (UnityWebRequest request = UnityWebRequest.Post(serverUrl, ""))
        {
            // Attach JSON data
            byte[] bodyRaw = System.Text.Encoding.UTF8.GetBytes(jsonData);
            request.uploadHandler = new UploadHandlerRaw(bodyRaw);
            request.downloadHandler = new DownloadHandlerBuffer();
            request.SetRequestHeader("Content-Type", "application/json");

            // Send request
            yield return request.SendWebRequest();

            // Handle response
            if (request.result == UnityWebRequest.Result.Success)
            {
                string response = request.downloadHandler.text;
                LogDetailed($"Response: {response}");
                onSuccess?.Invoke(response);
            }
            else
            {
                LogError($"HTTP Error: {request.error}\nResponse: {request.downloadHandler.text}");
            }
        }
    }

    #endregion

    #region Helper Methods

    /// <summary>
    /// Gets the most recently created user ID
    /// Simplified approach - production would use better tracking
    /// </summary>
    private int GetLastUserId()
    {
        int maxId = 0;
        foreach (var kvp in playerNameToDbId)
        {
            if (kvp.Value > maxId) maxId = kvp.Value;
        }
        return maxId;
    }

    /// <summary>
    /// Gets the most recently created session ID
    /// </summary>
    private int GetCurrentSessionId()
    {
        int maxId = 0;
        foreach (var kvp in dbUserIdToCurrentDbSessionId)
        {
            if (kvp.Value > maxId) maxId = kvp.Value;
        }
        return maxId;
    }

    #endregion

    #region Logging

    private void Log(string message)
    {
        if (enableLogging)
        {
            Debug.Log($"<color=cyan>[Analytics]</color> {message}");
        }
    }

    private void LogDetailed(string message)
    {
        if (enableLogging && enableDetailedLogging)
        {
            Debug.Log($"<color=gray>[Analytics-Detail]</color> {message}");
        }
    }

    private void LogError(string message)
    {
        Debug.LogError($"<color=red>[Analytics ERROR]</color> {message}");
    }

    #endregion

    #region Data Classes for JSON Serialization

    [Serializable]
    private class PlayerEventData
    {
        public string event_type;
        public string username;
        public string country;
        public int age;
        public float gender;
        public string registration_date;
    }

    [Serializable]
    private class SessionStartEventData
    {
        public string event_type;
        public int user_id;
        public string start_time;
    }

    [Serializable]
    private class SessionEndEventData
    {
        public string event_type;
        public int session_id;
        public string end_time;
        public int duration_seconds;
    }

    [Serializable]
    private class PurchaseEventData
    {
        public string event_type;
        public int session_id;
        public int user_id;
        public int item_id;
        public float amount;
        public string purchase_date;
    }

    [Serializable]
    private class BaseResponse
    {
        public bool success;
        public string message;
        public string error;
    }

    [Serializable]
    private class PlayerResponse : BaseResponse
    {
        public int user_id;
    }

    [Serializable]
    private class SessionResponse : BaseResponse
    {
        public int session_id;
    }

    [Serializable]
    private class PurchaseResponse : BaseResponse
    {
        public int purchase_id;
    }

    #endregion
}
```

**⚠️ IMPORTANT**: Change line 11 in AnalyticsManager.cs:
```csharp
[SerializeField] private string serverUrl = "https://citmalumnes.upc.es/~yourUsername/receive_analytics.php";
```
Replace `yourUsername` with your actual UPC username!

#### Step 4.3: Add AnalyticsManager to Unity Scene

1. Open Unity Editor
2. Open the scene with the Simulator (likely `SampleScene.unity`)
3. Create an empty GameObject: `GameObject → Create Empty`
4. Rename it to "AnalyticsManager"
5. Add the script: Click "Add Component" → search "AnalyticsManager"
6. In Inspector:
   - ✅ Verify Server URL is correct
   - ✅ Check "Enable Logging"
   - ✅ Check "Enable Detailed Logging" (for testing)

---

## Testing & Debugging

### Day 11-12: Integration Testing

#### Step 5.1: Full Pipeline Test

1. **Clear database** (start fresh):
   ```sql
   DELETE FROM purchases;
   DELETE FROM sessions;
   DELETE FROM users;
   ```

2. **Press Play in Unity**

3. **Watch Console** for cyan-colored analytics logs:
   - `[Analytics] New Player: ...`
   - `[Analytics] ✓ Player created with DB ID: ...`
   - `[Analytics] New Session for simulator player ID: ...`
   - etc.

4. **Check SQL Workbench** after simulation finishes:
   ```sql
   SELECT COUNT(*) FROM users;     -- Should have ~100 players
   SELECT COUNT(*) FROM sessions;  -- Should have many sessions
   SELECT COUNT(*) FROM purchases; -- Should have some purchases
   ```

#### Step 5.2: Verify Data Quality

Run these queries to check data integrity:

```sql
-- Check if all sessions have valid users
SELECT COUNT(*) FROM sessions s
LEFT JOIN users u ON s.user_id = u.user_id
WHERE u.user_id IS NULL;
-- Should return 0 (no orphaned sessions)

-- Check if all purchases have valid sessions
SELECT COUNT(*) FROM purchases p
LEFT JOIN sessions s ON p.session_id = s.session_id
WHERE s.session_id IS NULL;
-- Should return 0

-- View sample data
SELECT
    u.username,
    u.country,
    COUNT(DISTINCT s.session_id) as session_count,
    COUNT(DISTINCT p.purchase_id) as purchase_count,
    COALESCE(SUM(p.amount), 0) as total_spent
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id
LEFT JOIN purchases p ON u.user_id = p.user_id
GROUP BY u.user_id
LIMIT 10;
```

#### Step 5.3: Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "HTTP Error: Cannot connect" | Check serverUrl in Inspector, verify PHP file is uploaded |
| "Missing field: username" | JSON serialization issue - check class field names match |
| No data in database | Check PHP error logs, verify config.php credentials |
| Sessions have NULL user_id | ID mapping issue - add Debug.Log to track ID flow |
| Unity freezes | Not using coroutines properly - ensure `yield return` |

---

## Part 2 Preview: KPI Analysis

### SQL Queries for KPIs

Once your data is flowing, you'll need these queries for Part 2:

#### DAU (Daily Active Users)
```sql
SELECT
    DATE(start_time) as date,
    COUNT(DISTINCT user_id) as dau
FROM sessions
GROUP BY DATE(start_time)
ORDER BY date;
```

#### MAU (Monthly Active Users)
```sql
SELECT
    DATE_FORMAT(start_time, '%Y-%m') as month,
    COUNT(DISTINCT user_id) as mau
FROM sessions
GROUP BY DATE_FORMAT(start_time, '%Y-%m')
ORDER BY month;
```

#### D1 Retention
```sql
SELECT
    COUNT(DISTINCT CASE
        WHEN DATEDIFF(s.start_time, u.registration_date) = 1
        THEN u.user_id
    END) / COUNT(DISTINCT u.user_id) * 100 as d1_retention
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id;
```

#### ARPU (Average Revenue Per User)
```sql
SELECT
    COALESCE(SUM(p.amount), 0) / COUNT(DISTINCT u.user_id) as arpu
FROM users u
LEFT JOIN purchases p ON u.user_id = p.user_id;
```

#### ARPPU (Average Revenue Per Paying User)
```sql
SELECT
    AVG(total_spent) as arppu
FROM (
    SELECT user_id, SUM(amount) as total_spent
    FROM purchases
    GROUP BY user_id
) paying_users;
```

#### Revenue by Country
```sql
SELECT
    u.country,
    COUNT(DISTINCT u.user_id) as user_count,
    COALESCE(SUM(p.amount), 0) as total_revenue,
    COALESCE(SUM(p.amount), 0) / COUNT(DISTINCT u.user_id) as arpu
FROM users u
LEFT JOIN purchases p ON u.user_id = p.user_id
GROUP BY u.country
ORDER BY total_revenue DESC;
```

### R Analysis Template

```r
# Install required packages
install.packages("RMySQL")
install.packages("ggplot2")

library(RMySQL)
library(ggplot2)

# Connect to database
con <- dbConnect(MySQL(),
                 host = "localhost",
                 user = "yourUsername",
                 password = "yourPassword",
                 dbname = "yourDatabase")

# Get DAU data
dau_data <- dbGetQuery(con, "
    SELECT DATE(start_time) as date, COUNT(DISTINCT user_id) as dau
    FROM sessions
    GROUP BY DATE(start_time)
    ORDER BY date
")

# Calculate confidence interval
t_test <- t.test(dau_data$dau)
cat("DAU Mean:", mean(dau_data$dau), "\n")
cat("95% CI:", t_test$conf.int[1], "to", t_test$conf.int[2], "\n")

# Visualize
ggplot(dau_data, aes(x = as.Date(date), y = dau)) +
    geom_line() +
    geom_point() +
    labs(title = "Daily Active Users Over Time",
         x = "Date", y = "DAU") +
    theme_minimal()

# Close connection
dbDisconnect(con)
```

---

## Final Deliverables

### Checklist

**Part 1: Data Collection** (Due Week 2)
- [ ] MySQL database with 4 tables created
- [ ] Items table populated with 5 items
- [ ] `config.php` uploaded to server
- [ ] `receive_analytics.php` uploaded to server
- [ ] `Item.cs` added to Unity project
- [ ] `AnalyticsManager.cs` added to Unity project
- [ ] AnalyticsManager GameObject added to scene
- [ ] Full pipeline tested (Unity → PHP → MySQL)
- [ ] Data validation queries run successfully
- [ ] Screenshot: SQL Workbench showing populated tables
- [ ] Screenshot: Unity Console showing successful analytics logs
- [ ] `schema.sql` file saved for documentation

**Part 2: KPI Analysis** (Future)
- [ ] SQL queries for all required KPIs written
- [ ] R script for statistical analysis completed
- [ ] Confidence intervals calculated (95% CI)
- [ ] Visualizations created (graphs, charts)
- [ ] Demographic segmentation analysis done
- [ ] Presentation slides prepared (10 min)
- [ ] Documentation explaining data model rationale
- [ ] Reflection on strengths/limitations written

### Files to Submit

```
Delivery 1 KPIs/
├── Backend/
│   ├── config.php
│   └── receive_analytics.php
├── Database/
│   ├── schema.sql
│   └── kpi_queries.sql
├── Delivery1_Simulator/
│   └── Assets/_Scripts/
│       ├── Item.cs
│       └── AnalyticsManager.cs
├── Analysis/
│   └── analysis.R
├── Documentation/
│   ├── data_model_explanation.md
│   ├── screenshots/
│   └── presentation.pptx
└── IMPLEMENTATION_GUIDE.md (this file)
```

### Presentation Outline (10 minutes)

1. **Data Model (2 min)**
   - Show database schema diagram
   - Explain why normalized structure
   - Discuss indexes for performance

2. **Pipeline Architecture (2 min)**
   - Unity → PHP → MySQL flow diagram
   - Non-intrusive async design
   - ID mapping strategy

3. **KPI Results (4 min)**
   - DAU/MAU trends with visualizations
   - Retention metrics (D1, D3, D7)
   - ARPU/ARPPU with confidence intervals
   - Demographic insights (country/age analysis)

4. **Strengths & Limitations (2 min)**
   - ✅ Scalable, normalized design
   - ✅ Async, non-blocking transmission
   - ⚠️ Simplified ID tracking
   - ⚠️ No retry logic for failed requests

---

## Evaluation Alignment

Your implementation scores well because:

### Gather & Store (50%) - Excellent
- ✅ **Data schema well thought out**: Normalized, 4 tables with clear relationships
- ✅ **Database efficient**: Indexes on date fields, foreign keys, AUTO_INCREMENT
- ✅ **Non-intrusive transmission**: Coroutines, fire-and-forget, async
- ✅ **SOLID principles**: Single Responsibility (AnalyticsManager only handles analytics)
- ✅ **Scalable**: Can handle thousands of events with batching approach

### Analytics (30%) - To be completed in Part 2
- Efficient SQL queries provided
- R template includes confidence intervals
- Statistical rigor with t.test()

### Reporting (20%) - To be completed in Part 2
- Clear visualization templates
- Professional presentation structure

---

## Quick Reference

### DateTime Format
Always: `"yyyy-MM-dd HH:mm:ss"`
```csharp
dateTime.ToString("yyyy-MM-dd HH:mm:ss")
```

### Testing Commands
```bash
# Clear database
DELETE FROM purchases; DELETE FROM sessions; DELETE FROM users;

# Check counts
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM sessions;
SELECT COUNT(*) FROM purchases;

# Test PHP
curl -X POST https://citmalumnes.upc.es/~yourUser/receive_analytics.php \
  -H "Content-Type: application/json" \
  -d '{"event_type":"new_player","username":"Test",...}'
```

### Unity Tips
- Check Inspector: Server URL must be exact
- Console logs: Look for cyan `[Analytics]` messages
- Detailed logging: Enable for debugging, disable for performance

---

**Good luck with your implementation! Follow this guide step-by-step and you'll have a solid analytics pipeline.** 🎮📊
