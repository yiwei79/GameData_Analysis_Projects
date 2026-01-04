using UnityEngine;

namespace GameAnalytics.Editor
{
    /// <summary>
    /// Stores a saved visualization configuration preset
    /// Can be quickly loaded during presentations to show different analysis views
    /// </summary>
    [System.Serializable]
    public class VisualizationPreset
    {
        public string presetName = "New Preset";
        public string description = "";

        // Layer visibility
        public bool showHeatmap = true;
        public bool showPaths = false;
        public bool showDeaths = true;
        public bool showPickups = false;
        public bool showCombat = false;

        // Heatmap settings
        public float gridSize = 2.0f;

        // Note: Gradient can't be easily serialized, so we'll use a simple color scheme index
        public int colorScheme = 0; // 0=Default, 1=Hot, 2=Cool, 3=Monochrome

        // Filters
        public bool filterPlayerDeathsOnly = false;
        public bool filterEnemyDeathsOnly = false;

        // Time range (as percentages 0-1)
        public float timeRangeMinPercent = 0f;
        public float timeRangeMaxPercent = 1f;

        public VisualizationPreset()
        {
        }

        public VisualizationPreset(string name, string desc)
        {
            presetName = name;
            description = desc;
        }

        /// <summary>
        /// Copy settings from another preset
        /// </summary>
        public void CopyFrom(VisualizationPreset other)
        {
            presetName = other.presetName;
            description = other.description;
            showHeatmap = other.showHeatmap;
            showPaths = other.showPaths;
            showDeaths = other.showDeaths;
            showPickups = other.showPickups;
            showCombat = other.showCombat;
            gridSize = other.gridSize;
            colorScheme = other.colorScheme;
            filterPlayerDeathsOnly = other.filterPlayerDeathsOnly;
            filterEnemyDeathsOnly = other.filterEnemyDeathsOnly;
            timeRangeMinPercent = other.timeRangeMinPercent;
            timeRangeMaxPercent = other.timeRangeMaxPercent;
        }

        public override string ToString()
        {
            return $"{presetName}: {description}";
        }

        #region Built-in Presets

        /// <summary>
        /// Create default presentation presets
        /// </summary>
        public static VisualizationPreset[] GetDefaultPresets()
        {
            return new VisualizationPreset[]
            {
                CreateDeathHotspotsPreset(),
                CreateExplorationPatternsPreset(),
                CreateCombatAnalysisPreset(),
                CreateTimelineAnalysisPreset(),
                CreateOverviewPreset()
            };
        }

        private static VisualizationPreset CreateDeathHotspotsPreset()
        {
            var preset = new VisualizationPreset(
                "Death Hotspots",
                "Shows where players die most frequently - identifies difficulty spikes"
            );
            preset.showHeatmap = false;
            preset.showPaths = false;
            preset.showDeaths = true;
            preset.showPickups = false;
            preset.showCombat = false;
            preset.filterPlayerDeathsOnly = true;
            preset.timeRangeMinPercent = 0f;
            preset.timeRangeMaxPercent = 1f;
            return preset;
        }

        private static VisualizationPreset CreateExplorationPatternsPreset()
        {
            var preset = new VisualizationPreset(
                "Exploration Patterns",
                "Heatmap + paths showing how players navigate the level"
            );
            preset.showHeatmap = true;
            preset.showPaths = true;
            preset.showDeaths = false;
            preset.showPickups = false;
            preset.showCombat = false;
            preset.gridSize = 2.0f;
            preset.colorScheme = 0; // Default gradient
            preset.timeRangeMinPercent = 0f;
            preset.timeRangeMaxPercent = 1f;
            return preset;
        }

        private static VisualizationPreset CreateCombatAnalysisPreset()
        {
            var preset = new VisualizationPreset(
                "Combat Analysis",
                "Shows combat engagement zones and enemy deaths"
            );
            preset.showHeatmap = false;
            preset.showPaths = false;
            preset.showDeaths = true;
            preset.showPickups = false;
            preset.showCombat = true;
            preset.filterEnemyDeathsOnly = true;
            preset.timeRangeMinPercent = 0f;
            preset.timeRangeMaxPercent = 1f;
            return preset;
        }

        private static VisualizationPreset CreateTimelineAnalysisPreset()
        {
            var preset = new VisualizationPreset(
                "First 2 Minutes",
                "Focus on early-game behavior (tutorial/onboarding effectiveness)"
            );
            preset.showHeatmap = true;
            preset.showPaths = true;
            preset.showDeaths = true;
            preset.showPickups = false;
            preset.showCombat = false;
            preset.gridSize = 1.5f;
            preset.timeRangeMinPercent = 0f;
            preset.timeRangeMaxPercent = 0.1f; // First 10% of session
            return preset;
        }

        private static VisualizationPreset CreateOverviewPreset()
        {
            var preset = new VisualizationPreset(
                "Complete Overview",
                "All visualization layers enabled for comprehensive analysis"
            );
            preset.showHeatmap = true;
            preset.showPaths = true;
            preset.showDeaths = true;
            preset.showPickups = true;
            preset.showCombat = true;
            preset.gridSize = 3.0f; // Larger grid for less clutter
            preset.timeRangeMinPercent = 0f;
            preset.timeRangeMaxPercent = 1f;
            return preset;
        }

        #endregion
    }
}
