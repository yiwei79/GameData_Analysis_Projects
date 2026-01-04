using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using GameAnalytics.Editor;

namespace GameAnalytics.Editor
{
    /// <summary>
    /// Renders 3D spatial heatmap based on player position density
    /// Uses grid-based discretization for performance
    /// </summary>
    public class HeatmapRenderer
    {
        #region Grid Data

        /// <summary>
        /// Grid cell data structure storing density count
        /// </summary>
        private class GridCell
        {
            public Vector3Int gridPosition;
            public Vector3 worldPosition;
            public int sampleCount;
            public float normalizedDensity; // 0-1 range for coloring

            public GridCell(Vector3Int gridPos, Vector3 worldPos)
            {
                gridPosition = gridPos;
                worldPosition = worldPos;
                sampleCount = 0;
                normalizedDensity = 0f;
            }
        }

        private Dictionary<Vector3Int, GridCell> gridCells = new Dictionary<Vector3Int, GridCell>();
        private float cellSize = 2.0f;
        private int maxDensity = 1;
        private Gradient colorGradient;

        #endregion

        #region Public API

        /// <summary>
        /// Build heatmap from position samples
        /// </summary>
        /// <param name="positions">Player position samples</param>
        /// <param name="gridSize">Size of each grid cell in meters</param>
        /// <param name="timeMin">Minimum timestamp filter</param>
        /// <param name="timeMax">Maximum timestamp filter</param>
        /// <param name="gradient">Color gradient for density visualization</param>
        public void BuildHeatmap(List<PositionSampleData> positions, float gridSize, float timeMin, float timeMax, Gradient gradient = null)
        {
            if (positions == null || positions.Count == 0)
            {
                Debug.LogWarning("[HeatmapRenderer] No position data to visualize");
                Clear();
                return;
            }

            cellSize = Mathf.Max(0.1f, gridSize); // Minimum 0.1m cells
            colorGradient = gradient ?? GetDefaultGradient();
            gridCells.Clear();
            maxDensity = 1;

            // Phase 1: Discretize positions into grid cells
            int filteredCount = 0;
            foreach (var pos in positions)
            {
                // Time filter
                if (pos.timestamp < timeMin || pos.timestamp > timeMax)
                    continue;

                filteredCount++;

                Vector3 worldPos = new Vector3(pos.x, pos.y, pos.z);
                Vector3Int gridPos = WorldToGrid(worldPos);

                // Get or create grid cell
                if (!gridCells.ContainsKey(gridPos))
                {
                    Vector3 cellWorldPos = GridToWorld(gridPos);
                    gridCells[gridPos] = new GridCell(gridPos, cellWorldPos);
                }

                // Increment density count
                gridCells[gridPos].sampleCount++;

                // Track maximum for normalization
                if (gridCells[gridPos].sampleCount > maxDensity)
                {
                    maxDensity = gridCells[gridPos].sampleCount;
                }
            }

            // Phase 2: Normalize densities to 0-1 range
            foreach (var cell in gridCells.Values)
            {
                cell.normalizedDensity = (float)cell.sampleCount / maxDensity;
            }

            Debug.Log($"[HeatmapRenderer] Built heatmap: {gridCells.Count} cells, {filteredCount} samples, max density: {maxDensity}");
        }

        /// <summary>
        /// Render heatmap in Scene View
        /// </summary>
        public void DrawInScene()
        {
            if (gridCells.Count == 0)
                return;

            Handles.BeginGUI();
            Handles.EndGUI();

            // Draw each grid cell as a colored disc
            foreach (var cell in gridCells.Values)
            {
                Color cellColor = colorGradient.Evaluate(cell.normalizedDensity);
                Handles.color = cellColor;

                // Draw solid disc at cell center
                Vector3 center = cell.worldPosition;
                float radius = cellSize * 0.45f; // Slightly smaller than cell to show gaps

                Handles.DrawSolidDisc(center, Vector3.up, radius);

                // Optional: Draw intensity number for high-density areas
                if (cell.normalizedDensity > 0.7f)
                {
                    Handles.Label(center + Vector3.up * 0.1f, cell.sampleCount.ToString(),
                        new GUIStyle(EditorStyles.whiteBoldLabel)
                        {
                            alignment = TextAnchor.MiddleCenter,
                            fontSize = 10
                        });
                }
            }
        }

        /// <summary>
        /// Clear all heatmap data
        /// </summary>
        public void Clear()
        {
            gridCells.Clear();
            maxDensity = 1;
        }

        /// <summary>
        /// Get heatmap statistics
        /// </summary>
        public (int cellCount, int maxDensity, float avgDensity) GetStats()
        {
            if (gridCells.Count == 0)
                return (0, 0, 0f);

            int totalSamples = 0;
            foreach (var cell in gridCells.Values)
            {
                totalSamples += cell.sampleCount;
            }

            float avgDensity = (float)totalSamples / gridCells.Count;

            return (gridCells.Count, maxDensity, avgDensity);
        }

        #endregion

        #region Grid Math

        /// <summary>
        /// Convert world position to grid coordinates
        /// </summary>
        private Vector3Int WorldToGrid(Vector3 worldPos)
        {
            return new Vector3Int(
                Mathf.FloorToInt(worldPos.x / cellSize),
                Mathf.FloorToInt(worldPos.y / cellSize),
                Mathf.FloorToInt(worldPos.z / cellSize)
            );
        }

        /// <summary>
        /// Convert grid coordinates to world position (cell center)
        /// </summary>
        private Vector3 GridToWorld(Vector3Int gridPos)
        {
            return new Vector3(
                gridPos.x * cellSize + cellSize * 0.5f,
                gridPos.y * cellSize + cellSize * 0.5f,
                gridPos.z * cellSize + cellSize * 0.5f
            );
        }

        #endregion

        #region Default Gradient

        /// <summary>
        /// Create default heatmap gradient (blue -> cyan -> green -> yellow -> red)
        /// </summary>
        private Gradient GetDefaultGradient()
        {
            Gradient gradient = new Gradient();

            GradientColorKey[] colorKeys = new GradientColorKey[5];
            colorKeys[0] = new GradientColorKey(new Color(0f, 0f, 1f), 0f);      // Blue (cold)
            colorKeys[1] = new GradientColorKey(new Color(0f, 1f, 1f), 0.25f);   // Cyan
            colorKeys[2] = new GradientColorKey(new Color(0f, 1f, 0f), 0.5f);    // Green
            colorKeys[3] = new GradientColorKey(new Color(1f, 1f, 0f), 0.75f);   // Yellow
            colorKeys[4] = new GradientColorKey(new Color(1f, 0f, 0f), 1f);      // Red (hot)

            GradientAlphaKey[] alphaKeys = new GradientAlphaKey[2];
            alphaKeys[0] = new GradientAlphaKey(0.6f, 0f);   // Low density semi-transparent
            alphaKeys[1] = new GradientAlphaKey(0.9f, 1f);   // High density more opaque

            gradient.SetKeys(colorKeys, alphaKeys);

            return gradient;
        }

        #endregion

        #region Debug Helpers

        /// <summary>
        /// Draw debug info overlay
        /// </summary>
        public void DrawDebugInfo(Rect position)
        {
            if (gridCells.Count == 0)
                return;

            var stats = GetStats();

            GUILayout.BeginArea(position);
            GUILayout.BeginVertical(EditorStyles.helpBox);

            GUILayout.Label("Heatmap Debug Info", EditorStyles.boldLabel);
            GUILayout.Label($"Grid Cells: {stats.cellCount}");
            GUILayout.Label($"Max Density: {stats.maxDensity} samples/cell");
            GUILayout.Label($"Avg Density: {stats.avgDensity:F1} samples/cell");
            GUILayout.Label($"Cell Size: {cellSize:F2}m");

            GUILayout.EndVertical();
            GUILayout.EndArea();
        }

        #endregion
    }
}
