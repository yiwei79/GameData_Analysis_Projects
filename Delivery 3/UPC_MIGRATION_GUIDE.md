# UPC Database Migration Guide

## ✅ What Has Been Updated

All files have been updated to use the UPC Database instead of localhost:

### Database Configuration
- **Host**: citmalumnes.upc.es
- **User**: yiweiy
- **Schema**: test
- **Table Prefix**: delivery3_ (to avoid conflicts)

### Files Modified
1. ✅ `Database/schema_upc.sql` - NEW schema with delivery3_ prefix
2. ✅ `Backend/config.php` - UPC credentials
3. ✅ `Backend/receive_analytics.php` - Updated table names
4. ✅ `Backend/get_sessions.php` - Updated table names
5. ✅ `Backend/get_session_data.php` - Updated table names
6. ✅ `Assets/Analytics/Scripts/Runtime/AnalyticsCollector.cs` - UPC endpoint URL
7. ✅ `Assets/Analytics/Scripts/Runtime/AnalyticsExporter.cs` - UPC endpoint URL
8. ✅ `Assets/Analytics/Scripts/Editor/AnalyticsDataImporter.cs` - UPC endpoint URLs

---

## 📋 Migration Steps (15 minutes)

### Step 1: Create Database Tables (5 minutes)

1. **Open MySQL Workbench**
2. **Connect to UPC Database**:
   - Host: `citmalumnes.upc.es`
   - Port: `3306`
   - Username: `yiweiy`
   - Password: `5DNmxr2aCxAr`
   - Schema: `test`

3. **Execute Schema**:
   - Open `Delivery 3/Database/schema_upc.sql`
   - Execute the entire file (Ctrl+Shift+Enter or ⌘+Shift+Enter)

4. **Verify Tables Created**:
   ```sql
   USE test;
   SHOW TABLES LIKE 'delivery3_%';
   ```

   You should see:
   - delivery3_sessions
   - delivery3_player_positions
   - delivery3_death_events
   - delivery3_pickup_events
   - delivery3_combat_events

---

### Step 2: Upload PHP Scripts to UPC Server (5 minutes)

1. **Open FileZilla** (or your preferred FTP client)

2. **Connect to UPC Server**:
   - Host: `citmalumnes.upc.es`
   - Protocol: SFTP
   - Username: `yiweiy`
   - Password: `5DNmxr2aCxAr`
   - Port: 22

3. **Navigate to your web directory**:
   - Should be something like: `/home/yiweiy/public_html/`

4. **Create `delivery3_backend` folder**:
   - Right-click → Create Directory → Name it `delivery3_backend`

5. **Upload ALL PHP files from `Delivery 3/Backend/`**:
   - config.php
   - receive_analytics.php
   - get_sessions.php
   - get_session_data.php
   - test_connection.php

6. **Set Permissions** (if needed):
   - Right-click each PHP file → File Permissions
   - Set to `644` (rw-r--r--)

7. **Verify Upload**:
   - Open browser and go to:
     `https://citmalumnes.upc.es/~yiweiy/delivery3_backend/test_connection.php`
   - You should see a JSON response with database connection status

---

### Step 3: Test Connection from Browser (2 minutes)

**Test the connection endpoint**:
```
https://citmalumnes.upc.es/~yiweiy/delivery3_backend/test_connection.php
```

**Expected Response**:
```json
{
  "success": true,
  "message": "Database connection successful",
  "database": "test",
  "tables": [
    "delivery3_sessions",
    "delivery3_player_positions",
    "delivery3_death_events",
    "delivery3_pickup_events",
    "delivery3_combat_events"
  ]
}
```

**If you see errors**:
- Check MySQL credentials in `config.php`
- Check file permissions (should be 644)
- Check UPC database is accessible

---

### Step 4: Test from Unity (3 minutes)

1. **Open Unity Project**:
   - Open `Delivery 3/Data_Visualization_proj/`

2. **Let Unity Recompile**:
   - Wait for scripts to compile (updated endpoint URLs)

3. **Test Connection**:
   - Open Analytics Dashboard: `Window > Game Analytics > Visualization Dashboard`
   - Click **"Test Connection"** button
   - Should see success dialog

4. **Test Data Export** (Optional):
   - Open `ExampleScene.unity`
   - Check `[Analytics]` GameObject in Hierarchy
   - Inspector should show UPC endpoint: `https://citmalumnes.upc.es/~yiweiy/...`
   - Press Play for 30 seconds
   - Check Console for success messages

5. **Verify Data in MySQL**:
   ```sql
   USE test;
   SELECT * FROM delivery3_sessions ORDER BY start_time DESC LIMIT 1;
   SELECT COUNT(*) FROM delivery3_player_positions;
   ```

---

## 🔧 Troubleshooting

### ❌ "Database connection failed"

**Causes**:
- Wrong credentials in `config.php`
- UPC MySQL not accessible from web server

**Fix**:
1. Double-check credentials in `config.php`
2. Test MySQL connection from terminal:
   ```bash
   mysql -h citmalumnes.upc.es -u yiweiy -p test
   ```

---

### ❌ "404 Not Found" on PHP files

**Causes**:
- Files not uploaded correctly
- Wrong folder path

**Fix**:
1. Verify folder structure on UPC server:
   ```
   /home/yiweiy/public_html/delivery3_backend/
   ├── config.php
   ├── receive_analytics.php
   ├── get_sessions.php
   ├── get_session_data.php
   └── test_connection.php
   ```

2. Check URL matches your username:
   `https://citmalumnes.upc.es/~yiweiy/delivery3_backend/...`

---

### ❌ Unity "Connection refused"

**Causes**:
- Firewall blocking HTTPS
- Wrong endpoint URL

**Fix**:
1. Check endpoint in Inspector (`[Analytics]` GameObject):
   - Should be: `https://citmalumnes.upc.es/~yiweiy/delivery3_backend/receive_analytics.php`

2. Test endpoint in browser first (should show "Method not allowed" for GET)

---

### ❌ "Foreign key constraint fails"

**Causes**:
- Tables created in wrong order
- session_id doesn't exist when inserting positions/events

**Fix**:
1. Drop all delivery3_ tables:
   ```sql
   DROP TABLE IF EXISTS delivery3_combat_events;
   DROP TABLE IF EXISTS delivery3_pickup_events;
   DROP TABLE IF EXISTS delivery3_death_events;
   DROP TABLE IF EXISTS delivery3_player_positions;
   DROP TABLE IF EXISTS delivery3_sessions;
   ```

2. Re-run `schema_upc.sql` (creates tables in correct order)

---

## ✅ Verification Checklist

Before presenting, verify:

- [ ] All 5 delivery3_ tables exist in UPC `test` schema
- [ ] PHP files uploaded to UPC server
- [ ] `test_connection.php` returns success in browser
- [ ] Unity "Test Connection" button works
- [ ] Can play game and see data exported (check Console)
- [ ] Can load session in Analytics Dashboard
- [ ] Visualization renders in Scene View

---

## 📊 Table Structure Reference

### delivery3_sessions
```sql
id, session_id (VARCHAR 36), start_time, end_time, duration_seconds
```

### delivery3_player_positions
```sql
id, session_id, position_x, position_y, position_z, speed, timestamp
```

### delivery3_death_events
```sql
id, session_id, entity_type, position_x, position_y, position_z, cause, timestamp
```

### delivery3_pickup_events
```sql
id, session_id, item_name, position_x, position_y, position_z, timestamp
```

### delivery3_combat_events
```sql
id, session_id, attacker, target, damage_amount, position_x, position_y, position_z, timestamp
```

---

## 🔄 Rollback (if needed)

If you need to go back to localhost:

1. **Revert config.php**:
   ```php
   define('DB_HOST', '127.0.0.1');
   define('DB_USER', 'root');
   define('DB_PASS', '456210');
   define('DB_NAME', 'delivery3_analytics');
   ```

2. **Revert Unity endpoints** back to:
   `http://localhost:8888/delivery3_backend/...`

3. **Use original schema.sql** (without delivery3_ prefix)

---

## 🎯 Next Steps After Migration

1. ✅ Generate demo data (5-10 minute play session)
2. ✅ Test all visualization presets
3. ✅ Prepare presentation
4. ✅ Submit!

**Migration complete! You're now using production UPC database!** 🎉
