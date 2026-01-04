using System;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Data structures for analytics system
/// These classes are serializable for JSON export to PHP backend
/// </summary>

namespace GameAnalytics
{
    /// <summary>
    /// Single position sample from player movement
    /// Collected at regular intervals (default 0.5s)
    /// </summary>
    [Serializable]
    public class PositionSample
    {
        public float x;
        public float y;
        public float z;
        public float speed;         // Velocity magnitude
        public float timestamp;     // Seconds since session start

        public PositionSample(Vector3 position, float playerSpeed, float time)
        {
            x = position.x;
            y = position.y;
            z = position.z;
            speed = playerSpeed;
            timestamp = time;
        }
    }

    /// <summary>
    /// Death event for player or enemy
    /// </summary>
    [Serializable]
    public class DeathEventData
    {
        public string session_id;
        public string entity_type;  // "Player", "Chomper", "Spitter", etc.
        public float x;
        public float y;
        public float z;
        public string cause;         // Damage source
        public float timestamp;

        public DeathEventData(string sessionId, string entityType, Vector3 position, string deathCause, float time)
        {
            session_id = sessionId;
            entity_type = entityType;
            x = position.x;
            y = position.y;
            z = position.z;
            cause = deathCause ?? "Unknown";
            timestamp = time;
        }
    }

    /// <summary>
    /// Item pickup event
    /// </summary>
    [Serializable]
    public class PickupEventData
    {
        public string session_id;
        public string item_name;
        public float x;
        public float y;
        public float z;
        public float timestamp;

        public PickupEventData(string sessionId, string itemName, Vector3 position, float time)
        {
            session_id = sessionId;
            item_name = itemName;
            x = position.x;
            y = position.y;
            z = position.z;
            timestamp = time;
        }
    }

    /// <summary>
    /// Combat damage event
    /// </summary>
    [Serializable]
    public class CombatEventData
    {
        public string session_id;
        public string attacker;
        public string target;
        public float damage_amount;
        public float x;
        public float y;
        public float z;
        public float timestamp;

        public CombatEventData(string sessionId, string attackerName, string targetName, float damage, Vector3 position, float time)
        {
            session_id = sessionId;
            attacker = attackerName;
            target = targetName;
            damage_amount = damage;
            x = position.x;
            y = position.y;
            z = position.z;
            timestamp = time;
        }
    }

    /// <summary>
    /// Wrapper for JSON payloads sent to PHP
    /// </summary>
    [Serializable]
    public class AnalyticsPayload
    {
        public string event_type;   // "session_start", "session_end", "positions_batch", "death", "pickup", "combat"
    }

    /// <summary>
    /// Session start payload
    /// </summary>
    [Serializable]
    public class SessionStartPayload : AnalyticsPayload
    {
        public string session_id;
        public string start_time;   // MySQL datetime format: "YYYY-MM-DD HH:MM:SS"

        public SessionStartPayload(string sessionId)
        {
            event_type = "session_start";
            session_id = sessionId;
            start_time = System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        }
    }

    /// <summary>
    /// Session end payload
    /// </summary>
    [Serializable]
    public class SessionEndPayload : AnalyticsPayload
    {
        public string session_id;
        public string end_time;
        public int duration_seconds;

        public SessionEndPayload(string sessionId, float durationInSeconds)
        {
            event_type = "session_end";
            session_id = sessionId;
            end_time = System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            duration_seconds = Mathf.RoundToInt(durationInSeconds);
        }
    }

    /// <summary>
    /// Batch position payload (multiple samples at once)
    /// </summary>
    [Serializable]
    public class PositionsBatchPayload : AnalyticsPayload
    {
        public string session_id;
        public List<PositionSample> positions;

        public PositionsBatchPayload(string sessionId, List<PositionSample> positionSamples)
        {
            event_type = "positions_batch";
            session_id = sessionId;
            positions = new List<PositionSample>(positionSamples);
        }
    }

    /// <summary>
    /// Death event payload (with nested data object)
    /// </summary>
    [Serializable]
    public class DeathPayload : AnalyticsPayload
    {
        public DeathEventData data;

        public DeathPayload(DeathEventData deathData)
        {
            event_type = "death";
            data = deathData;
        }
    }

    /// <summary>
    /// Pickup event payload
    /// </summary>
    [Serializable]
    public class PickupPayload : AnalyticsPayload
    {
        public PickupEventData data;

        public PickupPayload(PickupEventData pickupData)
        {
            event_type = "pickup";
            data = pickupData;
        }
    }

    /// <summary>
    /// Combat event payload
    /// </summary>
    [Serializable]
    public class CombatPayload : AnalyticsPayload
    {
        public CombatEventData data;

        public CombatPayload(CombatEventData combatData)
        {
            event_type = "combat";
            data = combatData;
        }
    }
}
