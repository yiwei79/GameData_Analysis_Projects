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

        private AnalyticsVisualizationSettings settings;

        // Presentation presets
        private VisualizationPreset[] presets;
        private int selectedPresetIndex = -1;
        private string[] presetNames;

        // Quick access properties (delegates to settings)
        private bool showHeatmap
        {
            get => settings != null ? settings.showHeatmap : true;
            set { if (settings != null) settings.showHeatmap = value; }
        }

        private bool showPaths
        {
            get => settings != null ? settings.showPaths : false;
            set { if (settings != null) settings.showPaths = value; }
        }

        private bool showDeaths
        {
            get => settings != null ? settings.showDeaths : true;
            set { if (settings != null) settings.showDeaths = value; }
        }

        private bool showPickups
        {
            get => settings != null ? settings.showPickups : false;
            set { if (settings != null) settings.showPickups = value; }
        }

        private bool showCombat
        {
            get => settings != null ? settings.showCombat : false;
            set { if (settings != null) settings.showCombat = value; }
        }

        private float gridSize
        {
            get => settings != null ? settings.gridSize : 2.0f;
            set { if (settings != null) settings.gridSize = value; }
        }

        private Gradient heatmapGradient
        {
            get => settings != null ? settings.heatmapGradient : null;
            set { if (settings != null) settings.heatmapGradient = value; }
        }

        private bool showStatistics
        {
            get => settings != null ? settings.showStatistics : true;
            set { if (settings != null) settings.showStatistics = value; }
        }

        private bool autoRefreshSceneView
        {
            get => settings != null ? settings.autoRefreshSceneView : true;
            set { if (settings != null) settings.autoRefreshSceneView = value; }
        }

        [Header("Time Filter")]
        public float timeRangeMin = 0f;
        public float timeRangeMax = 1f;

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

            // Load persistent settings
            settings = AnalyticsVisualizationSettings.Instance;

            // Load presets
            LoadPresets();

            RefreshSessionList();
        }

        private void LoadPresets()
        {
            presets = VisualizationPreset.GetDefaultPresets();
            presetNames = new string[presets.Length + 1];
            presetNames[0] = "-- Select Preset --";
            for (int i = 0; i < presets.Length; i++)
            {
                presetNames[i + 1] = presets[i].presetName;
            }
            selectedPresetIndex = 0;
        }

        void OnDisable()
        {
            // Save settings when window closes
            if (settings != null)
            {
                settings.Save();
            }

            if (instance == this)
            {
                instance = null;
            }
        }

        #endregion

        #region GUI Drawing

        void OnGUI()
        {
            // Handle keyboard shortcuts
            HandleKeyboardShortcuts();

            InitializeStyles();

            scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);

            DrawHeader();
            EditorGUILayout.Space(10);

            DrawSessionControls();
            EditorGUILayout.Space(10);

            if (currentSession != null)
            {
                DrawPresetSelector();
                EditorGUILayout.Space(10);

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
                EditorGUILayout.Space(10);

                DrawKeyboardShortcutsHelp();
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

        void DrawPresetSelector()
        {
            EditorGUILayout.LabelField("📋 Presentation Presets", subHeaderStyle);

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.PrefixLabel("Quick Load:");

            int newPresetIndex = EditorGUILayout.Popup(selectedPresetIndex, presetNames);

            if (newPresetIndex != selectedPresetIndex && newPresetIndex > 0)
            {
                selectedPresetIndex = newPresetIndex;
                ApplyPreset(presets[newPresetIndex - 1]);
            }

            EditorGUILayout.EndHorizontal();

            // Show preset description if one is selected
            if (selectedPresetIndex > 0)
            {
                var preset = presets[selectedPresetIndex - 1];
                EditorGUILayout.HelpBox(preset.description, MessageType.Info);
            }
            else
            {
                EditorGUILayout.HelpBox(
                    "Select a preset to quickly configure visualization for specific analysis needs.\n\n" +
                    "Presets are ideal for presentations and demos!",
                    MessageType.Info
                );
            }

            EditorGUILayout.EndVertical();
        }

        void DrawVisualizationControls()
        {
            EditorGUILayout.LabelField("Visualization Layers", subHeaderStyle);

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            // Layer toggles with tooltips
            showHeatmap = EditorGUILayout.Toggle(
                new GUIContent("Show Heatmap (H)", "Toggle density heatmap visualization. Hotkey: H"),
                showHeatmap
            );
            if (showHeatmap)
            {
                EditorGUI.indentLevel++;
                gridSize = EditorGUILayout.Slider(
                    new GUIContent("Grid Size (m)", "Size of each grid cell in meters. Smaller = more detail"),
                    gridSize, 0.5f, 10f
                );
                heatmapGradient = EditorGUILayout.GradientField(
                    new GUIContent("Color Gradient", "Color mapping from low (blue) to high (red) density"),
                    heatmapGradient
                );
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.Space(5);

            showPaths = EditorGUILayout.Toggle(
                new GUIContent("Show Movement Paths (P)", "Toggle player movement trail visualization. Hotkey: P"),
                showPaths
            );
            showDeaths = EditorGUILayout.Toggle(
                new GUIContent("Show Death Markers (D)", "Toggle death event markers. Hotkey: D"),
                showDeaths
            );
            showPickups = EditorGUILayout.Toggle(
                new GUIContent("Show Pickup Markers (K)", "Toggle pickup event markers. Hotkey: K"),
                showPickups
            );
            showCombat = EditorGUILayout.Toggle(
                new GUIContent("Show Combat Events (C)", "Toggle combat event markers. Hotkey: C"),
                showCombat
            );

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

        void DrawKeyboardShortcutsHelp()
        {
            if (settings == null || !settings.enableKeyboardShortcuts)
                return;

            EditorGUILayout.BeginVertical(EditorStyles.helpBox);

            EditorGUILayout.LabelField("⌨️ Keyboard Shortcuts", EditorStyles.boldLabel);

            GUIStyle miniStyle = new GUIStyle(EditorStyles.miniLabel);
            miniStyle.richText = true;

            EditorGUILayout.LabelField("<b>H</b> - Toggle Heatmap", miniStyle);
            EditorGUILayout.LabelField("<b>P</b> - Toggle Paths", miniStyle);
            EditorGUILayout.LabelField("<b>D</b> - Toggle Deaths", miniStyle);
            EditorGUILayout.LabelField("<b>K</b> - Toggle Pickups", miniStyle);
            EditorGUILayout.LabelField("<b>C</b> - Toggle Combat", miniStyle);
            EditorGUILayout.LabelField("<b>A</b> - Apply Visualization", miniStyle);
            EditorGUILayout.LabelField("<b>X</b> - Clear Visualization", miniStyle);
            EditorGUILayout.LabelField("<b>R</b> - Reset Time Range", miniStyle);

            EditorGUILayout.EndVertical();
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

        void ApplyPreset(VisualizationPreset preset)
        {
            if (preset == null || currentSession == null)
                return;

            Debug.Log($"[AnalyticsWindow] Applying preset: {preset.presetName}");

            // Apply layer visibility
            showHeatmap = preset.showHeatmap;
            showPaths = preset.showPaths;
            showDeaths = preset.showDeaths;
            showPickups = preset.showPickups;
            showCombat = preset.showCombat;

            // Apply heatmap settings
            gridSize = preset.gridSize;

            // Apply time range (convert from percentage to actual time)
            if (currentSession != null && currentSession.info != null)
            {
                float totalDuration = currentSession.info.duration_seconds;
                timeRangeMin = preset.timeRangeMinPercent * totalDuration;
                timeRangeMax = preset.timeRangeMaxPercent * totalDuration;
            }

            // Auto-apply visualization
            ApplyVisualization();

            Repaint();
        }

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

            // Apply path visualization
            if (showPaths)
            {
                AnalyticsSceneViewOverlay.UpdatePaths(currentSession, timeRangeMin, timeRangeMax);
            }

            // Apply event markers
            if (showDeaths)
            {
                AnalyticsSceneViewOverlay.UpdateDeathMarkers(currentSession, timeRangeMin, timeRangeMax);
            }

            if (showPickups)
            {
                AnalyticsSceneViewOverlay.UpdatePickupMarkers(currentSession, timeRangeMin, timeRangeMax);
            }

            if (showCombat)
            {
                AnalyticsSceneViewOverlay.UpdateCombatMarkers(currentSession, timeRangeMin, timeRangeMax);
            }

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

        #region Keyboard Shortcuts

        /// <summary>
        /// Handle keyboard shortcut inputs
        /// </summary>
        private void HandleKeyboardShortcuts()
        {
            if (settings == null || !settings.enableKeyboardShortcuts)
                return;

            Event e = Event.current;
            if (e.type != EventType.KeyDown)
                return;

            bool settingsChanged = false;

            switch (e.keyCode)
            {
                case KeyCode.H:
                    showHeatmap = !showHeatmap;
                    settingsChanged = true;
                    Debug.Log($"[AnalyticsWindow] Heatmap toggled: {(showHeatmap ? "ON" : "OFF")}");
                    break;

                case KeyCode.P:
                    showPaths = !showPaths;
                    settingsChanged = true;
                    Debug.Log($"[AnalyticsWindow] Paths toggled: {(showPaths ? "ON" : "OFF")}");
                    break;

                case KeyCode.D:
                    showDeaths = !showDeaths;
                    settingsChanged = true;
                    Debug.Log($"[AnalyticsWindow] Death markers toggled: {(showDeaths ? "ON" : "OFF")}");
                    break;

                case KeyCode.K:
                    showPickups = !showPickups;
                    settingsChanged = true;
                    Debug.Log($"[AnalyticsWindow] Pickup markers toggled: {(showPickups ? "ON" : "OFF")}");
                    break;

                case KeyCode.C:
                    showCombat = !showCombat;
                    settingsChanged = true;
                    Debug.Log($"[AnalyticsWindow] Combat markers toggled: {(showCombat ? "ON" : "OFF")}");
                    break;

                case KeyCode.R:
                    // Reset time range
                    if (currentSession != null && currentSession.info != null)
                    {
                        timeRangeMin = 0f;
                        timeRangeMax = currentSession.info.duration_seconds;
                        settingsChanged = true;
                        Debug.Log("[AnalyticsWindow] Time range reset");
                    }
                    break;

                case KeyCode.A:
                    // Apply visualization
                    if (currentSession != null)
                    {
                        ApplyVisualization();
                        Debug.Log("[AnalyticsWindow] Visualization applied (hotkey: A)");
                    }
                    break;

                case KeyCode.X:
                    // Clear visualization
                    ClearVisualization();
                    Debug.Log("[AnalyticsWindow] Visualization cleared (hotkey: X)");
                    break;
            }

            if (settingsChanged)
            {
                e.Use(); // Consume the event
                Repaint(); // Refresh window
                if (currentSession != null)
                {
                    ApplyVisualization(); // Auto-apply on toggle
                }
            }
        }

        #endregion
    }
}
