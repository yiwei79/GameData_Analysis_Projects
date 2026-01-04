using UnityEngine;
using UnityEngine.Networking;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;

namespace GameAnalytics.Editor
{
    /// <summary>
    /// Handles importing analytics data from PHP backend into Unity Editor
    /// Uses UnityWebRequest to fetch session data from MySQL database
    /// </summary>
    public class AnalyticsDataImporter
    {
        // PHP endpoint URLs (update port if needed)
        private const string GET_SESSIONS_URL = "http://localhost:8888/delivery3_backend/get_sessions.php";
        private const string GET_SESSION_DATA_URL = "http://localhost:8888/delivery3_backend/get_session_data.php";
        private const string TEST_CONNECTION_URL = "http://localhost:8888/delivery3_backend/test_connection.php";

        // Singleton instance for editor coroutines
        private static EditorCoroutineRunner coroutineRunner;

        /// <summary>
        /// Test connection to PHP backend
        /// </summary>
        public static void TestConnection(System.Action<bool, string> callback)
        {
            EnsureCoroutineRunner();
            coroutineRunner.StartCoroutine(TestConnectionCoroutine(callback));
        }

        /// <summary>
        /// Fetch list of all available sessions
        /// </summary>
        public static void FetchSessionList(System.Action<List<SessionInfo>> callback)
        {
            EnsureCoroutineRunner();
            coroutineRunner.StartCoroutine(FetchSessionListCoroutine(callback));
        }

        /// <summary>
        /// Load complete data for a specific session
        /// </summary>
        public static void LoadSessionData(string sessionId, System.Action<SessionData> callback)
        {
            EnsureCoroutineRunner();
            coroutineRunner.StartCoroutine(LoadSessionDataCoroutine(sessionId, callback));
        }

        #region Coroutines

        private static IEnumerator TestConnectionCoroutine(System.Action<bool, string> callback)
        {
            Debug.Log($"[AnalyticsImporter] Testing connection to: {TEST_CONNECTION_URL}");

            using (UnityWebRequest request = UnityWebRequest.Get(TEST_CONNECTION_URL))
            {
                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    Debug.Log($"[AnalyticsImporter] Connection test SUCCESS:\n{request.downloadHandler.text}");
                    callback?.Invoke(true, request.downloadHandler.text);
                }
                else
                {
                    Debug.LogError($"[AnalyticsImporter] Connection test FAILED:\n{request.error}");
                    callback?.Invoke(false, request.error);
                }
            }
        }

        private static IEnumerator FetchSessionListCoroutine(System.Action<List<SessionInfo>> callback)
        {
            Debug.Log($"[AnalyticsImporter] Fetching session list from: {GET_SESSIONS_URL}");

            using (UnityWebRequest request = UnityWebRequest.Get(GET_SESSIONS_URL))
            {
                request.timeout = 10; // 10 second timeout

                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    string json = request.downloadHandler.text;
                    Debug.Log($"[AnalyticsImporter] Session list response: {json}");

                    try
                    {
                        // Parse JSON response
                        SessionListResponse response = JsonUtility.FromJson<SessionListResponse>(json);

                        if (response != null && response.success)
                        {
                            Debug.Log($"[AnalyticsImporter] Successfully fetched {response.count} sessions");
                            callback?.Invoke(response.sessions ?? new List<SessionInfo>());
                        }
                        else
                        {
                            Debug.LogError("[AnalyticsImporter] Response indicates failure");
                            callback?.Invoke(new List<SessionInfo>());
                        }
                    }
                    catch (System.Exception e)
                    {
                        Debug.LogError($"[AnalyticsImporter] Failed to parse JSON: {e.Message}\nJSON: {json}");
                        callback?.Invoke(new List<SessionInfo>());
                    }
                }
                else
                {
                    Debug.LogError($"[AnalyticsImporter] Failed to fetch sessions: {request.error}");
                    callback?.Invoke(new List<SessionInfo>());
                }
            }
        }

        private static IEnumerator LoadSessionDataCoroutine(string sessionId, System.Action<SessionData> callback)
        {
            string url = $"{GET_SESSION_DATA_URL}?session_id={UnityWebRequest.EscapeURL(sessionId)}";
            Debug.Log($"[AnalyticsImporter] Loading session data from: {url}");

            using (UnityWebRequest request = UnityWebRequest.Get(url))
            {
                request.timeout = 30; // 30 second timeout for large datasets

                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    string json = request.downloadHandler.text;
                    Debug.Log($"[AnalyticsImporter] Session data loaded ({json.Length} bytes)");

                    try
                    {
                        // Parse JSON response
                        SessionDataResponse response = JsonUtility.FromJson<SessionDataResponse>(json);

                        if (response != null && response.success)
                        {
                            SessionData sessionData = response.ToSessionData();

                            Debug.Log($"[AnalyticsImporter] Session loaded successfully:\n" +
                                     $"  - Positions: {sessionData.positions.Count}\n" +
                                     $"  - Deaths: {sessionData.deaths.Count}\n" +
                                     $"  - Pickups: {sessionData.pickups.Count}\n" +
                                     $"  - Duration: {sessionData.info.duration_seconds}s");

                            callback?.Invoke(sessionData);
                        }
                        else
                        {
                            Debug.LogError($"[AnalyticsImporter] Response indicates failure for session: {sessionId}");
                            callback?.Invoke(null);
                        }
                    }
                    catch (System.Exception e)
                    {
                        Debug.LogError($"[AnalyticsImporter] Failed to parse session data: {e.Message}\nJSON: {json.Substring(0, Mathf.Min(500, json.Length))}...");
                        callback?.Invoke(null);
                    }
                }
                else
                {
                    Debug.LogError($"[AnalyticsImporter] Failed to load session data: {request.error}");
                    callback?.Invoke(null);
                }
            }
        }

        #endregion

        #region Editor Coroutine Runner

        /// <summary>
        /// Ensure we have a coroutine runner for editor scripts
        /// </summary>
        private static void EnsureCoroutineRunner()
        {
            if (coroutineRunner == null)
            {
                // Create a hidden GameObject to run coroutines in the editor
                GameObject runnerObject = new GameObject("EditorCoroutineRunner");
                runnerObject.hideFlags = HideFlags.HideAndDontSave;
                coroutineRunner = runnerObject.AddComponent<EditorCoroutineRunner>();
            }
        }

        /// <summary>
        /// Hidden MonoBehaviour to run coroutines in editor
        /// </summary>
        private class EditorCoroutineRunner : MonoBehaviour
        {
            // This component exists solely to enable StartCoroutine in editor
            private void OnDestroy()
            {
                Debug.Log("[AnalyticsImporter] Coroutine runner destroyed");
            }
        }

        #endregion

        #region Utility Methods

        /// <summary>
        /// Get display name for a session
        /// </summary>
        public static string GetSessionDisplayName(SessionInfo session)
        {
            if (session == null)
                return "Invalid Session";

            string shortId = session.session_id.Length > 8 ? session.session_id.Substring(0, 8) + "..." : session.session_id;
            return $"{shortId} ({session.start_time}) - {session.duration_seconds}s";
        }

        /// <summary>
        /// Clear cached coroutine runner
        /// </summary>
        [UnityEditor.Callbacks.DidReloadScripts]
        private static void OnScriptsReloaded()
        {
            if (coroutineRunner != null)
            {
                Object.DestroyImmediate(coroutineRunner.gameObject);
                coroutineRunner = null;
            }
        }

        #endregion
    }
}
