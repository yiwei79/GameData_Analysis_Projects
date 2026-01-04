using System;
using System.Collections.Generic;
using UnityEngine;

namespace GameAnalytics.Editor
{
    /// <summary>
    /// Data models for importing analytics data from MySQL into Unity Editor
    /// These mirror the runtime structures but are optimized for editor use
    /// </summary>

    /// <summary>
    /// Session information from database
    /// </summary>
    [Serializable]
    public class SessionInfo
    {
        public string session_id;
        public string start_time;
        public string end_time;
        public int duration_seconds;

        public override string ToString()
        {
            return $"{session_id.Substring(0, 8)}... ({start_time}) - {duration_seconds}s";
        }
    }

    /// <summary>
    /// Response from get_sessions.php
    /// </summary>
    [Serializable]
    public class SessionListResponse
    {
        public bool success;
        public int count;
        public List<SessionInfo> sessions;
    }

    /// <summary>
    /// Complete session data loaded from database
    /// </summary>
    [Serializable]
    public class SessionData
    {
        public string session_id;
        public SessionInfo info;
        public List<PositionSampleData> positions;
        public List<DeathEventData> deaths;
        public List<PickupEventData> pickups;
        public List<CombatEventData> combat;
        public SessionStats stats;

        // Cached for performance
        [NonSerialized]
        public Vector3[] positionArray;
        [NonSerialized]
        public Vector3[] deathPositionArray;

        /// <summary>
        /// Convert positions list to array for faster rendering
        /// </summary>
        public void CacheArrays()
        {
            if (positions != null && positions.Count > 0)
            {
                positionArray = new Vector3[positions.Count];
                for (int i = 0; i < positions.Count; i++)
                {
                    positionArray[i] = new Vector3(positions[i].x, positions[i].y, positions[i].z);
                }
            }

            if (deaths != null && deaths.Count > 0)
            {
                deathPositionArray = new Vector3[deaths.Count];
                for (int i = 0; i < deaths.Count; i++)
                {
                    deathPositionArray[i] = new Vector3(deaths[i].x, deaths[i].y, deaths[i].z);
                }
            }
        }
    }

    /// <summary>
    /// Position sample from database (matches PHP response)
    /// </summary>
    [Serializable]
    public class PositionSampleData
    {
        public float x;
        public float y;
        public float z;
        public float speed;
        public float timestamp;

        public Vector3 ToVector3()
        {
            return new Vector3(x, y, z);
        }
    }

    /// <summary>
    /// Death event from database (matches PHP response)
    /// </summary>
    [Serializable]
    public class DeathEventData
    {
        public string entity_type;  // "Player", "Chomper", etc.
        public float x;
        public float y;
        public float z;
        public string cause;         // What killed the entity
        public float timestamp;

        public Vector3 ToVector3()
        {
            return new Vector3(x, y, z);
        }
    }

    /// <summary>
    /// Pickup event from database (matches PHP response)
    /// </summary>
    [Serializable]
    public class PickupEventData
    {
        public string item_name;
        public float x;
        public float y;
        public float z;
        public float timestamp;

        public Vector3 ToVector3()
        {
            return new Vector3(x, y, z);
        }
    }

    /// <summary>
    /// Combat event from database (matches PHP response)
    /// </summary>
    [Serializable]
    public class CombatEventData
    {
        public string attacker;
        public string target;
        public float damage_amount;
        public float x;
        public float y;
        public float z;
        public float timestamp;

        public Vector3 ToVector3()
        {
            return new Vector3(x, y, z);
        }
    }

    /// <summary>
    /// Session statistics
    /// </summary>
    [Serializable]
    public class SessionStats
    {
        public int total_positions;
        public int total_deaths;
        public int total_pickups;
        public int total_combat;
    }

    /// <summary>
    /// Complete response from get_session_data.php
    /// </summary>
    [Serializable]
    public class SessionDataResponse
    {
        public bool success;
        public string session_id;
        public SessionInfo info;
        public List<PositionSampleData> positions;
        public List<DeathEventData> deaths;
        public List<PickupEventData> pickups;
        public List<CombatEventData> combat;
        public SessionStats stats;

        /// <summary>
        /// Convert response to SessionData object
        /// </summary>
        public SessionData ToSessionData()
        {
            var sessionData = new SessionData
            {
                session_id = session_id,
                info = info,
                positions = positions ?? new List<PositionSampleData>(),
                deaths = deaths ?? new List<DeathEventData>(),
                pickups = pickups ?? new List<PickupEventData>(),
                combat = combat ?? new List<CombatEventData>(),
                stats = stats ?? new SessionStats()
            };

            sessionData.CacheArrays();
            return sessionData;
        }
    }
}
