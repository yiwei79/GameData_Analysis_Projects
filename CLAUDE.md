# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Game Analytics Pipeline** project for the course "Delivery 1 KPIs". The goal is to build a complete analytics system that tracks player behavior in a Unity game, sends data to a backend server, stores it in MySQL, and analyzes it using R for KPI extraction and statistical analysis.

**Pipeline Flow**: Unity Simulator → AnalyticsManager → PHP Backend → MySQL Database → SQL Queries → R Analysis

## Critical Constraints

### **NEVER MODIFY SIMULATOR.CS**
- The file `Delivery 1 KPIs/Delivery1_Simulator/Assets/_Scripts/Simulator.cs` is a **provided simulation engine** that generates synthetic player data
- It must remain completely untouched throughout the project
- All analytics work must be done by **subscribing to its events**, not modifying its code
- The Simulator generates ~100 players throughout the year 2022 with randomized behavior

### Simulator Event System
The Simulator exposes 4 static C# Action events that fire during simulation:

```csharp
// Fires when a new player is created
OnNewPlayer(string name, string country, int age, float gender, DateTime registrationDate)

// Fires when a player starts a gaming session (uint is internal player/session ID)
OnNewSession(DateTime startTime, uint simulatorId)

// Fires when a session ends (uint is internal identifier)
OnEndSession(DateTime endTime, uint simulatorId)

// Fires when a player buys an item (int itemId, DateTime purchaseDate, uint sessionId)
OnBuyItem(int itemId, DateTime purchaseDate, uint simulatorId)
```

**Important**: The `uint` parameters are Simulator's internal IDs and will NOT match database auto-increment IDs. You must maintain mapping dictionaries to translate between them.

## Project Structure

```
Delivery 1 KPIs/
├── Delivery1_Simulator/          # Unity project
│   └── Assets/_Scripts/
│       ├── Simulator.cs           # PROVIDED - DO NOT MODIFY
│       ├── AllCountries.cs        # Enum of 195+ countries
│       ├── Item.cs                # (To create) Item catalog data class
│       └── AnalyticsManager.cs    # (To create) Main analytics collection script
├── Backend/                       # (To create) PHP server-side code
│   ├── config.php                # Database credentials
│   └── receive_analytics.php     # API endpoint for Unity
├── Database/                      # (To create) SQL scripts
│   ├── schema.sql                # Table creation
│   └── kpi_queries.sql           # KPI extraction queries
└── Analysis/                      # (To create) R scripts
    └── analysis.R                # Statistical analysis & visualizations
```

## Architecture

### Data Model (MySQL)
The database must be **normalized, scalable, and indexed** per evaluation criteria (50% of grade):

**Core Tables**:
- `users` - Player demographics (username, country, age, gender, registration_date)
- `sessions` - Gameplay sessions (user_id FK, start_time, end_time, duration_seconds)
- `items` - Item catalog (item_id PK, item_name, price, category) - 5 pre-defined items
- `purchases` - In-game purchases (session_id FK, user_id FK, item_id FK, amount, purchase_date)

**Key Design Principles**:
- Use AUTO_INCREMENT for primary keys
- Index on: registration_date, start_time, purchase_date (for KPI queries)
- Composite index on (user_id, start_time) for retention calculations
- Denormalize `amount` in purchases (preserve historical pricing)

### Item Catalog
The Simulator's `GetItem()` method (line 118-131) returns items with these probabilities:
- Item 1: 50% chance - $0.99 (Bronze Pack)
- Item 2: 25% chance - $4.99 (Silver Pack)
- Item 3: 15% chance - $9.99 (Gold Pack)
- Item 4: 1% chance - $19.99 (Platinum Pack)
- Item 5: 9% chance - $49.99 (Diamond Pack)

### Unity Analytics Implementation
**AnalyticsManager.cs** must:
- Subscribe to Simulator events in `OnEnable()`, unsubscribe in `OnDisable()`
- Use **UnityWebRequest** with **coroutines** for async HTTP POST requests
- Send JSON payloads to PHP endpoint
- Maintain ID mappings: `Dictionary<string, int>` for player names to DB IDs, `Dictionary<uint, int>` for session mappings
- Be non-intrusive: use fire-and-forget async pattern to avoid blocking gameplay
- Format DateTime as `"yyyy-MM-dd HH:mm:ss"` for MySQL compatibility

**Critical Pattern**:
```csharp
IEnumerator SendData() {
    string jsonData = JsonUtility.ToJson(dataObject);
    UnityWebRequest request = UnityWebRequest.Post(serverUrl, "");
    byte[] bodyRaw = System.Text.Encoding.UTF8.GetBytes(jsonData);
    request.uploadHandler = new UploadHandlerRaw(bodyRaw);
    request.SetRequestHeader("Content-Type", "application/json");
    yield return request.SendWebRequest();
    // Handle response to get database IDs
}
```

### PHP Backend
**receive_analytics.php** must:
- Accept JSON via `file_get_contents('php://input')`
- Use **prepared statements** (mysqli or PDO) to prevent SQL injection
- Route events by `event_type` field (new_player, new_session, end_session, purchase)
- Return JSON responses with generated database IDs: `{"success": true, "user_id": 123}`
- Include CORS headers: `header('Access-Control-Allow-Origin: *')`

**Deployment**: Upload to UPC server at `https://citmalumnes.upc.es/~username/receive_analytics.php`

## Key Technical Challenges

### ID Mapping
The Simulator uses internal `uint` IDs that don't match database AUTO_INCREMENT IDs. Solutions:
- Store player names → DB user_id mappings when creating users
- Track current session_id per user
- The `uint` in `OnNewSession` and `OnEndSession` represents a player/session identifier, not a direct database ID

### Session Duration Calculation
- Simulator provides start_time in `OnNewSession` and end_time in `OnEndSession`
- Calculate duration in seconds: `(end_time - start_time).TotalSeconds`
- Store in `duration_seconds` column

### DateTime Handling
- Simulator generates dates throughout 2022 (see `GetNewPlayerDate()` line 137-149)
- Always format as `"yyyy-MM-dd HH:mm:ss"` when sending to PHP/MySQL
- SQL queries must handle date ranges for DAU/MAU calculations

## Development Workflow

### Database Setup
1. Use **SQL Workbench** connected to UPC database (already configured)
2. Execute schema.sql to create tables
3. Verify with: `SELECT * FROM information_schema.tables WHERE table_schema = 'your_db'`
4. Test manual inserts before connecting Unity

### Testing PHP Backend
Use **curl** from Terminal (macOS):
```bash
curl -X POST https://citmalumnes.upc.es/~username/receive_analytics.php \
  -H "Content-Type: application/json" \
  -d '{"event_type":"new_player","username":"TestUser",...}'
```

### Unity Testing
1. Clear database tables: `DELETE FROM purchases; DELETE FROM sessions; DELETE FROM users;`
2. Press Play in Unity Editor
3. Check Console for analytics logs (enable Debug mode)
4. Verify data in SQL Workbench: `SELECT COUNT(*) FROM users;`

### Debugging Strategy
- Enable detailed logging in AnalyticsManager (use `[SerializeField] bool enableDetailedLogging`)
- Add `error_log()` statements in PHP
- Check PHP error logs on server
- Use phpMyAdmin to manually inspect data integrity

## KPI Requirements (Part 2)

Must calculate with **SQL queries** and analyze in **R** with confidence intervals:

**User Metrics**:
- DAU (Daily Active Users): `COUNT(DISTINCT user_id) per day`
- MAU (Monthly Active Users): `COUNT(DISTINCT user_id) per month`

**Retention**:
- Stickiness: DAU/MAU ratio
- D1, D3, D7: % of users who return 1, 3, 7 days after registration

**Monetization**:
- ARPU (Average Revenue Per User): Total revenue / Total users
- ARPPU (Average Revenue Per Paying User): Total revenue / Paying users only

**Sessions**:
- Average session count per user
- Average session duration

**Analysis Requirements**:
- Segment by demographics (country, age, gender)
- Calculate 95% confidence intervals in R using `t.test()`
- Create visualizations (time series, bar charts, heatmaps)

## Evaluation Criteria

**Gather & Store (50%)**:
- Normalized database with proper indexes
- Non-intrusive async data transmission
- SOLID principles, modular, well-documented code

**Analytics (30%)**:
- Correct KPI calculations
- Efficient, reusable SQL queries
- Statistical rigor (confidence intervals, hypothesis testing)

**Reporting (20%)**:
- Clear visualizations
- Professional presentation
- Findings contextualized for business impact

## Important Notes

- **Server URL Pattern**: Always use `https://citmalumnes.upc.es/~username/filename.php`
- **Database Connection**: Host is `localhost` when PHP and MySQL are on same UPC server
- **Unity Platform**: Project is Unity 2020.x (check ProjectSettings/ProjectVersion.txt)
- **Name Generation**: Uses Lexic asset for random name generation (third-party asset, leave untouched)
- **Country List**: AllCountries.cs enum has 195+ countries, Simulator randomly selects 1-10 of them per run
- **Timeline**: 2-week project (Week 1: Backend, Week 2: Unity + Integration)

## Common Pitfalls to Avoid

1. **Don't modify Simulator.cs** - cannot stress this enough
2. **Don't use synchronous HTTP** - will freeze Unity gameplay
3. **Don't forget CORS headers** in PHP - Unity requests will fail
4. **Don't skip prepared statements** - SQL injection vulnerability
5. **Don't assume Simulator IDs match DB IDs** - maintain mappings
6. **Don't use `DateTime.Now` in Unity** - use Simulator's provided timestamps
7. **Don't create unindexed foreign keys** - queries will be slow at scale
