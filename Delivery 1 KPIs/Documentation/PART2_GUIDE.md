# Part 2 Setup & Execution Guide

**Complete instructions for running KPI analysis**

---

## Prerequisites

✅ Part 1 completed (database populated with game data)  
✅ macOS computer (instructions are macOS-specific)  
✅ Database credentials from Part 1  

---

## Step 1: Install R and RStudio

### 1.1 Install R

1. Go to [https://cran.r-project.org/bin/macosx/](https://cran.r-project.org/bin/macosx/)
2. Download the latest R package for macOS (e.g., `R-4.3.2-arm64.pkg` for Apple Silicon or `R-4.3.2-x86_64.pkg` for Intel)
3. Open the downloaded `.pkg` file
4. Follow installation wizard (use default settings)
5. Verify installation:
   - Open Terminal
   - Type `R --version`
   - You should see R version information

### 1.2 Install RStudio (Recommended)

1. Go to [https://posit.co/download/rstudio-desktop/](https://posit.co/download/rstudio-desktop/)
2. Click "Download RStudio Desktop for Mac"
3. Open the downloaded `.dmg` file
4. Drag RStudio to Applications folder
5. Launch RStudio from Applications

**✅ Checkpoint**: You can open RStudio successfully

---

## Step 2: Install Required R Packages

### 2.1 Open RStudio

Launch RStudio from your Applications folder.

### 2.2 Install Packages

Copy and paste this command into the R console (bottom-left pane):

```r
install.packages(c("RMySQL", "ggplot2", "dplyr", "tidyr", "scales", "lubridate", "viridis", "RColorBrewer"))
```

Press **Enter** and wait for installation to complete.

**Note**: You may be asked to select a CRAN mirror. Choose any location close to you (e.g., "Spain" or "Europe").

**Troubleshooting**:
- If you see "Do you want to install from sources...?", type `n` and press Enter
- Installation may take 5-10 minutes
- Warnings are normal; errors are not

### 2.3 Install MySQL Client (if needed)

The RMySQL package requires MySQL client libraries. If you encounter errors:

**Option A: Install via Homebrew** (recommended)
```bash
# In Terminal
brew install mysql
```

**Option B: Install MySQL Workbench** (includes client libraries)
- Already installed from Part 1!

**✅ Checkpoint**: Run this in R console without errors:
```r
library(RMySQL)
```

---

## Step 3: Set Up Configuration

### 3.1 Navigate to Analysis Folder

In RStudio:
1. Go to **Session → Set Working Directory → Choose Directory**
2. Navigate to: `Delivery 1 KPIs/Analysis/`
3. Click "Open"

Or in Terminal:
```bash
cd "/Users/yiwei/.cursor/worktrees/Delivery1_Unity__Workspace_/BZacy/Delivery 1 KPIs/Analysis"
```

### 3.2 Create config.R from Template

In Terminal (within Analysis folder):
```bash
cp config.R.template config.R
```

Or manually:
1. Open `config.R.template` in a text editor
2. Copy all contents
3. Create new file `config.R`
4. Paste contents
5. Save in `Analysis/` folder

### 3.3 Edit config.R with Your Credentials

Open `config.R` in a text editor and update these lines:

```r
DB_CONFIG <- list(
  host = "localhost",                    # Keep as-is
  dbname = "YOUR_DATABASE_NAME",         # ← CHANGE THIS
  user = "YOUR_USERNAME",                # ← CHANGE THIS
  password = "YOUR_PASSWORD"             # ← CHANGE THIS
)
```

**Where to find these values:**
- Open SQL Workbench from Part 1
- Check your connection settings
- Use the SAME credentials that work in SQL Workbench

**Example:**
```r
DB_CONFIG <- list(
  host = "localhost",
  dbname = "bdii_project_db",
  user = "yiweiy",
  password = "mySecretPassword123"
)
```

**⚠️ IMPORTANT**: 
- `host` should remain `"localhost"` (not citmalumnes.upc.es)
- Database is on the same server as PHP, so localhost is correct
- Never commit `config.R` to git (it's in .gitignore)

**✅ Checkpoint**: Your `config.R` file exists with your actual credentials

---

## Step 4: Run Exploratory Analysis

### 4.1 Open Exploratory Script in RStudio

1. In RStudio, go to **File → Open File**
2. Navigate to `Analysis/exploratory_analysis.R`
3. Click "Open"

### 4.2 Run the Script

**Method A: Run entire script**
- Click "Source" button (top-right of script pane)

**Method B: Run line-by-line**
- Click at the beginning of the script
- Press `Cmd + Enter` repeatedly to execute each line

### 4.3 Review Diagnostic Output

Watch the console output carefully. You should see:

```
========================================
  EXPLORATORY DATA ANALYSIS
========================================

STEP 1: Loading configuration...
✓ Configuration loaded
✓ All required packages are installed

STEP 2: Loading packages...
✓ All packages loaded

STEP 3: Connecting to database...
Host: localhost
Database: your_database_name
User: your_username
✓ Successfully connected to database: your_database_name
✓ All required tables exist

STEP 4: Data quality checks...
📊 Table Record Counts:
----------------------------------------
  table_name row_count
1      users        98
2   sessions       745
3  purchases       123
4      items         5

📅 Date Range Coverage:
...
```

**What to Look For:**
- ✓ Green checkmarks indicate success
- ⚠️ Warnings should be reviewed
- ✗ Red X marks indicate problems

### 4.4 Check Output Files

Navigate to `Analysis/visualizations/` folder. You should see:
- `exploratory_country_distribution.png`
- `exploratory_dau_trend.png`

Open them to verify they look correct.

**✅ Checkpoint**: Exploratory script runs without errors, diagnostics look good

---

## Step 5: Run Main Analysis

### 5.1 Review Exploratory Results

Before running main analysis, review:
1. Console output from exploratory script
2. Preview visualizations
3. Data quality score (should be 4/5 or 5/5)

If data quality issues detected, fix them before proceeding.

### 5.2 Open Main Analysis Script

1. In RStudio: **File → Open File**
2. Navigate to `Analysis/analysis.R`
3. Click "Open"

### 5.3 Run Main Analysis

Click **"Source"** button to run entire script.

**Expected Runtime**: 2-5 minutes depending on data size

### 5.4 Monitor Progress

Watch console for section headers:
```
========================================
  User Engagement Metrics
========================================

📈 Calculating DAU...
  Executing: DAU... ✓ (365 rows)
  Mean DAU: 45.2
  95% CI: 45.20 [42.50, 47.90]

📅 Calculating MAU...
...
```

### 5.5 Review Output

After completion, check:

**Console Output:**
- KPI summary table with all metrics
- Confirmation of exports

**Files in `Analysis/visualizations/`:**
1. `01_dau_trend.png` - Daily active users over time
2. `02_mau_trend.png` - Monthly active users
3. `03_retention_curve.png` - D1/D3/D7 retention
4. `04_revenue_by_item.png` - Revenue breakdown by item
5. `05_session_duration_dist.png` - Session length histogram
6. `06_arpu_by_country.png` - ARPU by geographic location
7. `07_arpu_by_age.png` - ARPU by age group
8. `08_country_age_heatmap.png` - Cross-segment analysis

**CSV Files:**
- `kpi_summary.csv` - All KPI values with confidence intervals
- `country_analysis.csv` - Country-level metrics
- `age_analysis.csv` - Age-group metrics
- `cross_segment_analysis.csv` - Combined demographics

**✅ Checkpoint**: Main analysis complete, all visualizations generated

---

## Step 6: Interpret Results

### 6.1 Open kpi_summary.csv

In Excel or Numbers:
```bash
open Analysis/visualizations/kpi_summary.csv
```

You should see:
| Metric | Value |
|--------|-------|
| Mean DAU | 45.2 [42.5, 47.9] |
| Mean MAU | 78.5 [72.1, 84.9] |
| Stickiness Ratio | 57.6% |
| D1 Retention | 32.5% |
| D3 Retention | 45.8% |
| D7 Retention | 58.2% |
| ARPU | $3.45 |
| ARPPU | $12.30 |
| Conversion Rate | 28.1% |
| ... | ... |

(Values above are examples - yours will differ based on your data)

### 6.2 Review Visualizations

Open each PNG file and verify:
- ✅ Clear, readable labels
- ✅ Appropriate axis scales
- ✅ Data looks reasonable (no obvious errors)
- ✅ Professional appearance

### 6.3 Key Questions to Answer

Based on your results:
1. **Engagement**: What's your average DAU? Is it consistent or trending?
2. **Retention**: What % of users return after 1 week? Is this good?
3. **Monetization**: What's your ARPU? Which segment spends most?
4. **Sessions**: How long do users play? How many sessions?
5. **Demographics**: Which countries/ages are most valuable?

---

## Troubleshooting

### Issue: "Cannot connect to database"

**Solutions:**
1. Verify `config.R` credentials match SQL Workbench
2. Ensure database server is running
3. Test connection in SQL Workbench first
4. Check `host` is `"localhost"` not `"citmalumnes.upc.es"`

### Issue: "Package 'RMySQL' not found"

**Solutions:**
1. Install MySQL client libraries:
   ```bash
   brew install mysql
   ```
2. Restart RStudio
3. Re-install package:
   ```r
   install.packages("RMySQL")
   ```

### Issue: "Object not found" errors in script

**Solutions:**
1. Run scripts in order: `exploratory_analysis.R` → `analysis.R`
2. Don't run line-by-line unless you understand dependencies
3. Use "Source" button to run entire script

### Issue: "No data" warnings

**Solutions:**
1. Verify database has data (check SQL Workbench)
2. Run Unity simulator if database is empty
3. Check date range in SQL queries

### Issue: Visualizations don't generate

**Solutions:**
1. Check `Analysis/visualizations/` folder exists
2. Verify write permissions
3. Look for error messages in console
4. Ensure ggplot2 package is installed

### Issue: "Cannot open config.R.template"

**Solutions:**
1. Ensure you're in correct directory (`Analysis/`)
2. Check file exists: `ls config.R.template`
3. Set working directory in RStudio correctly

---

## Quick Reference

### File Locations
```
Delivery 1 KPIs/
├── Analysis/
│   ├── config.R              ← Your credentials (DO NOT SHARE)
│   ├── config.R.template     ← Template file
│   ├── utils.R               ← Helper functions
│   ├── exploratory_analysis.R ← Run this first
│   ├── analysis.R            ← Run this second
│   └── visualizations/       ← Output folder
├── Database/
│   └── kpi_queries.sql       ← SQL reference
└── Documentation/
    └── PART2_GUIDE.md        ← This file
```

### R Commands Cheat Sheet

```r
# Set working directory
setwd("/path/to/Analysis/")

# Check current directory
getwd()

# List files
list.files()

# Run script
source("exploratory_analysis.R")

# Install package
install.packages("packagename")

# Load package
library(packagename)

# View data frame
View(data_frame_name)

# Get help
?function_name
```

### Terminal Commands (macOS)

```bash
# Navigate to Analysis folder
cd "/Users/yiwei/.cursor/worktrees/Delivery1_Unity__Workspace_/BZacy/Delivery 1 KPIs/Analysis"

# Copy template
cp config.R.template config.R

# Edit file
open -e config.R

# List files
ls -la

# View visualizations
open visualizations/
```

---

## Next Steps

After successful analysis:

1. ✅ All scripts run without errors
2. ✅ Visualizations generated
3. ✅ KPI summary exported

**Then:**
1. Review all visualizations carefully
2. Note interesting findings
3. Prepare to discuss results
4. Consider generating presentation slides

---

## Getting Help

If you encounter issues:

1. **Check error messages carefully** - they usually tell you what's wrong
2. **Verify Part 1 is complete** - database must have data
3. **Review this guide** - follow steps in order
4. **Check file paths** - ensure you're in correct directory
5. **Test database connection** - use SQL Workbench first

**Common Mistakes:**
- ❌ Running `analysis.R` before `exploratory_analysis.R`
- ❌ Not updating `config.R` with actual credentials
- ❌ Using wrong host (should be `localhost`)
- ❌ Missing required packages
- ❌ Wrong working directory

**Good Practices:**
- ✅ Run exploratory script first
- ✅ Review diagnostics before main analysis
- ✅ Keep `config.R` secure (never commit to git)
- ✅ Save your work frequently
- ✅ Document interesting findings

---

**Good luck with your analysis!** 📊🎮

