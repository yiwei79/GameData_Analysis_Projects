using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using GameAnalytics.Editor;

namespace GameAnalytics.Editor
{
    /// <summary>
    /// Main editor window for analytics visualization controls
    /// Provides UI for session selection, visualization toggles, and settings
    /// </summary>
    public class AnalyticsVisualizationWindow : EditorWindow
    {
        #region Static Instance

        private static AnalyticsVisualizationWindow instance;

        /// <summary>
        /// Get the current window instance (for SceneView overlay)
        /// </summary>
        public static AnalyticsVisualizationWindow GetInstance()
        {
            return instance;
        }

        #endregion

        #region Session Data

        private SessionData currentSession;
        private List<SessionInfo> availableSessions = new List<SessionInfo>();
        private int selectedSessionIndex = 0;
        private bool isLoadingSession = false;

        #endregion

        #region Visualization Settings

        [Header("Layer Toggles")]
        public bool showHeatmap = true;
        public bool showPaths = false;
        public bool showDeaths = true;
        public bool showPickups = false;
        public bool showCombat = false;

        [Header("Heatmap Settings")]
        public float gridSize = 2.0f;
        public Gradient heatmapGradient;

        [Header("Time Filter")]
        public float timeRangeMin = 0f;
        public float timeRangeMax = 1f;

        [Header("Display Settings")]
        public bool showStatistics = true;
        public bool autoRefreshSceneView = true;

        #endregion

        #region UI State

        private Vector2 scrollPosition;
        private GUIStyle headerStyle;
        private GUIStyle subHeaderStyle;
        private bool stylesInitialized = false;

        #endregion

        #region Menu Item

        [MenuItem("Window/Game Analytics/Visualization Dashboard")]
        public static void ShowWindow()
        {
            var window = GetWindow<AnalyticsVisualizationWindow>("Analytics Dashboard");
            window.minSize = new Vector2(300, 500);
            instance = window;
        }

        #endregion

        #region Unity Lifecycle

        void OnEnable()
        {
            instance = this;

            // Initialize default gradient (blue -> green -> yellow -> red)
            if (heatmapGradient == null)
            {
                heatmapGradient = new Gradient();
                GradientColorKey[] colorKeys = new GradientColorKey[4];
                colorKeys[0] = new GradientColorKey(Color.blue, 0f);
                colorKeys[1] = new GradientColorKey(Color.cyan, 0.33f);
                colorKeys[2] = new GradientColorKey(Color.yellow, 0.66f);
                colorKeys[3] = new GradientColorKey(Color.red, 1f);

                GradientAlphaKey[] alphaKeys = new GradientAlphaKey[2];
                alphaKeys[0] = new GradientAlphaKey(0.7f, 0f);
                alphaKeys[1] = new GradientAlphaKey(0.9f, 1f);

                heatmapGradient.SetKeys(colorKeys, alphaKeys);
            }

            RefreshSessionList();
        }

        void OnDisable()
        {
            if (instance == this)
            {
                instance = null;
            }
        }

        #endregion

        #region GUI Drawing

        void OnGUI()
        {
            InitializeStyles();

            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);

            DrawHeader();
            EditorGUILayout.Space(10);

            DrawSessionControls();
            EditorGUILayout.Space(10);

            if (currentSession != null)
            {
                DrawVisualizationControls();
                EditorGUILayout.Space(10);

                DrawTimeRangeFilter();
                EditorGUILayout.Space(10);

                if (showStatistics)
                {
                    DrawStatistics();
                    EditorGUILayout.Space(10);
                }

                DrawActionButtons();
            }
            else
            {
                DrawNoSessionMessage();
            }

            EditorGUILayout.EndScrollView();

            // Auto-refresh scene view if settings changed
            if (GUI.changed && autoRefreshSceneView)
            {
                SceneView.RepaintAll();
            }
        }

        void InitializeStyles()
        {
            if (stylesInitialized) return;

            headerStyle = new GUIStyle(EditorStyles.boldLabel);
            headerStyle.fontSize = 16;
            headerStyle.alignment = TextAnchor.MiddleCenter;

            subHeaderStyle = new GUIStyle(EditorStyles.boldLabel);
            subHeaderStyle.fontSize = 12;

            stylesInitialized = true;
        }

        void DrawHeader()
        {
            EditorGUILayout.LabelField("Game Analytics Visualization", headerStyle);
            EditorGUILayout.LabelField("In-Editor Spatial Data Analysis", EditorStyles.centeredGreyMiniLabel);
        }

        void DrawSessionControls()
        {
            EditorGUILayout.LabelField("Session Management", subHeaderStyle);

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            // Session dropdown
            string[] sessionNames = GetSessionNames();
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("Select Session:");

            EditorGUI.BeginDisabledGroup(isLoadingSession);
            selectedSessionIndex = EditorGUILayout.Popup(selectedSessionIndex, sessionNames);
            EditorGUI.EndDisabledGroup();

            EditorGUILayout.EndHorizontal();

            // Action buttons
            EditorGUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();

            EditorGUI.BeginDisabledGroup(isLoadingSession || availableSessions.Count == 0);
            if (GUILayout.Button("Load Session", GUILayout.Width(100)))
            {
                LoadSelectedSession();
            }
            EditorGUI.EndDisabledGroup();

            if (GUILayout.Button("Refresh List", GUILayout.Width(100)))
            {
                RefreshSessionList();
            }

            EditorGUI.BeginDisabledGroup(isLoadingSession);
            if (GUILayout.Button("Test Connection", GUILayout.Width(120)))
            {
                TestBackendConnection();
            }
            EditorGUI.EndDisabledGroup();

            GUILayout.FlexibleSpace();
            EditorGUILayout.EndHorizontal();

            if (isLoadingSession)
            {
                EditorGUILayout.HelpBox("Loading session data...", MessageType.Info);
            }

            EditorGUILayout.EndVertical();
        }

        void DrawVisualizationControls()
        {
            EditorGUILayout.LabelField("Visualization Layers", subHeaderStyle);

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            // Layer toggles
            showHeatmap = EditorGUILayout.Toggle("Show Heatmap", showHeatmap);
            if (showHeatmap)
            {
                EditorGUI.indentLevel++;
                gridSize = EditorGUILayout.Slider("Grid Size (m)", gridSize, 0.5f, 10f);
                heatmapGradient = EditorGUILayout.GradientField("Color Gradient", heatmapGradient);
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.Space(5);

            showPaths = EditorGUILayout.Toggle("Show Movement Paths", showPaths);
            showDeaths = EditorGUILayout.Toggle("Show Death Markers", showDeaths);
            showPickups = EditorGUILayout.Toggle("Show Pickup Markers", showPickups);
            showCombat = EditorGUILayout.Toggle("Show Combat Events", showCombat);

            EditorGUILayout.EndVertical();
        }

        void DrawTimeRangeFilter()
        {
            EditorGUILayout.LabelField("Time Range Filter", subHeaderStyle);

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            if (currentSession != null && currentSession.info != null)
            {
                float maxTime = currentSession.info.duration_seconds;

                // MinMax slider
                EditorGUILayout.MinMaxSlider(
                    new GUIContent("Time Range (seconds)"),
                    ref timeRangeMin,
                    ref timeRangeMax,
                    0f,
                    maxTime
                );

                // Display values
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.LabelField($"From: {timeRangeMin:F1}s", GUILayout.Width(100));
                GUILayout.FlexibleSpace();
                EditorGUILayout.LabelField($"To: {timeRangeMax:F1}s", GUILayout.Width(100));
                EditorGUILayout.EndHorizontal();

                // Reset button
                if (GUILayout.Button("Reset Time Range"))
                {
                    timeRangeMin = 0f;
                    timeRangeMax = maxTime;
                }
            }
            else
            {
                EditorGUILayout.HelpBox("No session loaded", MessageType.Info);
            }

            EditorGUILayout.EndVertical();
        }

        void DrawStatistics()
        {
            EditorGUILayout.LabelField("Session Statistics", subHeaderStyle);

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            if (currentSession != null)
            {
                EditorGUILayout.LabelField("Session Info:", EditorStyles.boldLabel);
                EditorGUILayout.LabelField($"  Session ID: {currentSession.session_id.Substring(0, 8)}...");
                EditorGUILayout.LabelField($"  Start Time: {currentSession.info.start_time}");
                EditorGUILayout.LabelField($"  Duration: {currentSession.info.duration_seconds}s");

                EditorGUILayout.Space(5);

                EditorGUILayout.LabelField("Event Counts:", EditorStyles.boldLabel);
                EditorGUILayout.LabelField($"  Position Samples: {currentSession.positions?.Count ?? 0}");
                EditorGUILayout.LabelField($"  Death Events: {currentSession.deaths?.Count ?? 0}");
                EditorGUILayout.LabelField($"  Pickup Events: {currentSession.pickups?.Count ?? 0}");
                EditorGUILayout.LabelField($"  Combat Events: {currentSession.combat?.Count ?? 0}");

                // Calculate filtered counts
                if (currentSession.positions != null)
                {
                    int filteredPositions = CountFilteredPositions();
                    if (filteredPositions != currentSession.positions.Count)
                    {
                        EditorGUILayout.Space(5);
                        EditorGUILayout.LabelField("Filtered Data:", EditorStyles.boldLabel);
                        EditorGUILayout.LabelField($"  Visible Positions: {filteredPositions}");
                    }
                }
            }

            EditorGUILayout.EndVertical();
        }

        void DrawActionButtons()
        {
            EditorGUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();

            if (GUILayout.Button("Apply Visualization", GUILayout.Height(30), GUILayout.Width(150)))
            {
                ApplyVisualization();
            }

            if (GUILayout.Button("Clear Visualization", GUILayout.Height(30), GUILayout.Width(150)))
            {
                ClearVisualization();
            }

            GUILayout.FlexibleSpace();
            EditorGUILayout.EndHorizontal();
        }

        void DrawNoSessionMessage()
        {
            EditorGUILayout.Space(20);
            EditorGUILayout.HelpBox(
                "No session loaded.\n\n" +
                "1. Click 'Refresh List' to fetch available sessions\n" +
                "2. Select a session from the dropdown\n" +
                "3. Click 'Load Session' to visualize data",
                MessageType.Info
            );
        }

        #endregion

        #region Session Management

        void RefreshSessionList()
        {
            Debug.Log("[AnalyticsWindow] Refreshing session list...");

            AnalyticsDataImporter.FetchSessionList(sessions =>
            {
                availableSessions = sessions ?? new List<SessionInfo>();
                selectedSessionIndex = 0;

                Debug.Log($"[AnalyticsWindow] Fetched {availableSessions.Count} sessions");

                Repaint();
            });
        }

        void LoadSelectedSession()
        {
            if (selectedSessionIndex < 0 || selectedSessionIndex >= availableSessions.Count)
            {
                Debug.LogWarning("[AnalyticsWindow] Invalid session index");
                return;
            }

            string sessionId = availableSessions[selectedSessionIndex].session_id;
            Debug.Log($"[AnalyticsWindow] Loading session: {sessionId}");

            isLoadingSession = true;
            Repaint();

            AnalyticsDataImporter.LoadSessionData(sessionId, session =>
            {
                currentSession = session;
                isLoadingSession = false;

                if (session != null)
                {
                    // Reset time range to full session
                    timeRangeMin = 0f;
                    timeRangeMax = session.info.duration_seconds;

                    Debug.Log($"[AnalyticsWindow] Session loaded successfully:\n" +
                             $"  Positions: {session.positions?.Count ?? 0}\n" +
                             $"  Deaths: {session.deaths?.Count ?? 0}\n" +
                             $"  Pickups: {session.pickups?.Count ?? 0}");

                    // Auto-apply visualization
                    ApplyVisualization();
                }
                else
                {
                    Debug.LogError("[AnalyticsWindow] Failed to load session");
                }

                Repaint();
                SceneView.RepaintAll();
            });
        }

        void TestBackendConnection()
        {
            Debug.Log("[AnalyticsWindow] Testing backend connection...");

            AnalyticsDataImporter.TestConnection((success, message) =>
            {
                if (success)
                {
                    EditorUtility.DisplayDialog(
                        "Connection Success",
                        $"Backend connection successful!\n\n{message}",
                        "OK"
                    );
                }
                else
                {
                    EditorUtility.DisplayDialog(
                        "Connection Failed",
                        $"Failed to connect to backend:\n\n{message}",
                        "OK"
                    );
                }
            });
        }

        #endregion

        #region Visualization Control

        void ApplyVisualization()
        {
            if (currentSession == null)
            {
                Debug.LogWarning("[AnalyticsWindow] No session to visualize");
                return;
            }

            Debug.Log("[AnalyticsWindow] Applying visualization settings...");

            // Apply heatmap visualization
            if (showHeatmap)
            {
                AnalyticsSceneViewOverlay.UpdateHeatmap(
                    currentSession,
                    gridSize,
                    timeRangeMin,
                    timeRangeMax,
                    heatmapGradient
                );
            }
            else
            {
                // Clear heatmap if disabled
                AnalyticsSceneViewOverlay.ClearAll();
            }

            // TODO Phase 5: Call path and event renderers
            // if (showPaths) AnalyticsSceneViewOverlay.UpdatePaths(currentSession, timeRangeMin, timeRangeMax);
            // if (showDeaths) AnalyticsSceneViewOverlay.UpdateDeathMarkers(currentSession, timeRangeMin, timeRangeMax);

            SceneView.RepaintAll();
        }

        void ClearVisualization()
        {
            Debug.Log("[AnalyticsWindow] Clearing visualization...");

            AnalyticsSceneViewOverlay.ClearAll();

            SceneView.RepaintAll();
        }

        #endregion

        #region Helper Methods

        string[] GetSessionNames()
        {
            if (availableSessions == null || availableSessions.Count == 0)
            {
                return new[] { "No sessions available" };
            }

            string[] names = new string[availableSessions.Count];
            for (int i = 0; i < availableSessions.Count; i++)
            {
                var session = availableSessions[i];
                string shortId = session.session_id.Length > 8
                    ? session.session_id.Substring(0, 8) + "..."
                    : session.session_id;

                names[i] = $"{shortId} - {session.start_time} ({session.duration_seconds}s)";
            }

            return names;
        }

        int CountFilteredPositions()
        {
            if (currentSession == null || currentSession.positions == null)
                return 0;

            int count = 0;
            foreach (var pos in currentSession.positions)
            {
                if (pos.timestamp >= timeRangeMin && pos.timestamp <= timeRangeMax)
                {
                    count++;
                }
            }

            return count;
        }

        /// <summary>
        /// Get current session data (for SceneView overlay)
        /// </summary>
        public SessionData GetCurrentSession()
        {
            return currentSession;
        }

        /// <summary>
        /// Get current visualization settings (for renderers)
        /// </summary>
        public (bool heatmap, bool paths, bool deaths, bool pickups, bool combat) GetVisibilitySettings()
        {
            return (showHeatmap, showPaths, showDeaths, showPickups, showCombat);
        }

        #endregion
    }
}
