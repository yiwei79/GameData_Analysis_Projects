# Delivery 3 - Backend Setup Guide

## Overview

This backend provides PHP endpoints for the Unity Analytics Visualization System. It handles data export from Unity during gameplay and data import for editor visualization.

## Requirements

- **Web Server**: XAMPP (Windows) or MAMP (macOS)
- **PHP**: 7.4 or higher
- **MySQL**: 5.7 or higher
- **Extensions**: mysqli

## File Structure

```
Backend/
├── config.php                  # Database connection configuration
├── receive_analytics.php       # Main endpoint - receives analytics from Unity
├── get_sessions.php            # List all sessions
├── get_session_data.php        # Get complete session data
├── test_connection.php         # Test database connection
└── README.md                   # This file
```

## Setup Instructions

### 1. Install Web Server

**macOS (MAMP)**:
1. Download MAMP from https://www.mamp.info/
2. Install and launch MAMP
3. Start servers (Apache + MySQL)
4. Note the ports: Apache (8888), MySQL (8889 or 3306)

**Windows (XAMPP)**:
1. Download XAMPP from https://www.apachefriends.org/
2. Install and launch XAMPP Control Panel
3. Start Apache and MySQL modules
4. Default ports: Apache (80), MySQL (3306)

### 2. Copy PHP Files

Copy all files from this `Backend/` folder to your web server directory:

**MAMP (macOS)**:
```bash
cp -r /path/to/Delivery\ 3/Backend/* /Applications/MAMP/htdocs/delivery3_backend/
```

**XAMPP (Windows)**:
```
Copy to: C:\xampp\htdocs\delivery3_backend\
```

### 3. Configure Database Credentials

Edit `config.php` and update the database credentials:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');              // Your MySQL username
define('DB_PASS', '');                   // Your MySQL password
define('DB_NAME', 'delivery3_analytics');
define('DB_PORT', 3306);                 // 8889 for MAMP, 3306 for XAMPP
```

**Common Configurations**:
- **XAMPP**: User: `root`, Password: `` (empty), Port: `3306`
- **MAMP**: User: `root`, Password: `root`, Port: `8889` or `3306`

### 4. Create MySQL Database

1. Open **MySQL Workbench**
2. Connect to your localhost MySQL server
3. Execute the SQL script: `Database/schema.sql`

Or run these commands:
```sql
CREATE DATABASE delivery3_analytics CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE delivery3_analytics;
-- Then execute schema.sql
```

### 5. Test Connection

Open your browser and navigate to:
```
http://localhost/delivery3_backend/test_connection.php
```

**MAMP Users**: If using port 8888, use:
```
http://localhost:8888/delivery3_backend/test_connection.php
```

**Expected Response** (success):
```json
{
  "success": true,
  "message": "Database connected successfully",
  "server_info": "8.0.x",
  "database": "delivery3_analytics",
  "session_count": 0,
  "tables": [
    "sessions",
    "player_positions",
    "death_events",
    "pickup_events",
    "combat_events"
  ]
}
```

**If Connection Fails**:
- Verify MySQL is running (XAMPP/MAMP control panel)
- Check credentials in `config.php`
- Verify database `delivery3_analytics` exists
- Check port number (3306 vs 8889)

## API Endpoints

### 1. POST /receive_analytics.php
Receives analytics data from Unity during gameplay.

**Request**: JSON payload with `event_type` field

**Example - Session Start**:
```json
{
  "event_type": "session_start",
  "session_id": "abc-123-def-456",
  "start_time": "2026-01-04 10:30:00"
}
```

**Example - Position Batch**:
```json
{
  "event_type": "positions_batch",
  "session_id": "abc-123-def-456",
  "positions": [
    {"x": 10.5, "y": 0.0, "z": 5.2, "speed": 3.5, "timestamp": 0.5},
    {"x": 10.7, "y": 0.0, "z": 5.4, "speed": 3.2, "timestamp": 1.0}
  ]
}
```

**Example - Death Event**:
```json
{
  "event_type": "death",
  "data": {
    "session_id": "abc-123-def-456",
    "entity_type": "Player",
    "x": 25.3,
    "y": 1.0,
    "z": 12.7,
    "cause": "Chomper",
    "timestamp": 45.2
  }
}
```

### 2. GET /get_sessions.php
Returns list of all recorded sessions.

**Response**:
```json
{
  "success": true,
  "count": 5,
  "sessions": [
    {
      "session_id": "abc-123-def-456",
      "start_time": "2026-01-04 10:30:00",
      "end_time": "2026-01-04 10:35:23",
      "duration_seconds": 323
    }
  ]
}
```

### 3. GET /get_session_data.php?session_id={id}
Returns complete analytics data for a specific session.

**Example**:
```
http://localhost/delivery3_backend/get_session_data.php?session_id=abc-123-def-456
```

**Response**:
```json
{
  "success": true,
  "session_id": "abc-123-def-456",
  "info": {
    "session_id": "abc-123-def-456",
    "start_time": "2026-01-04 10:30:00",
    "end_time": "2026-01-04 10:35:23",
    "duration_seconds": 323
  },
  "positions": [...],
  "deaths": [...],
  "pickups": [...],
  "combat": [...],
  "stats": {
    "total_positions": 646,
    "total_deaths": 3,
    "total_pickups": 2,
    "total_combat": 15
  }
}
```

## Testing with curl

### Test Session Creation:
```bash
curl -X POST http://localhost/delivery3_backend/receive_analytics.php \
  -H "Content-Type: application/json" \
  -d '{"event_type":"session_start","session_id":"test-001","start_time":"2026-01-04 10:00:00"}'
```

### Test Session Retrieval:
```bash
curl http://localhost/delivery3_backend/get_sessions.php
```

### Verify in MySQL:
```sql
USE delivery3_analytics;
SELECT * FROM sessions ORDER BY start_time DESC LIMIT 5;
```

## Unity Integration

Update your Unity `AnalyticsExporter.cs` to point to the correct endpoint:

```csharp
private string endpoint = "http://localhost/delivery3_backend/receive_analytics.php";
// OR for MAMP on port 8888:
// private string endpoint = "http://localhost:8888/delivery3_backend/receive_analytics.php";
```

## Troubleshooting

### Error: "Database connection failed"
- **Cause**: MySQL not running or wrong credentials
- **Solution**:
  - Check XAMPP/MAMP control panel - MySQL must be running
  - Verify credentials in `config.php` match MySQL Workbench
  - Test connection in MySQL Workbench first

### Error: "Table doesn't exist"
- **Cause**: Schema not created
- **Solution**: Execute `Database/schema.sql` in MySQL Workbench

### Error: "Access denied for user"
- **Cause**: Wrong username/password
- **Solution**: Update `config.php` with correct credentials

### Error: "404 Not Found"
- **Cause**: PHP files not in correct directory
- **Solution**: Verify files are in `htdocs/delivery3_backend/`

### Error: "CORS policy blocked"
- **Cause**: Unity can't access localhost
- **Solution**: CORS headers already added in PHP files, should work

### Unity shows "Connection refused"
- **Cause**: Apache not running or wrong port
- **Solution**:
  - Verify Apache is running in XAMPP/MAMP
  - Check port in Unity matches server (80 or 8888)

## Security Notes

**For Production** (if deploying to real server):
1. Change MySQL password from default `root`
2. Use environment variables for credentials (not hardcoded)
3. Add rate limiting to prevent abuse
4. Restrict CORS to specific domains
5. Enable HTTPS

**For Development** (localhost):
- Current setup is fine for local testing
- CORS allows all origins (`*`) for Unity compatibility

## Maintenance

### View Error Logs:
```bash
# MAMP
tail -f /Applications/MAMP/logs/php_error.log

# XAMPP
tail -f C:\xampp\apache\logs\error.log
```

### Clear Old Sessions:
```sql
-- Delete sessions older than 30 days
DELETE FROM sessions WHERE start_time < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### Check Database Size:
```sql
SELECT
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'delivery3_analytics'
ORDER BY (data_length + index_length) DESC;
```

## Next Steps

After successful backend setup:
1. ✅ Test connection via browser
2. ✅ Verify all 5 tables exist in MySQL
3. ✅ Test with curl commands
4. → Proceed to Phase 2: Unity Data Collection
5. → Configure Unity to send data to this endpoint

## Support

If you encounter issues:
1. Check `error_log.txt` in Backend folder (created automatically)
2. Verify MySQL Workbench can connect with same credentials
3. Test each endpoint individually with curl
4. Check Apache/MySQL logs in XAMPP/MAMP
