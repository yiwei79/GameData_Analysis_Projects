using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;
using GameAnalytics.Editor;

namespace GameAnalytics.Editor
{
    /// <summary>
    /// Renders event markers for deaths, pickups, and combat
    /// Uses distinct visual styles for each event type
    /// </summary>
    public class EventMarkerRenderer
    {
        #region Event Data

        private List<DeathEventData> deathMarkers = new List<DeathEventData>();
        private List<PickupEventData> pickupMarkers = new List<PickupEventData>();
        private List<CombatEventData> combatMarkers = new List<CombatEventData>();

        #endregion

        #region Colors

        private Color playerDeathColor = new Color(1f, 0f, 0f, 0.9f);      // Red
        private Color enemyDeathColor = new Color(1f, 0.5f, 0f, 0.8f);     // Orange
        private Color pickupColor = new Color(0f, 1f, 0f, 0.8f);           // Green
        private Color combatColor = new Color(1f, 1f, 0f, 0.7f);           // Yellow

        #endregion

        #region Public API - Death Markers

        /// <summary>
        /// Set death markers to display
        /// </summary>
        public void SetDeathMarkers(List<DeathEventData> deaths, float timeMin, float timeMax)
        {
            deathMarkers.Clear();

            if (deaths == null || deaths.Count == 0)
                return;

            // Filter by time range
            deathMarkers = deaths
                .Where(d => d.timestamp >= timeMin && d.timestamp <= timeMax)
                .ToList();

            Debug.Log($"[EventMarkerRenderer] Loaded {deathMarkers.Count} death markers");
        }

        /// <summary>
        /// Draw death markers in scene
        /// </summary>
        public void DrawDeathMarkers()
        {
            if (deathMarkers.Count == 0)
                return;

            foreach (var death in deathMarkers)
            {
                Vector3 position = new Vector3(death.x, death.y, death.z);
                bool isPlayer = death.entity_type.Equals("Player", System.StringComparison.OrdinalIgnoreCase) ||
                               death.entity_type.Equals("Ellen", System.StringComparison.OrdinalIgnoreCase);

                Color markerColor = isPlayer ? playerDeathColor : enemyDeathColor;

                // Draw skull icon (sphere with cross)
                DrawDeathMarker(position, markerColor, death.entity_type, death.cause);
            }
        }

        #endregion

        #region Public API - Pickup Markers

        /// <summary>
        /// Set pickup markers to display
        /// </summary>
        public void SetPickupMarkers(List<PickupEventData> pickups, float timeMin, float timeMax)
        {
            pickupMarkers.Clear();

            if (pickups == null || pickups.Count == 0)
                return;

            // Filter by time range
            pickupMarkers = pickups
                .Where(p => p.timestamp >= timeMin && p.timestamp <= timeMax)
                .ToList();

            Debug.Log($"[EventMarkerRenderer] Loaded {pickupMarkers.Count} pickup markers");
        }

        /// <summary>
        /// Draw pickup markers in scene
        /// </summary>
        public void DrawPickupMarkers()
        {
            if (pickupMarkers.Count == 0)
                return;

            foreach (var pickup in pickupMarkers)
            {
                Vector3 position = new Vector3(pickup.x, pickup.y, pickup.z);
                DrawPickupMarker(position, pickup.item_name);
            }
        }

        #endregion

        #region Public API - Combat Markers

        /// <summary>
        /// Set combat markers to display
        /// </summary>
        public void SetCombatMarkers(List<CombatEventData> combatEvents, float timeMin, float timeMax)
        {
            combatMarkers.Clear();

            if (combatEvents == null || combatEvents.Count == 0)
                return;

            // Filter by time range
            combatMarkers = combatEvents
                .Where(c => c.timestamp >= timeMin && c.timestamp <= timeMax)
                .ToList();

            Debug.Log($"[EventMarkerRenderer] Loaded {combatMarkers.Count} combat markers");
        }

        /// <summary>
        /// Draw combat markers in scene
        /// </summary>
        public void DrawCombatMarkers()
        {
            if (combatMarkers.Count == 0)
                return;

            foreach (var combat in combatMarkers)
            {
                Vector3 position = new Vector3(combat.x, combat.y, combat.z);
                DrawCombatMarker(position, combat.attacker, combat.target, combat.damage_amount);
            }
        }

        #endregion

        #region Public API - General

        /// <summary>
        /// Clear all event markers
        /// </summary>
        public void Clear()
        {
            deathMarkers.Clear();
            pickupMarkers.Clear();
            combatMarkers.Clear();
        }

        /// <summary>
        /// Get event statistics
        /// </summary>
        public (int deaths, int pickups, int combatEvents) GetStats()
        {
            return (deathMarkers.Count, pickupMarkers.Count, combatMarkers.Count);
        }

        #endregion

        #region Rendering Methods - Deaths

        /// <summary>
        /// Draw a death marker with label
        /// </summary>
        private void DrawDeathMarker(Vector3 position, Color color, string entityType, string cause)
        {
            // Draw solid disc at ground level
            Handles.color = color;
            Handles.DrawSolidDisc(position, Vector3.up, 0.4f);

            // Draw vertical line (death pillar)
            Handles.color = new Color(color.r, color.g, color.b, 0.6f);
            Handles.DrawLine(position, position + Vector3.up * 2f);

            // Draw sphere at top
            Handles.color = color;
            Handles.SphereHandleCap(0, position + Vector3.up * 2f, Quaternion.identity, 0.3f, EventType.Repaint);

            // Label with entity type and cause
            string labelText = $"☠ {entityType}";
            if (!string.IsNullOrEmpty(cause) && !cause.Equals("Unknown", System.StringComparison.OrdinalIgnoreCase))
            {
                labelText += $"\n({cause})";
            }

            Handles.Label(position + Vector3.up * 2.5f, labelText,
                new GUIStyle(EditorStyles.whiteBoldLabel)
                {
                    alignment = TextAnchor.MiddleCenter,
                    fontSize = 10,
                    normal = new GUIStyleState { textColor = color }
                });
        }

        #endregion

        #region Rendering Methods - Pickups

        /// <summary>
        /// Draw a pickup marker (cube with label)
        /// </summary>
        private void DrawPickupMarker(Vector3 position, string itemName)
        {
            // Draw wire cube
            Handles.color = pickupColor;
            Handles.DrawWireCube(position + Vector3.up * 0.5f, Vector3.one * 0.5f);

            // Draw solid disc at base
            Handles.DrawSolidDisc(position, Vector3.up, 0.3f);

            // Label with item name
            Handles.Label(position + Vector3.up * 1.2f, $"📦 {itemName}",
                new GUIStyle(EditorStyles.whiteBoldLabel)
                {
                    alignment = TextAnchor.MiddleCenter,
                    fontSize = 10,
                    normal = new GUIStyleState { textColor = pickupColor }
                });
        }

        #endregion

        #region Rendering Methods - Combat

        /// <summary>
        /// Draw a combat marker (ring with damage amount)
        /// </summary>
        private void DrawCombatMarker(Vector3 position, string attacker, string target, float damage)
        {
            // Draw expanding rings (impact effect)
            Handles.color = combatColor;
            Handles.DrawWireDisc(position, Vector3.up, 0.3f);
            Handles.color = new Color(combatColor.r, combatColor.g, combatColor.b, 0.5f);
            Handles.DrawWireDisc(position, Vector3.up, 0.5f);
            Handles.color = new Color(combatColor.r, combatColor.g, combatColor.b, 0.3f);
            Handles.DrawWireDisc(position, Vector3.up, 0.7f);

            // Draw small sphere at center
            Handles.color = combatColor;
            Handles.SphereHandleCap(0, position + Vector3.up * 0.1f, Quaternion.identity, 0.15f, EventType.Repaint);

            // Label with attacker -> target and damage
            string labelText = $"⚔ {attacker} → {target}\n{damage:F0} dmg";

            Handles.Label(position + Vector3.up * 0.8f, labelText,
                new GUIStyle(EditorStyles.whiteBoldLabel)
                {
                    alignment = TextAnchor.MiddleCenter,
                    fontSize = 9,
                    normal = new GUIStyleState { textColor = combatColor }
                });
        }

        #endregion

        #region Configuration

        /// <summary>
        /// Set custom colors for event types
        /// </summary>
        public void SetColors(Color playerDeath, Color enemyDeath, Color pickup, Color combat)
        {
            playerDeathColor = playerDeath;
            enemyDeathColor = enemyDeath;
            pickupColor = pickup;
            combatColor = combat;
        }

        #endregion
    }
}
