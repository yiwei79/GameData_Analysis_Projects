<!-- 25262bd2-32d8-4bfb-8b29-06506a081222 13006efc-0606-4999-84de-39915c6366bc -->
# Part 2: KPI Analysis & Reporting Implementation

## Overview

Part 2 focuses on extracting insights from collected game data using SQL queries and R statistical analysis. We'll calculate key performance indicators (KPIs), perform demographic segmentation, generate confidence intervals, and create visualizations.

**Two-Phase Approach:**

- **Phase 1 (Automated):** Create all SQL queries and R scripts with placeholder connection details
- **Phase 2 (Collaborative):** You'll provide your database credentials, and we'll run the analysis together on YOUR actual data in real-time

## File Structure to Create

```
Delivery 1 KPIs/
├── Database/
│   ├── schema.sql (exists)
│   └── kpi_queries.sql (NEW - comprehensive SQL queries)
├── Analysis/
│   ├── config.R (NEW - YOUR database credentials, gitignored)
│   ├── config.R.template (NEW - template for config)
│   ├── analysis.R (NEW - main R analysis script)
│   ├── exploratory_analysis.R (NEW - data exploration)
│   ├── utils.R (NEW - helper functions)
│   ├── visualizations/ (NEW - output directory for plots)
│   └── kpi_results.csv (NEW - exported KPI summary)
└── Documentation/
    ├── KPI_REPORT.md (NEW - comprehensive findings report)
    ├── PART2_GUIDE.md (NEW - setup instructions)
    ├── PRESENTATION_BRIEF.md (NEW - handoff doc for slides agent)
    └── SLIDE_CONTENT.md (NEW - pre-written slide content)
```

## Implementation Steps

### PHASE 1: Create Reusable Analysis Framework

#### Step 1: Create SQL Query Library (`kpi_queries.sql`)

Comprehensive SQL queries organized by category:

**User Engagement Metrics:**

- DAU (Daily Active Users) - time series
- MAU (Monthly Active Users) - by month
- WAU (Weekly Active Users)
- Stickiness Ratio (DAU/MAU)

**Retention Metrics:**

- D1, D3, D7 Retention (% returning after N days)
- Cohort-based retention analysis
- User lifecycle stages

**Monetization Metrics:**

- ARPU (Average Revenue Per User)
- ARPPU (Average Revenue Per Paying User)
- Conversion Rate (% of paying users)
- Revenue by item type
- Lifetime Value (LTV) estimates
- Revenue concentration (top 10% of spenders)

**Session Metrics:**

- Average sessions per user
- Average session duration
- Session length distribution
- Time-of-day analysis

**Demographic Segmentation:**

- All KPIs segmented by country
- All KPIs segmented by age group (<18, 18-25, 26-35, 36-45, 45+)
- All KPIs segmented by gender
- Cross-segment analysis (e.g., country + age)

**Data Quality Queries:**

- Record counts per table
- Date range coverage
- Orphaned records check
- Null value detection

#### Step 2: Create Configuration Template (`config.R.template`)

Template file with:

```r
# Database Connection Configuration
# INSTRUCTIONS: Copy this file to 'config.R' and fill in YOUR credentials
# config.R is gitignored for security

DB_CONFIG <- list(
  host = "localhost",              # Usually localhost for UPC server
  dbname = "YOUR_DATABASE_NAME",   # Replace with your database
  user = "YOUR_USERNAME",          # Replace with your username
  password = "YOUR_PASSWORD"       # Replace with your password
)

# Analysis Parameters
ANALYSIS_CONFIG <- list(
  confidence_level = 0.95,         # 95% confidence intervals
  output_dir = "Analysis/visualizations/",
  high_quality_plots = TRUE,       # 300 DPI exports
  date_range = NULL                # NULL = analyze all data
)
```

#### Step 3: Create Utility Functions (`utils.R`)

Helper functions library:

- `safe_connect()` - database connection with error handling
- `execute_query()` - run SQL with logging
- `calculate_ci()` - compute confidence intervals
- `format_kpi()` - pretty print metrics
- `create_age_buckets()` - categorize ages
- `export_plot()` - save visualization with consistent settings
- `summary_table()` - generate markdown tables

#### Step 4: Create Exploratory Analysis (`exploratory_analysis.R`)

Data exploration script that:

- Sources `config.R` and `utils.R`
- Connects to database with diagnostics
- Prints data summary (row counts, date ranges, unique values)
- Generates descriptive statistics
- Creates basic exploratory plots
- Identifies data quality issues
- **Outputs diagnostic report for us to review together**

Key feature: **Verbose diagnostic output** so when you run it, we can see:

```
✓ Connected to database: your_database_name
✓ Tables found: users (127 rows), sessions (843 rows), purchases (156 rows)
✓ Date range: 2022-01-03 to 2022-12-28
✓ Countries represented: 8 unique countries
✓ Ready for analysis!
```

#### Step 5: Create Main Analysis Script (`analysis.R`)

Comprehensive R script with:

**Setup & Connection:**

- Sources config.R (YOUR credentials) and utils.R
- Loads packages: RMySQL, ggplot2, dplyr, tidyr, scales, lubridate
- Establishes database connection with validation

**KPI Calculations:**

- Executes each query from `kpi_queries.sql`
- Calculates metrics with 95% confidence intervals
- Stores results in structured data frames
- Handles edge cases (e.g., no purchases = ARPPU = NA)

**Statistical Analysis:**

- Hypothesis testing (country differences in ARPU, etc.)
- Correlation analysis (age vs spending, session count vs revenue)
- Trend analysis over time
- Anomaly detection

**Demographic Segmentation:**

- Segment users by country, age, gender
- Compare KPIs across segments
- Identify high-value user profiles
- Statistical significance of segment differences

**Visualizations (8+ plots):**

1. DAU/MAU time series with trend lines
2. ARPU by country (top 10) with error bars
3. Retention curve (D1/D3/D7) with confidence bands
4. Revenue distribution histogram + summary stats
5. Country × Age heatmap (average spending)
6. Session duration boxplot by user segment
7. Conversion funnel visualization
8. Cohort retention heatmap

**Adaptive Analysis:**

The script will detect your data characteristics:

- Small dataset (<50 users)? Use Fisher's exact test instead of chi-square
- Limited date range? Adjust time series granularity
- Few purchases? Focus on engagement metrics

**Export Results:**

- All plots saved to `Analysis/visualizations/`
- Summary statistics to CSV
- KPI values with CIs to `kpi_results.csv`

#### Step 6: Create Setup Guide (`PART2_GUIDE.md`)

Comprehensive instructions:

- Installing R and RStudio (macOS specific)
- Installing required packages
- Setting up database credentials in `config.R`
- Running each script step-by-step
- Interpreting output
- Troubleshooting common issues

### PHASE 2: Collaborative Analysis with Your Data

#### Step 7: Interactive Analysis Session

**Workflow:**

1. You create `config.R` from template with YOUR database credentials
2. You run `exploratory_analysis.R` and share the diagnostic output with me
3. I review the output and identify:

   - Data characteristics (size, date range, distributions)
   - Any data quality issues
   - Adjustments needed for your specific dataset

4. We refine the analysis approach based on your data
5. You run `analysis.R` and we review results together
6. I help interpret findings and statistical tests
7. We iterate on visualizations if needed

**Benefits of This Approach:**

- ✅ Scripts work with YOUR actual data (not dummy data)
- ✅ R stays connected to MySQL (no CSV exports needed)
- ✅ I can see diagnostic output and help troubleshoot
- ✅ Analysis is tailored to your specific dataset characteristics
- ✅ Real-time collaboration on interpretation
- ✅ You maintain full control over credentials (config.R is gitignored)

#### Step 8: Generate KPI Report (`KPI_REPORT.md`)

**After Phase 2 analysis**, we'll populate the report with:

**Executive Summary:**

- Key findings from YOUR data (3-5 bullet points)
- Most important metrics with actual values
- Actionable recommendations based on real insights

**Methodology:**

- Your data collection period
- Your actual sample size
- Statistical methods applied

**Detailed KPI Results:**

- All metrics with YOUR confidence intervals
- Interpretation specific to YOUR data
- Embedded visualizations from YOUR analysis
- Statistical significance notes from YOUR tests

**Demographic Insights:**

- Which of YOUR countries generate most revenue?
- Which of YOUR age groups are most engaged?
- User personas from YOUR player base

**Recommendations:**

- Business actions based on YOUR findings
- Areas for further investigation in YOUR data
- Limitations specific to YOUR dataset

#### Step 9: Update Existing Documentation

Add Part 2 status to:

- `PROJECT_SUMMARY.md` - mark Part 2 complete
- `IMPLEMENTATION_GUIDE.md` - add Part 2 section with lessons learned

## Key Technical Details

### SQL Query Organization

Each query will be:

- Self-contained and documented
- Named with clear purpose
- Tested for efficiency
- Compatible with MySQL syntax

### R Script Architecture

```r
# Modular design
source("config.R")        # YOUR credentials
source("utils.R")         # Helper functions

# Main analysis flow
connect_and_validate()    # Check connection
load_data()               # Execute SQL queries
calculate_kpis()          # Compute metrics + CIs
perform_segmentation()    # Demographic analysis
generate_visualizations() # Create plots
export_results()          # Save outputs
disconnect()              # Clean up
```

### Security Considerations

- `config.R` added to `.gitignore`
- `config.R.template` is safe to commit (no credentials)
- Scripts never log passwords
- Connection objects properly closed

## Critical Considerations

### Database Schema Reference

- `users`: user_id, username, country, age, gender, registration_date
- `sessions`: session_id, user_id, start_time, end_time, duration_seconds
- `purchases`: purchase_id, session_id, user_id, item_id, amount, purchase_date
- `items`: item_id, item_name, price, category

### Statistical Rigor

- 95% confidence intervals for all metrics
- Appropriate tests (t-test, chi-square, Fisher's exact)
- Bonferroni correction for multiple comparisons
- Clearly state assumptions and limitations

### Visualization Standards

- Professional quality (300 DPI)
- Color-blind friendly palettes (viridis, ColorBrewer)
- Consistent theming
- Informative titles and labels

## Success Criteria

Part 2 is complete when:

- ✅ All SQL queries created and documented
- ✅ R scripts created with proper error handling
- ✅ You successfully run analysis on YOUR database
- ✅ All KPIs calculated with confidence intervals
- ✅ 8+ professional visualizations generated from YOUR data
- ✅ Demographic segmentation completed on YOUR data
- ✅ Statistical tests performed and interpreted
- ✅ KPI report written with YOUR findings
- ✅ Results are reproducible

## Timeline Estimate

**Phase 1 (Automated - me):** ~1-2 hours

- Create all SQL queries
- Create all R scripts
- Create documentation
- Test framework structure

**Phase 2 (Collaborative - together):** ~30-60 minutes

- You set up config.R
- Run exploratory script
- Review diagnostics together
- Run main analysis
- Interpret results together
- Finalize report

## Next Steps After Plan Approval

**Phase 1 (I will execute):**

1. Create `Database/kpi_queries.sql`
2. Create `Analysis/` directory structure
3. Create `config.R.template`
4. Create `utils.R` with helper functions
5. Create `exploratory_analysis.R`
6. Create `analysis.R` (main script)
7. Create `PART2_GUIDE.md`
8. Add `config.R` to `.gitignore`

**Phase 2 (We will do together):**

9. You create `config.R` from template
10. You run `exploratory_analysis.R`
11. Share diagnostic output with me
12. We review and adjust if needed
13. You run `analysis.R`
14. We interpret results together
15. Generate visualizations
16. Write `KPI_REPORT.md` with real findings
17. Update documentation

This approach ensures the R scripts work with YOUR actual data while maintaining the MySQL connection, and I can help you interpret the results in real-time!

### To-dos

- [ ] Create comprehensive SQL query library (kpi_queries.sql) with all metrics organized by category: engagement, retention, monetization, sessions, demographics
- [ ] Create config.R.template with database connection parameters and analysis settings
- [ ] Create utils.R with helper functions: safe_connect, execute_query, calculate_ci, export_plot, etc.
- [ ] Create exploratory_analysis.R with verbose diagnostics for data validation and initial exploration
- [ ] Create analysis.R with complete KPI calculations, statistical tests, segmentation, and visualization generation
- [ ] Create PART2_GUIDE.md with R installation, package setup, config instructions, and execution steps
- [ ] Add config.R to .gitignore to protect database credentials
- [ ] Interactive session: user creates config.R, runs exploratory script, shares diagnostics, we review together
- [ ] User runs analysis.R on their data, we interpret results and refine visualizations together
- [ ] Write KPI_REPORT.md with actual findings from user's data analysis
- [ ] Update PROJECT_SUMMARY.md and IMPLEMENTATION_GUIDE.md with Part 2 completion