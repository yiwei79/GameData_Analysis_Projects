using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Gamekit3D;

namespace GameAnalytics
{
    /// <summary>
    /// Main analytics collection component
    /// - Subscribes to 3D Game Kit events (non-intrusive)
    /// - Samples player position at regular intervals
    /// - Sends data to PHP backend via AnalyticsExporter
    ///
    /// IMPORTANT: This script does NOT modify any 3D Game Kit code
    /// It only listens to existing UnityEvents and samples public data
    /// </summary>
    public class AnalyticsCollector : MonoBehaviour
    {
        [Header("Configuration")]
        [SerializeField]
        [Tooltip("Position sampling rate in seconds (default: 0.5s = 2 Hz)")]
        private float positionSampleRate = 0.5f;

        [SerializeField]
        [Tooltip("Number of positions to batch before sending (default: 20)")]
        private int positionBatchSize = 20;

        [SerializeField]
        [Tooltip("PHP backend endpoint URL")]
        private string phpEndpoint = "http://localhost:8888/delivery3_backend/receive_analytics.php";

        [SerializeField]
        [Tooltip("Enable detailed debug logging")]
        private bool enableDetailedLogging = true;

        [Header("Status (Read-Only)")]
        [SerializeField]
        [Tooltip("Current session ID (auto-generated UUID)")]
        private string sessionId;

        [SerializeField]
        [Tooltip("Session start time")]
        private float sessionStartTime;

        [SerializeField]
        [Tooltip("Number of position samples collected this session")]
        private int positionSampleCount = 0;

        [SerializeField]
        [Tooltip("Number of death events recorded this session")]
        private int deathEventCount = 0;

        // Components
        private AnalyticsExporter exporter;

        // Data buffers
        private List<PositionSample> positionBuffer = new List<PositionSample>();

        // Coroutine reference
        private Coroutine positionSamplingCoroutine;

        // Subscription tracking
        private bool isSubscribedToEvents = false;

        #region Unity Lifecycle

        void Start()
        {
            // Create and initialize exporter
            exporter = gameObject.AddComponent<AnalyticsExporter>();
            exporter.Initialize(phpEndpoint);

            // Start analytics session
            StartSession();

            // Test connection (optional, comment out in production)
            if (enableDetailedLogging)
            {
                exporter.TestConnection();
            }
        }

        void OnEnable()
        {
            SubscribeToGameEvents();

            // Start position sampling
            if (positionSamplingCoroutine == null)
            {
                positionSamplingCoroutine = StartCoroutine(PositionSamplingRoutine());
            }
        }

        void OnDisable()
        {
            UnsubscribeFromGameEvents();

            // Stop position sampling
            if (positionSamplingCoroutine != null)
            {
                StopCoroutine(positionSamplingCoroutine);
                positionSamplingCoroutine = null;
            }
        }

        void OnApplicationQuit()
        {
            EndSession();
        }

        void OnDestroy()
        {
            EndSession();
        }

        #endregion

        #region Session Management

        /// <summary>
        /// Start a new analytics session
        /// </summary>
        private void StartSession()
        {
            sessionId = System.Guid.NewGuid().ToString();
            sessionStartTime = Time.time;
            positionSampleCount = 0;
            deathEventCount = 0;

            Log($"Starting analytics session: {sessionId}");

            exporter.SendSessionStart(sessionId);
        }

        /// <summary>
        /// End current session and flush remaining data
        /// </summary>
        private void EndSession()
        {
            if (string.IsNullOrEmpty(sessionId))
                return;

            Log($"Ending analytics session: {sessionId}");

            // Flush any remaining position data
            FlushPositionBuffer();

            // Send session end event
            float duration = Time.time - sessionStartTime;
            exporter.SendSessionEnd(sessionId, duration);

            Log($"Session ended. Duration: {duration:F1}s, Positions: {positionSampleCount}, Deaths: {deathEventCount}");

            sessionId = null;
        }

        #endregion

        #region Event Subscription

        /// <summary>
        /// Subscribe to 3D Game Kit events
        /// Non-intrusive: only listens to existing UnityEvents
        /// </summary>
        private void SubscribeToGameEvents()
        {
            if (isSubscribedToEvents)
                return;

            // Subscribe to player death
            if (PlayerController.instance != null)
            {
                var playerDamageable = PlayerController.instance.GetComponent<Damageable>();
                if (playerDamageable != null)
                {
                    playerDamageable.OnDeath.AddListener(OnPlayerDeath);
                    Log("Subscribed to player death events");
                }
                else
                {
                    LogWarning("PlayerController found but no Damageable component!");
                }
            }
            else
            {
                LogWarning("PlayerController.instance is null - will retry in PositionSamplingRoutine");
            }

            // Subscribe to enemy deaths
            SubscribeToEnemyDeaths();

            // Subscribe to pickups (if InventoryController is available)
            SubscribeToPickups();

            isSubscribedToEvents = true;
        }

        /// <summary>
        /// Unsubscribe from all events
        /// </summary>
        private void UnsubscribeFromGameEvents()
        {
            if (!isSubscribedToEvents)
                return;

            // Unsubscribe from player death
            if (PlayerController.instance != null)
            {
                var playerDamageable = PlayerController.instance.GetComponent<Damageable>();
                if (playerDamageable != null)
                {
                    playerDamageable.OnDeath.RemoveListener(OnPlayerDeath);
                }
            }

            // Note: Enemy deaths are subscribed individually, would need to track them to unsubscribe
            // For this analytics use case, it's okay to leave them subscribed

            isSubscribedToEvents = false;
        }

        /// <summary>
        /// Subscribe to all enemy death events
        /// </summary>
        private void SubscribeToEnemyDeaths()
        {
            // Find all Damageable components in the scene
            var allDamageables = FindObjectsOfType<Damageable>();

            int enemyCount = 0;

            foreach (var damageable in allDamageables)
            {
                // Skip player
                if (PlayerController.instance != null &&
                    damageable.gameObject == PlayerController.instance.gameObject)
                {
                    continue;
                }

                // Subscribe to enemy death (capture local variable to avoid closure issues)
                GameObject enemyObj = damageable.gameObject;
                damageable.OnDeath.AddListener(() => OnEnemyDeath(enemyObj));
                enemyCount++;
            }

            Log($"Subscribed to {enemyCount} enemy death events");
        }

        /// <summary>
        /// Subscribe to pickup events (if available in 3D Game Kit)
        /// </summary>
        private void SubscribeToPickups()
        {
            // Note: 3D Game Kit Lite may not have InventoryController
            // This is a placeholder for when pickup tracking is needed
            // Uncomment and adjust if your version has inventory system

            /*
            var inventory = FindObjectOfType<InventoryController>();
            if (inventory != null)
            {
                // Subscribe to inventory events
                // inventory.inventoryEvents[].OnAdd += OnItemPickup;
                Log("Subscribed to pickup events");
            }
            */
        }

        #endregion

        #region Position Sampling

        /// <summary>
        /// Coroutine that samples player position at regular intervals
        /// </summary>
        private IEnumerator PositionSamplingRoutine()
        {
            // Wait a bit for game to initialize
            yield return new WaitForSeconds(1f);

            while (true)
            {
                yield return new WaitForSeconds(positionSampleRate);

                // Retry subscription if player wasn't available at start
                if (PlayerController.instance != null && !isSubscribedToEvents)
                {
                    SubscribeToGameEvents();
                }

                // Sample position
                if (PlayerController.instance != null)
                {
                    SamplePlayerPosition();
                }
            }
        }

        /// <summary>
        /// Sample current player position and speed
        /// </summary>
        private void SamplePlayerPosition()
        {
            if (PlayerController.instance == null)
                return;

            Vector3 position = PlayerController.instance.transform.position;

            // Get speed from CharacterController if available
            float speed = 0f;
            var characterController = PlayerController.instance.GetComponent<CharacterController>();
            if (characterController != null)
            {
                speed = characterController.velocity.magnitude;
            }

            float timestamp = Time.time - sessionStartTime;

            // Add to buffer
            var sample = new PositionSample(position, speed, timestamp);
            positionBuffer.Add(sample);
            positionSampleCount++;

            // Send batch when buffer is full
            if (positionBuffer.Count >= positionBatchSize)
            {
                FlushPositionBuffer();
            }
        }

        /// <summary>
        /// Send all buffered positions to backend
        /// </summary>
        private void FlushPositionBuffer()
        {
            if (positionBuffer.Count == 0)
                return;

            Log($"Flushing {positionBuffer.Count} position samples");

            exporter.SendPositionsBatch(sessionId, positionBuffer);
            positionBuffer.Clear();
        }

        #endregion

        #region Event Handlers

        /// <summary>
        /// Called when player dies (parameterless UnityEvent)
        /// </summary>
        private void OnPlayerDeath()
        {
            if (PlayerController.instance == null)
                return;

            Vector3 position = PlayerController.instance.transform.position;
            string cause = "Unknown"; // OnDeath doesn't provide damage info
            float timestamp = Time.time - sessionStartTime;

            Log($"Player death recorded: Position={position}, Time={timestamp:F1}s");

            exporter.SendDeath(sessionId, "Player", position, cause, timestamp);
            deathEventCount++;
        }

        /// <summary>
        /// Called when an enemy dies (parameterless UnityEvent, enemy captured in closure)
        /// </summary>
        private void OnEnemyDeath(GameObject enemyObject)
        {
            if (enemyObject == null)
                return;

            Vector3 position = enemyObject.transform.position;
            string entityType = enemyObject.name; // e.g., "Chomper", "Spitter(Clone)"
            string cause = "Unknown"; // OnDeath doesn't provide damage info
            float timestamp = Time.time - sessionStartTime;

            // Clean up "(Clone)" from name
            entityType = entityType.Replace("(Clone)", "").Trim();

            Log($"Enemy death recorded: Type={entityType}, Position={position}, Time={timestamp:F1}s");

            exporter.SendDeath(sessionId, entityType, position, cause, timestamp);
            deathEventCount++;
        }

        /// <summary>
        /// Called when player picks up an item
        /// </summary>
        private void OnItemPickup(string itemName, Vector3 position)
        {
            float timestamp = Time.time - sessionStartTime;

            Log($"Item pickup recorded: Item={itemName}, Position={position}, Time={timestamp:F1}s");

            exporter.SendPickup(sessionId, itemName, position, timestamp);
        }

        #endregion

        #region Logging Helpers

        private void Log(string message)
        {
            if (enableDetailedLogging)
            {
                Debug.Log($"[AnalyticsCollector] {message}");
            }
        }

        private void LogWarning(string message)
        {
            if (enableDetailedLogging)
            {
                Debug.LogWarning($"[AnalyticsCollector] {message}");
            }
        }

        #endregion

        #region Public API (for manual events if needed)

        /// <summary>
        /// Manually record a custom event
        /// </summary>
        public void RecordCustomEvent(string eventType, Vector3 position)
        {
            float timestamp = Time.time - sessionStartTime;
            // Could extend with custom event type in future
            Log($"Custom event recorded: Type={eventType}, Position={position}, Time={timestamp:F1}s");
        }

        /// <summary>
        /// Manually flush position buffer
        /// </summary>
        public void ManualFlush()
        {
            FlushPositionBuffer();
        }

        #endregion
    }
}
