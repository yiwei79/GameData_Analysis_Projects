using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

/// <summary>
/// AnalyticsManager - Main analytics collection and transmission system
/// =====================================================
/// CRITICAL DESIGN PRINCIPLE:
/// This script subscribes to Simulator events WITHOUT modifying Simulator.cs
/// It implements a non-intrusive, asynchronous data collection pipeline
/// =====================================================
/// Architecture:
/// 1. Subscribe to Simulator's 4 static Action events
/// 2. Package event data as JSON
/// 3. Send async HTTP POST to PHP backend
/// 4. Receive database IDs and maintain mappings
/// =====================================================
/// </summary>
public class AnalyticsManager : MonoBehaviour
{
    #region Configuration

    [Header("Server Configuration")]
    [Tooltip("Your UPC PHP endpoint URL - MUST UPDATE WITH YOUR USERNAME")]
    [SerializeField] private string serverUrl = "https://citmalumnes.upc.es/~yiweiy/receive_analytics.php";

    [Header("Debug Settings")]
    [Tooltip("Enable console logging for analytics events")]
    [SerializeField] private bool enableLogging = true;

    [Tooltip("Enable detailed JSON logging (verbose)")]
    [SerializeField] private bool enableDetailedLogging = false;

    #endregion

    #region ID Tracking

    // Mapping dictionaries to translate Simulator IDs → Database IDs
    // The Simulator uses internal uint IDs that don't match database AUTO_INCREMENT IDs
    private Dictionary<string, int> playerNameToDbId = new Dictionary<string, int>();
    private Dictionary<int, int> dbUserIdToCurrentDbSessionId = new Dictionary<int, int>();
    private Dictionary<int, DateTime> dbSessionIdToStartTime = new Dictionary<int, DateTime>();

    #endregion

    #region Unity Lifecycle

    /// <summary>
    /// Subscribe to Simulator events when this component is enabled
    /// </summary>
    private void OnEnable()
    {
        // Subscribe to all 4 Simulator events
        Simulator.OnNewPlayer += HandleNewPlayer;
        Simulator.OnNewSession += HandleNewSession;
        Simulator.OnEndSession += HandleEndSession;
        Simulator.OnBuyItem += HandleBuyItem;

        Log("AnalyticsManager enabled - Listening to Simulator events");
    }

    /// <summary>
    /// Unsubscribe from events when disabled (prevents memory leaks)
    /// </summary>
    private void OnDisable()
    {
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
    /// Creates a new user in database and stores the mapping
    /// Signature: Action<string name, string country, int age, float gender, DateTime date>
    /// </summary>
    private void HandleNewPlayer(string name, string country, int age, float gender, DateTime registrationDate)
    {
        Log($"[EVENT] New Player: {name} from {country}, age {age}");
        StartCoroutine(SendNewPlayer(name, country, age, gender, registrationDate));
    }

    /// <summary>
    /// Handles OnNewSession event from Simulator
    /// Creates a new session in database
    /// Signature: Action<DateTime startTime, uint simulatorId>
    /// Note: simulatorId is Simulator's internal identifier, not a database ID
    /// </summary>
    private void HandleNewSession(DateTime startTime, uint simulatorId)
    {
        Log($"[EVENT] New Session at {startTime:yyyy-MM-dd HH:mm:ss} (Simulator ID: {simulatorId})");
        StartCoroutine(SendNewSession(simulatorId, startTime));
    }

    /// <summary>
    /// Handles OnEndSession event from Simulator
    /// Updates existing session with end_time and duration
    /// Signature: Action<DateTime endTime, uint simulatorId>
    /// </summary>
    private void HandleEndSession(DateTime endTime, uint simulatorId)
    {
        Log($"[EVENT] End Session at {endTime:yyyy-MM-dd HH:mm:ss} (Simulator ID: {simulatorId})");
        StartCoroutine(SendEndSession(simulatorId, endTime));
    }

    /// <summary>
    /// Handles OnBuyItem event from Simulator
    /// Records a purchase in database
    /// Signature: Action<int itemId, DateTime purchaseDate, uint simulatorId>
    /// </summary>
    private void HandleBuyItem(int itemId, DateTime purchaseDate, uint simulatorId)
    {
        Log($"[EVENT] Purchase: Item {itemId} at {purchaseDate:yyyy-MM-dd HH:mm:ss}");

        // Look up item details from catalog
        Item item = Item.GetItem(itemId);
        if (item == null)
        {
            LogError($"Unknown item ID: {itemId}");
            return;
        }

        StartCoroutine(SendPurchase(itemId, item.price, purchaseDate, simulatorId));
    }

    #endregion

    #region HTTP Senders

    /// <summary>
    /// Sends new player data to PHP backend
    /// Waits for response to get database-generated user_id
    /// </summary>
    private IEnumerator SendNewPlayer(string username, string country, int age, float gender, DateTime registrationDate)
    {
        // Create data object for JSON serialization
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

        // Send HTTP POST and handle response
        yield return StartCoroutine(SendPostRequest(jsonData, (response) =>
        {
            // DEBUG: Log raw response to diagnose JSON parsing issues
            Debug.Log($"<color=yellow>[DEBUG] Raw PHP Response:</color>\n{response}");
            Debug.Log($"<color=yellow>[DEBUG] Response Length:</color> {response.Length} chars");

            // Parse JSON response from PHP
            var responseObj = JsonUtility.FromJson<PlayerResponse>(response);
            if (responseObj != null && responseObj.success)
            {
                // Store mapping: player name → database user_id
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
        // Find database user_id
        // Strategy: Use most recently created user (simplified approach)
        // In production, you'd have more sophisticated tracking
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

        yield return StartCoroutine(SendPostRequest(jsonData, (response) =>
        {
            var responseObj = JsonUtility.FromJson<SessionResponse>(response);
            if (responseObj != null && responseObj.success)
            {
                // Store mappings
                dbUserIdToCurrentDbSessionId[dbUserId] = responseObj.session_id;
                dbSessionIdToStartTime[responseObj.session_id] = startTime;
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
    /// Updates existing session with end_time and calculated duration
    /// </summary>
    private IEnumerator SendEndSession(uint simulatorIdentifier, DateTime endTime)
    {
        // Find current session_id from mappings
        int sessionId = GetCurrentSessionId();

        if (sessionId == 0)
        {
            LogError("Cannot end session: No session ID available");
            yield break;
        }

        // Calculate duration in seconds
        int durationSeconds = 300; // Default 5 minutes
        if (dbSessionIdToStartTime.ContainsKey(sessionId))
        {
            DateTime startTime = dbSessionIdToStartTime[sessionId];
            durationSeconds = (int)(endTime - startTime).TotalSeconds;
        }

        var data = new SessionEndEventData
        {
            event_type = "end_session",
            session_id = sessionId,
            end_time = endTime.ToString("yyyy-MM-dd HH:mm:ss"),
            duration_seconds = durationSeconds
        };

        string jsonData = JsonUtility.ToJson(data);
        LogDetailed($"Sending: {jsonData}");

        yield return StartCoroutine(SendPostRequest(jsonData, (response) =>
        {
            var responseObj = JsonUtility.FromJson<BaseResponse>(response);
            if (responseObj != null && responseObj.success)
            {
                Log($"✓ Session {sessionId} ended (duration: {durationSeconds}s)");
            }
            else
            {
                LogError($"Failed to end session: {response}");
            }
        }));
    }

    /// <summary>
    /// Sends purchase data to PHP backend
    /// Records item purchase with price and timestamp
    /// </summary>
    private IEnumerator SendPurchase(int itemId, float amount, DateTime purchaseDate, uint simulatorIdentifier)
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

        yield return StartCoroutine(SendPostRequest(jsonData, (response) =>
        {
            var responseObj = JsonUtility.FromJson<PurchaseResponse>(response);
            if (responseObj != null && responseObj.success)
            {
                Log($"✓ Purchase recorded: Item {itemId} (${amount}) - Purchase ID: {responseObj.purchase_id}");
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
    /// <param name="jsonData">JSON string to send</param>
    /// <param name="onSuccess">Callback invoked with response string on success</param>
    private IEnumerator SendPostRequest(string jsonData, System.Action<string> onSuccess)
    {
        using (UnityWebRequest request = UnityWebRequest.PostWwwForm(serverUrl, ""))
        {
            // Attach JSON data as raw bytes
            byte[] bodyRaw = System.Text.Encoding.UTF8.GetBytes(jsonData);
            request.uploadHandler = new UploadHandlerRaw(bodyRaw);
            request.downloadHandler = new DownloadHandlerBuffer();

            // Set HTTP headers
            request.SetRequestHeader("Content-Type", "application/json");

            // Send request and wait for response
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
                LogError($"HTTP Error: {request.error}\nResponse Code: {request.responseCode}\nResponse: {request.downloadHandler.text}");
            }
        }
    }

    #endregion

    #region Helper Methods

    /// <summary>
    /// Gets the most recently created user ID from mappings
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
    /// Gets the most recently created session ID from mappings
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

    // These classes must match the PHP backend expectations

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

    // Response classes for parsing PHP JSON responses

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
