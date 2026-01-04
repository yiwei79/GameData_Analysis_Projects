using UnityEngine;
using UnityEngine.Networking;
using System.Collections;
using System.Collections.Generic;

namespace GameAnalytics
{
    /// <summary>
    /// Handles export of analytics data to PHP backend via HTTP POST
    /// Uses UnityWebRequest for async communication with MySQL database
    /// </summary>
    public class AnalyticsExporter : MonoBehaviour
    {
        [Header("Configuration")]
        [SerializeField]
        [Tooltip("PHP endpoint URL - Update if using different port")]
        private string phpEndpoint = "http://localhost:8888/delivery3_backend/receive_analytics.php";

        [SerializeField]
        [Tooltip("Enable detailed logging for debugging")]
        private bool enableDetailedLogging = true;

        [SerializeField]
        [Tooltip("Timeout for HTTP requests in seconds")]
        private float requestTimeout = 10f;

        private bool isInitialized = false;

        /// <summary>
        /// Initialize the exporter with custom endpoint
        /// </summary>
        public void Initialize(string customEndpoint = null)
        {
            if (!string.IsNullOrEmpty(customEndpoint))
            {
                phpEndpoint = customEndpoint;
            }

            isInitialized = true;

            if (enableDetailedLogging)
            {
                Debug.Log($"[AnalyticsExporter] Initialized with endpoint: {phpEndpoint}");
            }
        }

        /// <summary>
        /// Send session start event
        /// </summary>
        public void SendSessionStart(string sessionId)
        {
            if (!isInitialized)
            {
                Debug.LogWarning("[AnalyticsExporter] Not initialized! Call Initialize() first.");
                return;
            }

            var payload = new SessionStartPayload(sessionId);
            StartCoroutine(PostJSON(payload, "Session Start"));
        }

        /// <summary>
        /// Send session end event
        /// </summary>
        public void SendSessionEnd(string sessionId, float durationSeconds)
        {
            if (!isInitialized) return;

            var payload = new SessionEndPayload(sessionId, durationSeconds);
            StartCoroutine(PostJSON(payload, "Session End"));
        }

        /// <summary>
        /// Send batch of position samples
        /// </summary>
        public void SendPositionsBatch(string sessionId, List<PositionSample> positions)
        {
            if (!isInitialized || positions == null || positions.Count == 0) return;

            var payload = new PositionsBatchPayload(sessionId, positions);
            StartCoroutine(PostJSON(payload, $"Positions Batch ({positions.Count} samples)"));
        }

        /// <summary>
        /// Send death event
        /// </summary>
        public void SendDeath(string sessionId, string entityType, Vector3 position, string cause, float timestamp)
        {
            if (!isInitialized) return;

            var deathData = new DeathEventData(sessionId, entityType, position, cause, timestamp);
            var payload = new DeathPayload(deathData);
            StartCoroutine(PostJSON(payload, $"Death Event ({entityType})"));
        }

        /// <summary>
        /// Send pickup event
        /// </summary>
        public void SendPickup(string sessionId, string itemName, Vector3 position, float timestamp)
        {
            if (!isInitialized) return;

            var pickupData = new PickupEventData(sessionId, itemName, position, timestamp);
            var payload = new PickupPayload(pickupData);
            StartCoroutine(PostJSON(payload, $"Pickup Event ({itemName})"));
        }

        /// <summary>
        /// Send combat event
        /// </summary>
        public void SendCombat(string sessionId, string attacker, string target, float damage, Vector3 position, float timestamp)
        {
            if (!isInitialized) return;

            var combatData = new CombatEventData(sessionId, attacker, target, damage, position, timestamp);
            var payload = new CombatPayload(combatData);
            StartCoroutine(PostJSON(payload, $"Combat Event ({attacker} -> {target})"));
        }

        /// <summary>
        /// Generic POST request with JSON payload
        /// </summary>
        private IEnumerator PostJSON(object data, string eventDescription)
        {
            // Serialize to JSON
            string json = JsonUtility.ToJson(data);

            if (enableDetailedLogging)
            {
                Debug.Log($"[AnalyticsExporter] Sending {eventDescription}:\n{json}");
            }

            // Create POST request
            using (UnityWebRequest request = new UnityWebRequest(phpEndpoint, "POST"))
            {
                // Set request body
                byte[] bodyRaw = System.Text.Encoding.UTF8.GetBytes(json);
                request.uploadHandler = new UploadHandlerRaw(bodyRaw);
                request.downloadHandler = new DownloadHandlerBuffer();

                // Set headers
                request.SetRequestHeader("Content-Type", "application/json");
                request.timeout = Mathf.RoundToInt(requestTimeout);

                // Send request
                yield return request.SendWebRequest();

                // Handle response
                if (request.result == UnityWebRequest.Result.Success)
                {
                    if (enableDetailedLogging)
                    {
                        Debug.Log($"[AnalyticsExporter] {eventDescription} SUCCESS: {request.downloadHandler.text}");
                    }
                }
                else
                {
                    Debug.LogError($"[AnalyticsExporter] {eventDescription} FAILED:\n" +
                                   $"Error: {request.error}\n" +
                                   $"Response Code: {request.responseCode}\n" +
                                   $"URL: {phpEndpoint}");

                    // Log response body if available
                    if (!string.IsNullOrEmpty(request.downloadHandler.text))
                    {
                        Debug.LogError($"Response: {request.downloadHandler.text}");
                    }
                }
            }
        }

        /// <summary>
        /// Test connection to PHP backend
        /// </summary>
        public void TestConnection()
        {
            StartCoroutine(TestConnectionCoroutine());
        }

        private IEnumerator TestConnectionCoroutine()
        {
            string testUrl = phpEndpoint.Replace("receive_analytics.php", "test_connection.php");

            Debug.Log($"[AnalyticsExporter] Testing connection to: {testUrl}");

            using (UnityWebRequest request = UnityWebRequest.Get(testUrl))
            {
                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    Debug.Log($"[AnalyticsExporter] Connection test SUCCESS:\n{request.downloadHandler.text}");
                }
                else
                {
                    Debug.LogError($"[AnalyticsExporter] Connection test FAILED:\n{request.error}");
                }
            }
        }

        /// <summary>
        /// Cleanup on destroy
        /// </summary>
        void OnDestroy()
        {
            StopAllCoroutines();
        }
    }
}
