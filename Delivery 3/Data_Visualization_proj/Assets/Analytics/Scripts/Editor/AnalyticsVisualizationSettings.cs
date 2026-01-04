using UnityEngine;
using UnityEditor;

namespace GameAnalytics.Editor
{
    /// <summary>
    /// Persistent settings for analytics visualization
    /// Saved as a ScriptableObject asset in the project
    /// </summary>
    public class AnalyticsVisualizationSettings : ScriptableObject
    {
        private static AnalyticsVisualizationSettings instance;

        #region Singleton

        public static AnalyticsVisualizationSettings Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = LoadOrCreateSettings();
                }
                return instance;
            }
        }

        private static AnalyticsVisualizationSettings LoadOrCreateSettings()
        {
            // Try to load existing settings
            string[] guids = AssetDatabase.FindAssets("t:AnalyticsVisualizationSettings");
            if (guids.Length > 0)
            {
                string path = AssetDatabase.GUIDToAssetPath(guids[0]);
                instance = AssetDatabase.LoadAssetAtPath<AnalyticsVisualizationSettings>(path);
                Debug.Log($"[AnalyticsSettings] Loaded settings from: {path}");
                return instance;
            }

            // Create new settings asset
            instance = CreateInstance<AnalyticsVisualizationSettings>();

            // Initialize with defaults
            instance.InitializeDefaults();

            // Save to Resources folder
            string resourcesPath = "Assets/Analytics/Resources";
            if (!AssetDatabase.IsValidFolder(resourcesPath))
            {
                AssetDatabase.CreateFolder("Assets/Analytics", "Resources");
            }

            string assetPath = $"{resourcesPath}/AnalyticsVisualizationSettings.asset";
            AssetDatabase.CreateAsset(instance, assetPath);
            AssetDatabase.SaveAssets();

            Debug.Log($"[AnalyticsSettings] Created new settings at: {assetPath}");
            return instance;
        }

        #endregion

        #region Visualization Settings

        [Header("Layer Visibility")]
        [Tooltip("Show heatmap density visualization")]
        public bool showHeatmap = true;

        [Tooltip("Show player movement paths")]
        public bool showPaths = false;

        [Tooltip("Show death event markers")]
        public bool showDeaths = true;

        [Tooltip("Show pickup event markers")]
        public bool showPickups = false;

        [Tooltip("Show combat event markers")]
        public bool showCombat = false;

        [Header("Heatmap Settings")]
        [Tooltip("Grid cell size in meters")]
        [Range(0.5f, 10f)]
        public float gridSize = 2.0f;

        [Tooltip("Color gradient for heatmap (blue=low, red=high)")]
        public Gradient heatmapGradient;

        [Header("Path Settings")]
        [Tooltip("Movement path line width")]
        [Range(1f, 10f)]
        public float pathWidth = 3f;

        [Tooltip("Show arrow every N points")]
        [Range(5, 50)]
        public int arrowInterval = 10;

        [Header("Filter Settings")]
        [Tooltip("Show only player deaths (not enemy deaths)")]
        public bool filterPlayerDeathsOnly = false;

        [Tooltip("Show only enemy deaths (not player deaths)")]
        public bool filterEnemyDeathsOnly = false;

        [Header("Display Settings")]
        [Tooltip("Show statistics panel in window")]
        public bool showStatistics = true;

        [Tooltip("Auto-refresh Scene View when settings change")]
        public bool autoRefreshSceneView = true;

        [Tooltip("Show debug overlay in Scene View")]
        public bool showDebugOverlay = true;

        [Header("Keyboard Shortcuts Enabled")]
        [Tooltip("Enable keyboard shortcuts (H=heatmap, P=paths, D=deaths, etc.)")]
        public bool enableKeyboardShortcuts = true;

        #endregion

        #region Methods

        private void InitializeDefaults()
        {
            showHeatmap = true;
            showPaths = false;
            showDeaths = true;
            showPickups = false;
            showCombat = false;

            gridSize = 2.0f;
            pathWidth = 3f;
            arrowInterval = 10;

            // Default gradient (blue -> cyan -> green -> yellow -> red)
            heatmapGradient = new Gradient();
            GradientColorKey[] colorKeys = new GradientColorKey[5];
            colorKeys[0] = new GradientColorKey(new Color(0f, 0f, 1f), 0f);      // Blue
            colorKeys[1] = new GradientColorKey(new Color(0f, 1f, 1f), 0.25f);   // Cyan
            colorKeys[2] = new GradientColorKey(new Color(0f, 1f, 0f), 0.5f);    // Green
            colorKeys[3] = new GradientColorKey(new Color(1f, 1f, 0f), 0.75f);   // Yellow
            colorKeys[4] = new GradientColorKey(new Color(1f, 0f, 0f), 1f);      // Red

            GradientAlphaKey[] alphaKeys = new GradientAlphaKey[2];
            alphaKeys[0] = new GradientAlphaKey(0.7f, 0f);
            alphaKeys[1] = new GradientAlphaKey(0.9f, 1f);

            heatmapGradient.SetKeys(colorKeys, alphaKeys);

            filterPlayerDeathsOnly = false;
            filterEnemyDeathsOnly = false;

            showStatistics = true;
            autoRefreshSceneView = true;
            showDebugOverlay = true;
            enableKeyboardShortcuts = true;
        }

        public void Save()
        {
            EditorUtility.SetDirty(this);
            AssetDatabase.SaveAssets();
            Debug.Log("[AnalyticsSettings] Settings saved");
        }

        public void ResetToDefaults()
        {
            InitializeDefaults();
            Save();
            Debug.Log("[AnalyticsSettings] Settings reset to defaults");
        }

        #endregion

        #region Menu Items

        [MenuItem("Window/Game Analytics/Open Settings")]
        public static void OpenSettings()
        {
            Selection.activeObject = Instance;
            EditorGUIUtility.PingObject(Instance);
        }

        [MenuItem("Window/Game Analytics/Reset Settings to Defaults")]
        public static void ResetSettings()
        {
            if (EditorUtility.DisplayDialog(
                "Reset Settings",
                "Are you sure you want to reset all visualization settings to defaults?",
                "Reset",
                "Cancel"))
            {
                Instance.ResetToDefaults();
            }
        }

        #endregion
    }
}
