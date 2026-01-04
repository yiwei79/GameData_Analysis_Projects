using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;
using GameAnalytics.Editor;

namespace GameAnalytics.Editor
{
    /// <summary>
    /// Renders player movement paths as continuous trails
    /// Shows direction with arrows and optionally colors by speed
    /// </summary>
    public class PathRenderer
    {
        #region Path Data

        private List<Vector3> pathPoints = new List<Vector3>();
        private List<float> pathTimestamps = new List<float>();
        private List<float> pathSpeeds = new List<float>();
        private bool hasData = false;

        // Rendering settings
        private Color pathColor = new Color(0f, 0.8f, 1f, 0.9f); // Cyan
        private float pathWidth = 3f;
        private int arrowInterval = 10; // Show arrow every N points

        #endregion

        #region Public API

        /// <summary>
        /// Build path from position samples
        /// </summary>
        public void BuildPath(List<PositionSampleData> positions, float timeMin, float timeMax, bool colorBySpeed = false)
        {
            if (positions == null || positions.Count == 0)
            {
                Debug.LogWarning("[PathRenderer] No position data to visualize");
                Clear();
                return;
            }

            pathPoints.Clear();
            pathTimestamps.Clear();
            pathSpeeds.Clear();

            // Filter and sort positions by timestamp
            var filteredPositions = positions
                .Where(p => p.timestamp >= timeMin && p.timestamp <= timeMax)
                .OrderBy(p => p.timestamp)
                .ToList();

            if (filteredPositions.Count < 2)
            {
                Debug.LogWarning("[PathRenderer] Not enough position data for path (need at least 2 points)");
                Clear();
                return;
            }

            // Convert to Vector3 arrays
            foreach (var pos in filteredPositions)
            {
                pathPoints.Add(new Vector3(pos.x, pos.y, pos.z));
                pathTimestamps.Add(pos.timestamp);
                pathSpeeds.Add(pos.speed);
            }

            hasData = true;

            Debug.Log($"[PathRenderer] Built path with {pathPoints.Count} points (time range: {timeMin:F1}s - {timeMax:F1}s)");
        }

        /// <summary>
        /// Render path in Scene View
        /// </summary>
        public void DrawInScene()
        {
            if (!hasData || pathPoints.Count < 2)
                return;

            // Draw main path line
            DrawPathLine();

            // Draw direction arrows
            DrawDirectionArrows();

            // Draw start/end markers
            DrawPathMarkers();
        }

        /// <summary>
        /// Clear path data
        /// </summary>
        public void Clear()
        {
            pathPoints.Clear();
            pathTimestamps.Clear();
            pathSpeeds.Clear();
            hasData = false;
        }

        /// <summary>
        /// Get path statistics
        /// </summary>
        public (int pointCount, float totalDistance, float avgSpeed) GetStats()
        {
            if (!hasData || pathPoints.Count < 2)
                return (0, 0f, 0f);

            float totalDistance = 0f;
            for (int i = 1; i < pathPoints.Count; i++)
            {
                totalDistance += Vector3.Distance(pathPoints[i - 1], pathPoints[i]);
            }

            float avgSpeed = pathSpeeds.Count > 0 ? pathSpeeds.Average() : 0f;

            return (pathPoints.Count, totalDistance, avgSpeed);
        }

        #endregion

        #region Rendering Methods

        /// <summary>
        /// Draw the main path line using anti-aliased polyline
        /// </summary>
        private void DrawPathLine()
        {
            Handles.color = pathColor;
            Handles.DrawAAPolyLine(pathWidth, pathPoints.ToArray());
        }

        /// <summary>
        /// Draw direction arrows along the path
        /// </summary>
        private void DrawDirectionArrows()
        {
            Handles.color = new Color(pathColor.r, pathColor.g, pathColor.b, 1f); // Fully opaque arrows

            for (int i = arrowInterval; i < pathPoints.Count; i += arrowInterval)
            {
                Vector3 currentPoint = pathPoints[i];
                Vector3 previousPoint = pathPoints[i - 1];

                // Calculate direction
                Vector3 direction = (currentPoint - previousPoint).normalized;

                if (direction.magnitude < 0.01f)
                    continue; // Skip if no movement

                // Draw arrow at current point
                Quaternion rotation = Quaternion.LookRotation(direction);
                float arrowSize = 0.5f;

                Handles.ArrowHandleCap(
                    0,
                    currentPoint,
                    rotation,
                    arrowSize,
                    EventType.Repaint
                );
            }
        }

        /// <summary>
        /// Draw start and end markers
        /// </summary>
        private void DrawPathMarkers()
        {
            if (pathPoints.Count < 2)
                return;

            // Start marker (green sphere)
            Handles.color = new Color(0f, 1f, 0f, 0.8f); // Green
            Vector3 startPoint = pathPoints[0];
            Handles.SphereHandleCap(0, startPoint, Quaternion.identity, 0.3f, EventType.Repaint);
            Handles.Label(startPoint + Vector3.up * 0.5f, "START",
                new GUIStyle(EditorStyles.whiteBoldLabel)
                {
                    alignment = TextAnchor.MiddleCenter,
                    fontSize = 12
                });

            // End marker (red sphere)
            Handles.color = new Color(1f, 0f, 0f, 0.8f); // Red
            Vector3 endPoint = pathPoints[pathPoints.Count - 1];
            Handles.SphereHandleCap(0, endPoint, Quaternion.identity, 0.3f, EventType.Repaint);
            Handles.Label(endPoint + Vector3.up * 0.5f, "END",
                new GUIStyle(EditorStyles.whiteBoldLabel)
                {
                    alignment = TextAnchor.MiddleCenter,
                    fontSize = 12
                });
        }

        #endregion

        #region Configuration

        /// <summary>
        /// Set path rendering color
        /// </summary>
        public void SetPathColor(Color color)
        {
            pathColor = color;
        }

        /// <summary>
        /// Set path line width
        /// </summary>
        public void SetPathWidth(float width)
        {
            pathWidth = Mathf.Max(1f, width);
        }

        /// <summary>
        /// Set arrow interval (show arrow every N points)
        /// </summary>
        public void SetArrowInterval(int interval)
        {
            arrowInterval = Mathf.Max(1, interval);
        }

        #endregion
    }
}
