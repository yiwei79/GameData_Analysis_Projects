# Manual Steps - What YOU Need to Do

All code has been generated! Now follow these steps to complete Part 1.

---

## ✅ STEP 1: Database Setup (15 minutes)

### 1.1 Open SQL Workbench
- You already have this connected to your UPC database

### 1.2 Execute Schema
1. Open the file: `Database/schema.sql`
2. Copy the entire contents
3. Paste into SQL Workbench
4. Execute the script
5. **Verify**: Run `SHOW TABLES;` - you should see 4 tables:
   - users
   - sessions
   - items
   - purchases

### 1.3 Verify Items
Run this query:
```sql
SELECT * FROM items;
```
You should see 5 items (Bronze, Silver, Gold, Platinum, Diamond packs).

**✅ Checkpoint**: 4 tables created, 5 items populated.

---

## ✅ STEP 2: Configure PHP Backend (10 minutes)

### 2.1 Update Database Credentials
1. Open file: `Backend/config.php`
2. Find these lines (lines 12-17):
   ```php
   define('DB_NAME', 'your_database_name');
   define('DB_USER', 'your_username');
   define('DB_PASS', 'your_password');
   ```
3. Replace with your **actual** database credentials:
   - `DB_NAME` → Your database name from SQL Workbench
   - `DB_USER` → Your database username
   - `DB_PASS` → Your database password
4. **IMPORTANT**: `DB_HOST` should stay as `'localhost'`

### 2.2 Upload PHP Files to UPC Server
You need to upload 2 files to `https://citmalumnes.upc.es/~yourUsername/`:

**Option A: Web File Manager**
1. Go to https://citmalumnes.upc.es/
2. Log in
3. Navigate to "File Manager" or "public_html"
4. Upload:
   - `Backend/config.php`
   - `Backend/receive_analytics.php`

**Option B: FileZilla (FTP)**
1. Open FileZilla
2. Connect:
   - Host: `ftp.citmalumnes.upc.es`
   - Username: Your UPC username
   - Password: Your UPC password
   - Port: 21
3. Navigate to `public_html` folder
4. Drag and drop the 2 PHP files

**Option C: Ask Your Instructor**
"How do I upload PHP files to my citmalumnes.upc.es account?"

**✅ Checkpoint**: Both PHP files are on the server.

---

## ✅ STEP 3: Test PHP Backend (10 minutes)

### 3.1 Test with Browser
1. Open browser
2. Go to: `https://citmalumnes.upc.es/~yourUsername/receive_analytics.php`
   - Replace `yourUsername` with your actual username
3. You should see a JSON error (this is expected):
   ```json
   {"success":false,"error":"Invalid JSON format"}
   ```
   This means PHP is working!

### 3.2 Test with curl (From Terminal)
Open Terminal on your Mac and run:

```bash
curl -X POST https://citmalumnes.upc.es/~yourUsername/receive_analytics.php \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "new_player",
    "username": "TestPlayer",
    "country": "Spain",
    "age": 25,
    "gender": 0.5,
    "registration_date": "2022-01-15 10:00:00"
  }'
```

**Expected Response**:
```json
{"success":true,"user_id":1,"message":"Player created successfully"}
```

### 3.3 Verify in Database
In SQL Workbench, run:
```sql
SELECT * FROM users;
```
You should see "TestPlayer" with user_id = 1.

**✅ Checkpoint**: PHP backend is working and inserting data into MySQL.

---

## ✅ STEP 4: Configure Unity (5 minutes)

### 4.1 Update Server URL
1. Open file: `Assets/_Scripts/AnalyticsManager.cs`
2. Find line 27:
   ```csharp
   [SerializeField] private string serverUrl = "https://citmalumnes.upc.es/~YOUR_USERNAME_HERE/receive_analytics.php";
   ```
3. Replace `YOUR_USERNAME_HERE` with your actual UPC username
4. Save the file

### 4.2 Verify Files Exist
Check that these files are in your Unity project:
- `Assets/_Scripts/Item.cs` ✓
- `Assets/_Scripts/AnalyticsManager.cs` ✓
- `Assets/_Scripts/Simulator.cs` ✓ (already existed - DON'T modify)

**✅ Checkpoint**: Server URL is correct.

---

## ✅ STEP 5: Add AnalyticsManager to Unity Scene (5 minutes)

### 5.1 Open Unity
1. Open Unity Editor
2. Open your scene (likely `SampleScene.unity`)

### 5.2 Create AnalyticsManager GameObject
1. In Hierarchy window: Right-click → Create Empty
2. Rename it to: `AnalyticsManager`
3. Select the AnalyticsManager GameObject
4. In Inspector: Click "Add Component"
5. Search for: `AnalyticsManager`
6. Click to add the script

### 5.3 Configure Inspector Settings
With AnalyticsManager selected, in the Inspector:
- **Server Url**: Should show your UPC URL (you updated this in Step 4.1)
- **Enable Logging**: ✓ Check this
- **Enable Detailed Logging**: ✓ Check this (for testing)

### 5.4 Save Scene
- File → Save Scene (or Ctrl+S / Cmd+S)

**✅ Checkpoint**: AnalyticsManager is in the scene and configured.

---

## ✅ STEP 6: Test Full Pipeline (10 minutes)

### 6.1 Clear Database (Fresh Start)
In SQL Workbench:
```sql
DELETE FROM purchases;
DELETE FROM sessions;
DELETE FROM users WHERE user_id > 1; -- Keep TestPlayer if you want
```

### 6.2 Run Unity Game
1. In Unity Editor: Press **Play** button
2. Watch the **Console** window

### 6.3 Monitor Console Logs
You should see cyan-colored messages:
```
[Analytics] AnalyticsManager enabled - Listening to Simulator events
[Analytics] [EVENT] New Player: <name> from <country>, age <age>
[Analytics] ✓ Player '<name>' created with DB ID: <id>
[Analytics] [EVENT] New Session at <time> (Simulator ID: <id>)
[Analytics] ✓ Session <id> started for user <id>
[Analytics] [EVENT] Purchase: Item <id> at <time>
[Analytics] ✓ Purchase recorded: Item <id> ($<amount>) - Purchase ID: <id>
...
```

**If you see errors**: Read the error messages carefully - they'll tell you what's wrong.

### 6.4 Verify Data in Database
While Unity is running (or after it finishes), check SQL Workbench:

```sql
-- Check user count
SELECT COUNT(*) FROM users;  -- Should be increasing

-- Check session count
SELECT COUNT(*) FROM sessions;  -- Should have many sessions

-- Check purchase count
SELECT COUNT(*) FROM purchases;  -- Should have some purchases

-- View sample data
SELECT
    u.username,
    u.country,
    COUNT(DISTINCT s.session_id) as session_count,
    COALESCE(SUM(p.amount), 0) as total_spent
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id
LEFT JOIN purchases p ON u.user_id = p.user_id
GROUP BY u.user_id
LIMIT 10;
```

**✅ Checkpoint**: Data is flowing from Unity → PHP → MySQL!

---

## ✅ STEP 7: Validate Data Quality (5 minutes)

Run these validation queries:

### 7.1 Check for Orphaned Sessions
```sql
SELECT COUNT(*) FROM sessions s
LEFT JOIN users u ON s.user_id = u.user_id
WHERE u.user_id IS NULL;
```
**Expected**: 0 (no orphaned sessions)

### 7.2 Check for Orphaned Purchases
```sql
SELECT COUNT(*) FROM purchases p
LEFT JOIN sessions s ON p.session_id = s.session_id
WHERE s.session_id IS NULL;
```
**Expected**: 0 (no orphaned purchases)

### 7.3 Check Session Durations
```sql
SELECT
    MIN(duration_seconds) as min_duration,
    AVG(duration_seconds) as avg_duration,
    MAX(duration_seconds) as max_duration
FROM sessions
WHERE duration_seconds IS NOT NULL;
```
**Expected**: Reasonable values (30-500 seconds based on Simulator)

**✅ Checkpoint**: All data relationships are correct!

---

## 🎉 PART 1 COMPLETE!

You now have a fully functional analytics pipeline:
- ✅ Database with normalized schema
- ✅ PHP backend receiving and storing events
- ✅ Unity collecting and transmitting data
- ✅ Data flowing correctly through the entire pipeline

---

## 📸 Take Screenshots for Your Submission

1. **SQL Workbench**: Tables with data
2. **Unity Console**: Analytics logs showing successful transmission
3. **Unity Inspector**: AnalyticsManager component configured
4. **SQL Query Results**: Sample data from the validation queries

---

## 🐛 Troubleshooting

### Issue: "HTTP Error: Cannot connect"
**Solution**:
- Verify serverUrl in Unity Inspector
- Check PHP files are uploaded
- Test PHP endpoint in browser

### Issue: "Database connection failed"
**Solution**:
- Check credentials in config.php
- Verify database name is correct
- Test with SQL Workbench

### Issue: No data in database
**Solution**:
- Check Unity Console for errors
- Verify PHP file has correct permissions
- Look at PHP error logs on server

### Issue: "Missing field: username"
**Solution**:
- JSON serialization issue
- Check AnalyticsManager.cs field names match PHP expectations

### Issue: Sessions have NULL user_id
**Solution**:
- ID mapping issue
- Enable Detailed Logging in Unity
- Check console logs for ID tracking

---

## 📋 Next Steps (Part 2)

After Part 1 is working, you'll move to Part 2:
1. Write SQL queries for KPIs (DAU, MAU, Retention, ARPU, ARPPU)
2. Export data to R
3. Calculate confidence intervals
4. Create visualizations
5. Prepare presentation

**But for now, focus on getting Part 1 working perfectly!**

---

## ❓ Questions?

Refer to:
- `IMPLEMENTATION_GUIDE.md` - Full detailed guide
- `CLAUDE.md` - Technical architecture reference
- Your instructor for server access issues

**Good luck!** 🚀
