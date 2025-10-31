# =====================================================
# Exploratory Data Analysis Script
# =====================================================
# Purpose: Initial data exploration and validation
# This script provides verbose diagnostics to understand
# your dataset before running the main analysis
# =====================================================

# Clear environment
rm(list = ls())

# Set working directory to script location
# Works both in RStudio and from command line
if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}
# When running from command line, assume we're already in the correct directory
cat("Working directory:", getwd(), "\n")

cat("\n")
cat("========================================\n")
cat("  EXPLORATORY DATA ANALYSIS\n")
cat("  Game Analytics Pipeline - Part 2\n")
cat("========================================\n\n")

# =====================================================
# STEP 1: Load Configuration and Utilities
# =====================================================

cat("STEP 1: Loading configuration...\n")
cat("----------------------------------------\n")

# Check if config.R exists
if (!file.exists("config.R")) {
  cat("✗ ERROR: config.R not found!\n\n")
  cat("Please create config.R from the template:\n")
  cat("1. Copy config.R.template to config.R\n")
  cat("2. Edit config.R with your database credentials\n\n")
  stop("Configuration file missing")
}

# Load configuration
source("config.R")
cat("✓ Configuration loaded\n")

# Load utility functions
source("utils.R")

# Initialize analysis environment
initialize_analysis()


# =====================================================
# STEP 2: Install/Load Required Packages
# =====================================================

cat("\nSTEP 2: Loading packages...\n")
cat("----------------------------------------\n")

required_packages <- c("RMySQL", "ggplot2", "dplyr", "tidyr")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, quiet = TRUE)
    library(pkg, character.only = TRUE)
  }
}

cat("✓ All packages loaded\n")


# =====================================================
# STEP 3: Connect to Database
# =====================================================

cat("\nSTEP 3: Connecting to database...\n")
cat("----------------------------------------\n")
cat("Host:", DB_CONFIG$host, "\n")
cat("Database:", DB_CONFIG$dbname, "\n")
cat("User:", DB_CONFIG$user, "\n")

# Establish connection
con <- safe_connect()

# Validate database structure
validate_database(con)


# =====================================================
# STEP 4: Data Quality Checks
# =====================================================

cat("\nSTEP 4: Data quality checks...\n")
cat("========================================\n")

# Check 1: Table record counts
cat("\n📊 Table Record Counts:\n")
cat("----------------------------------------\n")

query_counts <- "
SELECT 'users' as table_name, COUNT(*) as row_count FROM users
UNION ALL
SELECT 'sessions', COUNT(*) FROM sessions
UNION ALL
SELECT 'purchases', COUNT(*) FROM purchases
UNION ALL
SELECT 'items', COUNT(*) FROM items;
"

counts <- execute_query(con, query_counts, "Table counts")
print(counts)

users_count <- counts$row_count[counts$table_name == "users"]
sessions_count <- counts$row_count[counts$table_name == "sessions"]
purchases_count <- counts$row_count[counts$table_name == "purchases"]
items_count <- counts$row_count[counts$table_name == "items"]

if (users_count == 0) {
  cat("\n⚠️  WARNING: No users found in database!\n")
  cat("   Have you run the Unity simulator to collect data?\n")
}


# Check 2: Date range coverage
cat("\n📅 Date Range Coverage:\n")
cat("----------------------------------------\n")

query_dates <- "
SELECT 
    'users' as table_name,
    MIN(registration_date) as earliest_date,
    MAX(registration_date) as latest_date,
    DATEDIFF(MAX(registration_date), MIN(registration_date)) as days_covered
FROM users
UNION ALL
SELECT 
    'sessions',
    MIN(start_time),
    MAX(start_time),
    DATEDIFF(MAX(start_time), MIN(start_time))
FROM sessions;
"

dates <- execute_query(con, query_dates, "Date ranges")
print(dates)


# Check 3: Orphaned records
cat("\n🔗 Referential Integrity:\n")
cat("----------------------------------------\n")

# Check orphaned sessions
query_orphaned_sessions <- "
SELECT COUNT(*) as orphaned_sessions
FROM sessions s
LEFT JOIN users u ON s.user_id = u.user_id
WHERE u.user_id IS NULL;
"
orphaned_sessions <- execute_query(con, query_orphaned_sessions)
cat("Orphaned sessions:", orphaned_sessions$orphaned_sessions, "\n")

if (orphaned_sessions$orphaned_sessions > 0) {
  cat("⚠️  WARNING: Found", orphaned_sessions$orphaned_sessions, "sessions without valid users\n")
}

# Check orphaned purchases
query_orphaned_purchases <- "
SELECT COUNT(*) as orphaned_purchases
FROM purchases p
LEFT JOIN sessions s ON p.session_id = s.session_id
WHERE s.session_id IS NULL;
"
orphaned_purchases <- execute_query(con, query_orphaned_purchases)
cat("Orphaned purchases:", orphaned_purchases$orphaned_purchases, "\n")

if (orphaned_purchases$orphaned_purchases > 0) {
  cat("⚠️  WARNING: Found", orphaned_purchases$orphaned_purchases, "purchases without valid sessions\n")
}


# Check 4: Incomplete sessions
cat("\n⏱️  Session Completeness:\n")
cat("----------------------------------------\n")

query_incomplete <- "
SELECT COUNT(*) as incomplete_sessions
FROM sessions
WHERE end_time IS NULL OR duration_seconds IS NULL;
"
incomplete <- execute_query(con, query_incomplete)
cat("Incomplete sessions:", incomplete$incomplete_sessions, "\n")
cat("Complete sessions:", sessions_count - incomplete$incomplete_sessions, "\n")

if (incomplete$incomplete_sessions > 0) {
  pct_incomplete <- (incomplete$incomplete_sessions / sessions_count) * 100
  cat(sprintf("⚠️  %.1f%% of sessions are incomplete\n", pct_incomplete))
}


# =====================================================
# STEP 5: Descriptive Statistics
# =====================================================

cat("\n\nSTEP 5: Descriptive statistics...\n")
cat("========================================\n")

# User demographics
cat("\n👥 User Demographics:\n")
cat("----------------------------------------\n")

query_demographics <- "
SELECT 
    COUNT(*) as total_users,
    MIN(age) as min_age,
    AVG(age) as avg_age,
    MAX(age) as max_age,
    COUNT(DISTINCT country) as unique_countries
FROM users;
"
demographics <- execute_query(con, query_demographics, "Demographics")
cat("Total users:", demographics$total_users, "\n")
cat("Age range:", demographics$min_age, "-", demographics$max_age, "\n")
cat("Average age:", round(demographics$avg_age, 1), "\n")
cat("Unique countries:", demographics$unique_countries, "\n")

# Top countries
cat("\n🌍 Top Countries:\n")
query_countries <- "
SELECT country, COUNT(*) as user_count
FROM users
GROUP BY country
ORDER BY user_count DESC
LIMIT 10;
"
top_countries <- execute_query(con, query_countries, "Top countries")
print(top_countries)


# Session statistics
cat("\n🎮 Session Statistics:\n")
cat("----------------------------------------\n")

query_sessions <- "
SELECT 
    COUNT(*) as total_sessions,
    COUNT(DISTINCT user_id) as users_with_sessions,
    AVG(duration_seconds) / 60 as avg_duration_minutes,
    MIN(duration_seconds) as min_duration_seconds,
    MAX(duration_seconds) as max_duration_seconds
FROM sessions
WHERE duration_seconds IS NOT NULL;
"
session_stats <- execute_query(con, query_sessions, "Session stats")
cat("Total sessions:", session_stats$total_sessions, "\n")
cat("Users with sessions:", session_stats$users_with_sessions, "\n")
cat("Average duration:", round(session_stats$avg_duration_minutes, 1), "minutes\n")
cat("Duration range:", session_stats$min_duration_seconds, "-", 
    session_stats$max_duration_seconds, "seconds\n")


# Purchase statistics
cat("\n💰 Purchase Statistics:\n")
cat("----------------------------------------\n")

if (purchases_count > 0) {
  query_purchases <- "
  SELECT 
      COUNT(*) as total_purchases,
      COUNT(DISTINCT user_id) as paying_users,
      SUM(amount) as total_revenue,
      AVG(amount) as avg_transaction,
      MIN(amount) as min_transaction,
      MAX(amount) as max_transaction
  FROM purchases;
  "
  purchase_stats <- execute_query(con, query_purchases, "Purchase stats")
  
  cat("Total purchases:", purchase_stats$total_purchases, "\n")
  cat("Paying users:", purchase_stats$paying_users, "\n")
  cat("Total revenue: $", round(purchase_stats$total_revenue, 2), "\n", sep = "")
  cat("Average transaction: $", round(purchase_stats$avg_transaction, 2), "\n", sep = "")
  cat("Conversion rate:", 
      round((purchase_stats$paying_users / users_count) * 100, 1), "%\n")
  
  # Top items
  cat("\n🛍️  Top Selling Items:\n")
  query_items <- "
  SELECT 
      i.item_name,
      COUNT(p.purchase_id) as purchase_count,
      SUM(p.amount) as total_revenue
  FROM items i
  LEFT JOIN purchases p ON i.item_id = p.item_id
  GROUP BY i.item_id, i.item_name
  ORDER BY total_revenue DESC;
  "
  item_stats <- execute_query(con, query_items, "Item sales")
  print(item_stats)
  
} else {
  cat("⚠️  No purchases found in database\n")
  cat("   Users may not have made any in-game purchases during simulation\n")
}


# =====================================================
# STEP 6: Quick KPI Preview
# =====================================================

cat("\n\nSTEP 6: Quick KPI preview...\n")
cat("========================================\n")

# DAU sample
cat("\n📈 Daily Active Users (sample):\n")
cat("----------------------------------------\n")
query_dau <- "
SELECT 
    DATE(start_time) as date,
    COUNT(DISTINCT user_id) as dau
FROM sessions
GROUP BY DATE(start_time)
ORDER BY date
LIMIT 10;
"
dau_sample <- execute_query(con, query_dau, "DAU sample")
print(dau_sample)

# ARPU calculation
cat("\n💵 Revenue Metrics:\n")
cat("----------------------------------------\n")
if (purchases_count > 0) {
  arpu <- purchase_stats$total_revenue / users_count
  arppu <- purchase_stats$total_revenue / purchase_stats$paying_users
  
  cat("ARPU (Average Revenue Per User): $", round(arpu, 2), "\n", sep = "")
  cat("ARPPU (Avg Revenue Per Paying User): $", round(arppu, 2), "\n", sep = "")
} else {
  cat("ARPU: $0.00 (no purchases)\n")
  cat("ARPPU: N/A (no paying users)\n")
}


# =====================================================
# STEP 7: Data Visualization Preview
# =====================================================

cat("\n\nSTEP 7: Creating preview visualizations...\n")
cat("========================================\n")

# Create output directory
if (!dir.exists(ANALYSIS_CONFIG$output_dir)) {
  dir.create(ANALYSIS_CONFIG$output_dir, recursive = TRUE)
  cat("✓ Created directory:", ANALYSIS_CONFIG$output_dir, "\n")
}

# Plot 1: User distribution by country
if (users_count > 0) {
  cat("\nGenerating preview plots...\n")
  
  country_data <- execute_query(con, "
    SELECT country, COUNT(*) as user_count
    FROM users
    GROUP BY country
    ORDER BY user_count DESC
    LIMIT 10;
  ")
  
  p1 <- ggplot(country_data, aes(x = reorder(country, user_count), y = user_count)) +
    geom_bar(stat = "identity", fill = "#3498db") +
    coord_flip() +
    labs(title = "User Distribution by Country (Top 10)",
         x = "Country", y = "Number of Users") +
    theme_minimal(base_size = 12)
  
  export_plot(p1, "exploratory_country_distribution")
}

# Plot 2: DAU over time (if enough data)
if (sessions_count > 0) {
  dau_data <- execute_query(con, "
    SELECT DATE(start_time) as date, COUNT(DISTINCT user_id) as dau
    FROM sessions
    GROUP BY DATE(start_time)
    ORDER BY date;
  ")
  
  if (nrow(dau_data) > 1) {
    dau_data$date <- as.Date(dau_data$date)
    
    p2 <- ggplot(dau_data, aes(x = date, y = dau)) +
      geom_line(color = "#2ecc71", size = 1) +
      geom_point(color = "#27ae60", size = 2) +
      labs(title = "Daily Active Users Over Time",
           x = "Date", y = "DAU") +
      theme_minimal(base_size = 12) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    export_plot(p2, "exploratory_dau_trend")
  }
}


# =====================================================
# STEP 8: Summary & Next Steps
# =====================================================

cat("\n\n")
cat("========================================\n")
cat("  EXPLORATORY ANALYSIS COMPLETE\n")
cat("========================================\n\n")

cat("📋 SUMMARY:\n")
cat("----------------------------------------\n")
cat("✓ Database connection: SUCCESS\n")
cat("✓ Data validation: COMPLETE\n")
cat("✓ Descriptive statistics: GENERATED\n")
cat("✓ Preview visualizations: CREATED\n\n")

cat("📊 DATA OVERVIEW:\n")
cat("  Users:", users_count, "\n")
cat("  Sessions:", sessions_count, "\n")
cat("  Purchases:", purchases_count, "\n")
if (users_count > 0) {
  cat("  Avg sessions/user:", round(sessions_count / users_count, 1), "\n")
}
cat("\n")

# Data quality assessment
cat("✅ DATA QUALITY:\n")
quality_score <- 0
max_score <- 5

if (users_count > 0) {
  cat("  ✓ User data present\n")
  quality_score <- quality_score + 1
}
if (sessions_count > 0) {
  cat("  ✓ Session data present\n")
  quality_score <- quality_score + 1
}
if (orphaned_sessions$orphaned_sessions == 0) {
  cat("  ✓ No orphaned sessions\n")
  quality_score <- quality_score + 1
}
if (orphaned_purchases$orphaned_purchases == 0) {
  cat("  ✓ No orphaned purchases\n")
  quality_score <- quality_score + 1
}
if (incomplete$incomplete_sessions < sessions_count * 0.1) {
  cat("  ✓ Most sessions are complete\n")
  quality_score <- quality_score + 1
}

cat("\nData Quality Score:", quality_score, "/", max_score, "\n\n")

# Next steps
cat("🚀 NEXT STEPS:\n")
cat("----------------------------------------\n")
if (quality_score >= 4) {
  cat("✓ Your data looks good! Ready to proceed.\n")
  cat("\n1. Review the diagnostics above\n")
  cat("2. Check preview visualizations in:", ANALYSIS_CONFIG$output_dir, "\n")
  cat("3. Run the main analysis script: source('analysis.R')\n")
} else {
  cat("⚠️  Some data quality issues detected.\n")
  cat("\nRecommendations:\n")
  if (users_count == 0) {
    cat("- Run Unity simulator to collect user data\n")
  }
  if (orphaned_sessions$orphaned_sessions > 0) {
    cat("- Investigate orphaned sessions (data integrity issue)\n")
  }
  if (orphaned_purchases$orphaned_purchases > 0) {
    cat("- Investigate orphaned purchases (data integrity issue)\n")
  }
  cat("\nAfter addressing issues, re-run this exploratory script.\n")
}

cat("\n")

# Close database connection
dbDisconnect(con)
cat("✓ Database connection closed\n\n")

cat("========================================\n")
cat("  Analysis session ended\n")
cat("========================================\n\n")

