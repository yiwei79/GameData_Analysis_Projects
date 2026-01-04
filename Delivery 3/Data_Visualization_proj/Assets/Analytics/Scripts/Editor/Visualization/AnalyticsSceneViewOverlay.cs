using UnityEngine;
using UnityEditor;
using GameAnalytics.Editor;

namespace GameAnalytics.Editor
{
    /// <summary>
    /// Scene View overlay for analytics visualization
    /// Hooks into SceneView.duringSceneGui to render heatmaps, paths, and event markers
    /// </summary>
    [InitializeOnLoad]
    public static class AnalyticsSceneViewOverlay
    {
        #region Renderers

        private static HeatmapRenderer heatmapRenderer;
        private static PathRenderer pathRenderer;
        private static EventMarkerRenderer eventRenderer;
        private static bool isInitialized = false;

        #endregion

        #region Initialization

        /// <summary>
        /// Static constructor - automatically called when editor loads
        /// </summary>
        static AnalyticsSceneViewOverlay()
        {
            Initialize();
            SceneView.duringSceneGui += OnSceneGUI;
            Debug.Log("[AnalyticsSceneView] Overlay initialized and hooked to Scene View");
        }

        private static void Initialize()
        {
            if (isInitialized)
                return;

            heatmapRenderer = new HeatmapRenderer();
            pathRenderer = new PathRenderer();
            eventRenderer = new EventMarkerRenderer();

            isInitialized = true;
        }

        #endregion

        #region Scene View Hook

        /// <summary>
        /// Called during Scene View GUI rendering
        /// </summary>
        private static void OnSceneGUI(SceneView sceneView)
        {
            // Get the visualization window instance
            var window = AnalyticsVisualizationWindow.GetInstance();
            if (window == null)
                return; // Window not open, nothing to render

            // Get current session data
            var session = window.GetCurrentSession();
            if (session == null)
                return; // No session loaded

            // Get visibility settings
            var settings = window.GetVisibilitySettings();

            // Render heatmap if enabled
            if (settings.heatmap)
            {
                heatmapRenderer.DrawInScene();
            }

            // Render movement paths if enabled
            if (settings.paths)
            {
                pathRenderer.DrawInScene();
            }

            // Render event markers if enabled
            if (settings.deaths)
            {
                eventRenderer.DrawDeathMarkers();
            }

            if (settings.pickups)
            {
                eventRenderer.DrawPickupMarkers();
            }

            if (settings.combat)
            {
                eventRenderer.DrawCombatMarkers();
            }

            // Draw debug overlay (optional - can be toggled in window)
            DrawOverlayUI(sceneView);
        }

        #endregion

        #region Overlay UI

        /// <summary>
        /// Draw overlay UI in top-left corner of Scene View
        /// </summary>
        private static void DrawOverlayUI(SceneView sceneView)
        {
            var window = AnalyticsVisualizationWindow.GetInstance();
            if (window == null)
                return;

            Handles.BeginGUI();

            // Top-left corner info panel
            GUILayout.BeginArea(new Rect(10, 10, 250, 150));
            GUILayout.BeginVertical(EditorStyles.helpBox);

            GUILayout.Label("Analytics Visualization Active", EditorStyles.boldLabel);

            var session = window.GetCurrentSession();
            if (session != null)
            {
                GUILayout.Label($"Session: {session.session_id.Substring(0, 8)}...");
                GUILayout.Label($"Duration: {session.info.duration_seconds}s");

                var settings = window.GetVisibilitySettings();
                GUILayout.Space(5);
                GUILayout.Label("Active Layers:", EditorStyles.miniBoldLabel);

                if (settings.heatmap)
                {
                    var stats = heatmapRenderer.GetStats();
                    GUILayout.Label($"  • Heatmap ({stats.cellCount} cells)");
                }
                if (settings.paths) GUILayout.Label("  • Movement Paths");
                if (settings.deaths) GUILayout.Label("  • Death Markers");
                if (settings.pickups) GUILayout.Label("  • Pickup Markers");
                if (settings.combat) GUILayout.Label("  • Combat Events");
            }

            GUILayout.EndVertical();
            GUILayout.EndArea();

            Handles.EndGUI();
        }

        #endregion

        #region Public API (for Visualization Window)

        /// <summary>
        /// Update heatmap visualization (called from window)
        /// </summary>
        public static void UpdateHeatmap(SessionData session, float gridSize, float timeMin, float timeMax, Gradient gradient)
        {
            if (heatmapRenderer == null)
                Initialize();

            if (session == null || session.positions == null)
            {
                heatmapRenderer.Clear();
                return;
            }

            heatmapRenderer.BuildHeatmap(session.positions, gridSize, timeMin, timeMax, gradient);
            SceneView.RepaintAll();

            Debug.Log("[AnalyticsSceneView] Heatmap updated");
        }

        /// <summary>
        /// Update path visualization (called from window)
        /// </summary>
        public static void UpdatePaths(SessionData session, float timeMin, float timeMax)
        {
            if (pathRenderer == null)
                Initialize();

            if (session == null || session.positions == null)
            {
                pathRenderer.Clear();
                return;
            }

            pathRenderer.BuildPath(session.positions, timeMin, timeMax);
            SceneView.RepaintAll();

            Debug.Log("[AnalyticsSceneView] Path updated");
        }

        /// <summary>
        /// Update death markers (called from window)
        /// </summary>
        public static void UpdateDeathMarkers(SessionData session, float timeMin, float timeMax)
        {
            if (eventRenderer == null)
                Initialize();

            if (session == null || session.deaths == null)
            {
                eventRenderer.SetDeathMarkers(new List<DeathEventData>(), 0, 0);
                return;
            }

            eventRenderer.SetDeathMarkers(session.deaths, timeMin, timeMax);
            SceneView.RepaintAll();

            Debug.Log("[AnalyticsSceneView] Death markers updated");
        }

        /// <summary>
        /// Update pickup markers (called from window)
        /// </summary>
        public static void UpdatePickupMarkers(SessionData session, float timeMin, float timeMax)
        {
            if (eventRenderer == null)
                Initialize();

            if (session == null || session.pickups == null)
            {
                eventRenderer.SetPickupMarkers(new List<PickupEventData>(), 0, 0);
                return;
            }

            eventRenderer.SetPickupMarkers(session.pickups, timeMin, timeMax);
            SceneView.RepaintAll();

            Debug.Log("[AnalyticsSceneView] Pickup markers updated");
        }

        /// <summary>
        /// Update combat markers (called from window)
        /// </summary>
        public static void UpdateCombatMarkers(SessionData session, float timeMin, float timeMax)
        {
            if (eventRenderer == null)
                Initialize();

            if (session == null || session.combat == null)
            {
                eventRenderer.SetCombatMarkers(new List<CombatEventData>(), 0, 0);
                return;
            }

            eventRenderer.SetCombatMarkers(session.combat, timeMin, timeMax);
            SceneView.RepaintAll();

            Debug.Log("[AnalyticsSceneView] Combat markers updated");
        }

        /// <summary>
        /// Clear all visualizations
        /// </summary>
        public static void ClearAll()
        {
            if (heatmapRenderer != null)
                heatmapRenderer.Clear();

            if (pathRenderer != null)
                pathRenderer.Clear();

            if (eventRenderer != null)
                eventRenderer.Clear();

            SceneView.RepaintAll();

            Debug.Log("[AnalyticsSceneView] All visualizations cleared");
        }

        #endregion
    }
}
