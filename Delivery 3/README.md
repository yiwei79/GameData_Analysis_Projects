# Delivery 3: In-Editor Analytics Visualization System

**Student**: Yiwei Yu
**Course**: Game Data Analysis
**Unity Project**: `Data_Visualization_proj/`

---

## Quick Start

### Opening the Visualization Tool

1. Open Unity project: `Delivery 3/Data_Visualization_proj/`
2. Wait for Unity to compile scripts
3. Open the Analytics Dashboard: **`Window > Game Analytics > Visualization Dashboard`**
4. Click **"Test Connection"** to verify backend connectivity

### Generating Demo Data

1. Open `ExampleScene.unity` (already configured)
2. Press **Play**
3. Play for 2-5 minutes (explore, die, collect items)
4. Data automatically exports to MySQL in real-time
5. Exit Play mode

### Viewing Visualizations

1. In Analytics Dashboard, select a session from dropdown
2. Click **"Load Session"**
3. Choose a preset (e.g., "Death Hotspots")
4. **Switch to Scene View** to see visualizations

---

## System Overview

This project implements a complete analytics pipeline for Unity's 3D Game Kit Lite:

**Data Pipeline**: Unity Runtime → PHP Backend → MySQL Database → Unity Editor Visualization

### Backend (MySQL + PHP)

- **Database**: UPC Server (`citmalumnes.upc.es`)
- **Schema**: `yiweiy`
- **Tables**: 5 normalized tables with `delivery3_` prefix
  - `delivery3_sessions` - Gameplay sessions
  - `delivery3_player_positions` - Movement tracking (2 Hz sampling)
  - `delivery3_death_events` - Player/enemy deaths
  - `delivery3_pickup_events` - Item collection
  - `delivery3_combat_events` - Damage tracking

- **PHP Endpoints**: Hosted at `https://citmalumnes.upc.es/~yiweiy/delivery3_backend/`
  - `receive_analytics.php` - Real-time data ingestion
  - `get_sessions.php` - Session list retrieval
  - `get_session_data.php` - Full session data export

### Visualization Features

**Interactive Scene View Overlays**:
- **Heatmap** - 3D grid-based density visualization (blue = low, red = high)
- **Movement Paths** - Player trajectory with direction arrows
- **Death Markers** - Red/orange pillars showing death locations with labels
- **Pickup Markers** - Green cubes for item collection events
- **Combat Markers** - Yellow rings for damage events

**Customization Controls**:
- Grid size adjustment (0.5m - 10m)
- Time range filtering (analyze specific gameplay segments)
- Event type toggles (deaths, pickups, combat)
- Color palette customization
- Layer visibility controls

**Presentation Presets**:
1. **Death Hotspots** - Difficulty spike analysis
2. **Exploration Patterns** - Movement heatmap + paths
3. **Combat Analysis** - Combat + death correlation
4. **First 2 Minutes** - Onboarding effectiveness
5. **Complete Overview** - All layers enabled

**Keyboard Shortcuts**:
- `H` - Toggle Heatmap
- `P` - Toggle Paths
- `D` - Toggle Deaths
- `K` - Toggle Pickups
- `C` - Toggle Combat
- `A` - Apply/Refresh Visualization
- `X` - Clear All
- `R` - Reset Time Range

---

## Technical Highlights

**Non-Intrusive Design**: Zero modifications to 3D Game Kit source code. Analytics collected via event subscription pattern.

**Real-Time Export**: Position samples batched (20 at a time) and sent asynchronously during gameplay. Fire-and-forget pattern ensures no performance impact.

**Scalable Architecture**: Normalized MySQL schema with foreign keys, indexes, and CASCADE DELETE. Tested with 1000+ position samples per session.

**Editor Integration**: Custom EditorWindow, SceneView hooks, persistent settings via ScriptableObject, coroutine-based async HTTP requests.

---

## Grading Alignment

**Gather & Store (30%)**:
- ✅ MySQL + PHP backend (mandatory requirement)
- ✅ Normalized database with proper indexing
- ✅ Non-intrusive, modular, well-documented code

**Analytics & Visualization (50%)**:
- ✅ Import/export pipeline working end-to-end
- ✅ Interactive visualizations with customization
- ✅ Multiple data layers (5 event types)
- ✅ Time filtering and event filtering

**Reporting & Presentation (20%)**:
- ✅ Preset configurations for quick demos
- ✅ Professional UI with keyboard shortcuts
- ✅ Clear visual insights (death clusters, exploration patterns)

---

## Files Structure

```
Delivery 3/
├── Data_Visualization_proj/          # Unity project (OPEN THIS)
│   └── Assets/Analytics/              # Custom analytics system
├── Backend/                           # PHP scripts (uploaded to UPC)
│   ├── config.php
│   ├── receive_analytics.php
│   ├── get_sessions.php
│   └── get_session_data.php
├── Database/
│   └── schema_upc.sql                 # Database schema
└── README.md                          # This file
```

---

## Troubleshooting

**"Connection Failed" Error**:
- Verify PHP files uploaded to UPC server
- Check `config.php` has correct credentials (schema: `yiweiy`)
- Test endpoint: `https://citmalumnes.upc.es/~yiweiy/delivery3_backend/test_connection.php`

**Visualizations Not Appearing**:
- Ensure you're in **Scene View** (not Game View)
- Click "Apply Visualization" button
- Check session has data (positions count > 0)
- Verify time range filter includes data

**No Sessions in Dropdown**:
- Generate demo data by playing the game
- Click "Refresh Sessions" button
- Check MySQL tables have data: `SELECT * FROM delivery3_sessions;`
