# 🎓 Hands-On Learning Guide - Step-by-Step Analysis

**Purpose**: Experience the analysis process interactively while learning SQL and R techniques.

---

## 🎯 Learning Objectives

By completing this guide, you will:
1. Execute SQL queries directly on your database
2. Manipulate data in R using dplyr/tidyr
3. Create statistical visualizations with ggplot2
4. Calculate confidence intervals and run t-tests
5. Export professional charts and reports

---

## 📚 Step 1: SQL Queries (15-20 minutes)

### Option 1A: SQL Workbench (Visual)

1. **Open SQL Workbench** and connect to your database
2. **Open** `Database/kpi_queries.sql`
3. **Execute queries one section at a time** and observe results

**Try These Key Queries** (copy-paste into SQL Workbench):

```sql
-- 1. DATA OVERVIEW
SELECT 
  (SELECT COUNT(*) FROM users) as total_users,
  (SELECT COUNT(*) FROM sessions) as total_sessions,
  (SELECT COUNT(*) FROM purchases) as total_purchases;

-- 2. DAILY ACTIVE USERS (DAU)
SELECT 
  DATE(start_time) as date,
  COUNT(DISTINCT user_id) as dau
FROM sessions
WHERE start_time IS NOT NULL
GROUP BY DATE(start_time)
ORDER BY date;
-- Export this to CSV or note the values

-- 3. TOP COUNTRIES BY ARPU
SELECT 
  u.country,
  COUNT(DISTINCT u.user_id) as users,
  COUNT(DISTINCT CASE WHEN p.user_id IS NOT NULL THEN u.user_id END) as paying_users,
  COALESCE(SUM(p.amount), 0) as revenue,
  COALESCE(SUM(p.amount) / COUNT(DISTINCT u.user_id), 0) as arpu,
  COALESCE(COUNT(DISTINCT CASE WHEN p.user_id IS NOT NULL THEN u.user_id END) * 100.0 / COUNT(DISTINCT u.user_id), 0) as conversion_rate
FROM users u
LEFT JOIN purchases p ON u.user_id = p.user_id
GROUP BY u.country
HAVING users >= 5  -- At least 5 users for statistical reliability
ORDER BY arpu DESC
LIMIT 10;
-- This is your geographic goldmine query!

-- 4. D7 RETENTION
SELECT 
  COUNT(DISTINCT user_id) as total_users,
  COUNT(DISTINCT CASE 
    WHEN user_id IN (
      SELECT DISTINCT s.user_id
      FROM sessions s
      JOIN users u ON s.user_id = u.user_id
      WHERE DATEDIFF(s.start_time, u.registration_date) BETWEEN 1 AND 7
    ) THEN user_id 
  END) as returned_users,
  ROUND(COUNT(DISTINCT CASE 
    WHEN user_id IN (
      SELECT DISTINCT s.user_id
      FROM sessions s
      JOIN users u ON s.user_id = u.user_id
      WHERE DATEDIFF(s.start_time, u.registration_date) BETWEEN 1 AND 7
    ) THEN user_id 
  END) * 100.0 / COUNT(DISTINCT user_id), 2) as d7_retention_pct
FROM users;
-- Your 65.6% retention comes from here!
```

**Learning Points**:
- Notice how `LEFT JOIN` preserves all users, even non-payers
- `CASE WHEN` enables conditional counting
- `COALESCE` handles NULL values for non-payers
- `DATEDIFF` calculates days between dates
- `GROUP BY` with `HAVING` filters after aggregation

### Option 1B: R Database Queries (Alternative)

Or run SQL directly from R (see below in RStudio section).

---

## 🔬 Step 2: RStudio Interactive Analysis (30-40 minutes)

### Setup

1. **Open RStudio**
2. **File → Open File** → Navigate to `Analysis/exploratory_analysis.R`
3. **Set working directory**: Session → Set Working Directory → To Source File Location

### Run Code Interactively (Line by Line)

Instead of running the entire script, **execute code section by section** using:
- **Ctrl+Enter** (Windows/Linux) or **Cmd+Enter** (Mac) to run current line
- **Ctrl+Shift+Enter** to run entire chunk

---

### 🎯 **EXPLORATORY ANALYSIS - Interactive Walkthrough**

Open `exploratory_analysis.R` and follow along:

#### **Section 1: Setup & Connection (Lines 1-30)**

```r
# Load packages one at a time and observe
library(RMySQL)       # Database connection
library(dplyr)        # Data manipulation
library(ggplot2)      # Visualizations

# Load your configuration
source("config.R")    # Your database credentials
source("utils.R")     # Helper functions

# Connect to database - watch the console!
con <- safe_connect(
  host = DB_CONFIG$host,
  dbname = DB_CONFIG$dbname,
  user = DB_CONFIG$user,
  password = DB_CONFIG$password
)

# Check connection worked
print(con)  # Should show MySQL connection object
```

**💡 Learning Point**: `safe_connect()` wraps the MySQL connection with error handling.

---

#### **Section 2: Data Quality Checks (Lines 35-80)**

```r
# Count records in each table
query <- "SELECT COUNT(*) as count FROM users"
user_count <- execute_query(con, query)
print(user_count)  # Should show 1007

# Try for other tables
session_count <- execute_query(con, "SELECT COUNT(*) as count FROM sessions")
purchase_count <- execute_query(con, "SELECT COUNT(*) as count FROM purchases")

print(paste("Users:", user_count$count))
print(paste("Sessions:", session_count$count))
print(paste("Purchases:", purchase_count$count))
```

**🔍 Explore Your Data**:

```r
# Preview users table
users_sample <- execute_query(con, "SELECT * FROM users LIMIT 10")
View(users_sample)  # Opens data viewer in RStudio

# Check date range
date_range <- execute_query(con, "
  SELECT 
    MIN(registration_date) as first_user,
    MAX(registration_date) as last_user,
    DATEDIFF(MAX(registration_date), MIN(registration_date)) as days_span
  FROM users
")
print(date_range)  # Full year 2022!
```

**💡 Learning Point**: `View()` opens RStudio's data viewer for exploration.

---

#### **Section 3: Descriptive Statistics (Lines 85-140)**

```r
# Get basic stats
basic_stats <- execute_query(con, "
  SELECT 
    COUNT(DISTINCT user_id) as total_users,
    COUNT(DISTINCT country) as countries,
    AVG(age) as avg_age,
    MIN(age) as min_age,
    MAX(age) as max_age
  FROM users
")

print(basic_stats)
```

**🎨 Create Your First Visualization**:

```r
# Get country distribution
country_data <- execute_query(con, "
  SELECT country, COUNT(*) as user_count
  FROM users
  GROUP BY country
  ORDER BY user_count DESC
  LIMIT 10
")

# Create bar chart
ggplot(country_data, aes(x = reorder(country, user_count), y = user_count)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +  # Horizontal bars
  labs(
    title = "Top 10 Countries by User Count",
    x = "Country",
    y = "Number of Users"
  ) +
  theme_minimal()
```

**💡 Learning Points**:
- `reorder()` sorts bars by value
- `coord_flip()` makes horizontal bars
- `theme_minimal()` applies clean styling

**Save Your Plot**:

```r
ggsave("my_first_chart.png", width = 10, height = 6, dpi = 300)
```

---

#### **Section 4: Key Metrics Calculation (Lines 145-200)**

```r
# Calculate ARPU manually
arpu_data <- execute_query(con, "
  SELECT 
    COUNT(DISTINCT u.user_id) as total_users,
    SUM(COALESCE(p.amount, 0)) as total_revenue,
    SUM(COALESCE(p.amount, 0)) / COUNT(DISTINCT u.user_id) as arpu
  FROM users u
  LEFT JOIN purchases p ON u.user_id = p.user_id
")

print(arpu_data)
# You should see: total_users = 1007, total_revenue = 10934.28, ARPU = 10.86

# Breakdown: Where does revenue come from?
item_revenue <- execute_query(con, "
  SELECT 
    i.item_name,
    i.price,
    COUNT(p.purchase_id) as purchase_count,
    SUM(p.amount) as total_revenue,
    ROUND(SUM(p.amount) * 100.0 / (SELECT SUM(amount) FROM purchases), 2) as revenue_pct
  FROM purchases p
  JOIN items i ON p.item_id = i.item_id
  GROUP BY i.item_id, i.item_name, i.price
  ORDER BY total_revenue DESC
")

View(item_revenue)  # See Diamond Pack dominating!

# Visualize it
ggplot(item_revenue, aes(x = reorder(item_name, total_revenue), y = total_revenue, fill = item_name)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(
    title = "Revenue by Item",
    subtitle = "Diamond Pack ($49.99) drives 62% of revenue",
    x = "Item",
    y = "Total Revenue ($)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

---

### 🎯 **MAIN ANALYSIS - Interactive Walkthrough**

Now open `analysis.R` and work through the key sections:

#### **Section 1: DAU Calculation with Confidence Intervals**

```r
# Get daily active users
dau_data <- execute_query(con, "
  SELECT 
    DATE(start_time) as date,
    COUNT(DISTINCT user_id) as dau
  FROM sessions
  WHERE start_time IS NOT NULL
  GROUP BY DATE(start_time)
  ORDER BY date
")

# Calculate 95% CI manually
mean_dau <- mean(dau_data$dau)
sd_dau <- sd(dau_data$dau)
n <- nrow(dau_data)
se <- sd_dau / sqrt(n)
ci_lower <- mean_dau - 1.96 * se
ci_upper <- mean_dau + 1.96 * se

print(paste("Mean DAU:", round(mean_dau, 2)))
print(paste("95% CI: [", round(ci_lower, 2), ",", round(ci_upper, 2), "]"))
# Output: Mean DAU: 9.1, 95% CI: [8.6, 9.6]
```

**💡 Learning Point**: Confidence intervals show uncertainty. We're 95% confident the true DAU is between 8.6-9.6.

**Visualize DAU Trend**:

```r
ggplot(dau_data, aes(x = as.Date(date), y = dau)) +
  geom_line(color = "steelblue", size = 1) +
  geom_smooth(method = "loess", color = "red", se = TRUE, alpha = 0.2) +
  labs(
    title = "Daily Active Users (DAU) - Full Year 2022",
    subtitle = paste("Mean DAU:", round(mean_dau, 1), "[95% CI:", round(ci_lower, 1), "-", round(ci_upper, 1), "]"),
    x = "Date",
    y = "Active Users"
  ) +
  theme_minimal()
```

**💡 Learning Point**: `geom_smooth()` adds a trend line with confidence band.

---

#### **Section 2: Retention Analysis**

```r
# Calculate D7 retention
retention <- execute_query(con, "
  SELECT 
    COUNT(DISTINCT user_id) as total_users,
    COUNT(DISTINCT CASE 
      WHEN user_id IN (
        SELECT DISTINCT s.user_id
        FROM sessions s
        JOIN users u ON s.user_id = u.user_id
        WHERE DATEDIFF(s.start_time, u.registration_date) BETWEEN 1 AND 7
      ) THEN user_id 
    END) as d7_returned,
    ROUND(COUNT(DISTINCT CASE 
      WHEN user_id IN (
        SELECT DISTINCT s.user_id
        FROM sessions s
        JOIN users u ON s.user_id = u.user_id
        WHERE DATEDIFF(s.start_time, u.registration_date) BETWEEN 1 AND 7
      ) THEN user_id 
    END) * 100.0 / COUNT(DISTINCT user_id), 2) as d7_retention_pct
  FROM users
")

print(retention)
# Output: total_users = 1007, d7_returned = 661, d7_retention_pct = 65.6%
```

**Create Retention Visualization**:

```r
# Compare to industry benchmark
retention_comparison <- data.frame(
  metric = c("Your Game\nD7 Retention", "Industry\nBenchmark"),
  value = c(65.6, 15),  # Industry avg: 10-20%, using 15% midpoint
  label = c("65.6%", "15%")
)

ggplot(retention_comparison, aes(x = metric, y = value, fill = metric)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = label), vjust = -0.5, size = 6, fontface = "bold") +
  scale_fill_manual(values = c("Your Game\nD7 Retention" = "#2ecc71", "Industry\nBenchmark" = "#95a5a6")) +
  labs(
    title = "D7 Retention: Your Game vs. Industry",
    subtitle = "Your game retains 65.6% of users after 7 days - EXCEPTIONAL!",
    y = "Retention Rate (%)",
    x = ""
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  ylim(0, 75)
```

---

#### **Section 3: Demographic Segmentation**

```r
# Age group analysis
age_arpu <- execute_query(con, "
  SELECT 
    CASE 
      WHEN age < 18 THEN '<18'
      WHEN age BETWEEN 18 AND 25 THEN '18-25'
      WHEN age BETWEEN 26 AND 35 THEN '26-35'
      WHEN age BETWEEN 36 AND 45 THEN '36-45'
      ELSE '45+'
    END as age_group,
    COUNT(DISTINCT u.user_id) as users,
    COALESCE(SUM(p.amount) / COUNT(DISTINCT u.user_id), 0) as arpu,
    COUNT(DISTINCT CASE WHEN p.user_id IS NOT NULL THEN u.user_id END) * 100.0 / COUNT(DISTINCT u.user_id) as conversion_rate
  FROM users u
  LEFT JOIN purchases p ON u.user_id = p.user_id
  GROUP BY age_group
  ORDER BY 
    CASE age_group
      WHEN '<18' THEN 1
      WHEN '18-25' THEN 2
      WHEN '26-35' THEN 3
      WHEN '36-45' THEN 4
      ELSE 5
    END
")

View(age_arpu)

# Visualize
ggplot(age_arpu, aes(x = age_group, y = arpu, fill = age_group)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste0("$", round(arpu, 2))), vjust = -0.5, fontface = "bold") +
  labs(
    title = "ARPU by Age Group",
    subtitle = "18-25 age group spends most ($13.38 ARPU)",
    x = "Age Group",
    y = "ARPU ($)"
  ) +
  theme_minimal() +
  theme(legend.position = "none")
```

---

#### **Section 4: Statistical Testing**

```r
# Compare 18-25 vs 36-45 age groups (are they significantly different?)

# Get revenue per user for each group
age_18_25 <- execute_query(con, "
  SELECT COALESCE(SUM(p.amount), 0) as revenue
  FROM users u
  LEFT JOIN purchases p ON u.user_id = p.user_id
  WHERE u.age BETWEEN 18 AND 25
  GROUP BY u.user_id
")

age_36_45 <- execute_query(con, "
  SELECT COALESCE(SUM(p.amount), 0) as revenue
  FROM users u
  LEFT JOIN purchases p ON u.user_id = p.user_id
  WHERE u.age BETWEEN 36 AND 45
  GROUP BY u.user_id
")

# Perform t-test
t_test_result <- t.test(age_18_25$revenue, age_36_45$revenue)
print(t_test_result)

# Interpretation
if (t_test_result$p.value < 0.05) {
  print("✅ SIGNIFICANT DIFFERENCE: Age groups spend differently (p < 0.05)")
} else {
  print("❌ No significant difference detected")
}
```

**💡 Learning Point**: P-value < 0.05 means the difference is statistically significant, not due to chance.

---

## 🎨 Step 3: Create Custom Visualizations (Optional)

Try creating your own charts:

### Example: Revenue Over Time

```r
# Get monthly revenue
monthly_revenue <- execute_query(con, "
  SELECT 
    DATE_FORMAT(purchase_date, '%Y-%m') as month,
    SUM(amount) as revenue,
    COUNT(DISTINCT user_id) as paying_users
  FROM purchases
  GROUP BY month
  ORDER BY month
")

# Line chart
ggplot(monthly_revenue, aes(x = month, y = revenue, group = 1)) +
  geom_line(color = "darkgreen", size = 1.2) +
  geom_point(size = 3, color = "darkgreen") +
  labs(
    title = "Monthly Revenue Trend",
    subtitle = "Total revenue: $10,934.28 across 2022",
    x = "Month",
    y = "Revenue ($)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
```

### Example: Conversion Rate by Country Heatmap

```r
# Get data
country_conversion <- execute_query(con, "
  SELECT 
    country,
    COUNT(DISTINCT u.user_id) as users,
    COUNT(DISTINCT CASE WHEN p.user_id IS NOT NULL THEN u.user_id END) * 100.0 / COUNT(DISTINCT u.user_id) as conversion_rate
  FROM users u
  LEFT JOIN purchases p ON u.user_id = p.user_id
  GROUP BY country
  HAVING users >= 5
  ORDER BY conversion_rate DESC
  LIMIT 15
")

# Heatmap-style bar chart
ggplot(country_conversion, aes(x = reorder(country, conversion_rate), y = conversion_rate, fill = conversion_rate)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "yellow", high = "darkgreen") +
  coord_flip() +
  labs(
    title = "Conversion Rate by Country (Top 15)",
    subtitle = "Ireland leads at 70.6% conversion!",
    x = "Country",
    y = "Conversion Rate (%)"
  ) +
  theme_minimal()
```

---

## 📝 Step 4: Export Your Findings

### Save Visualizations

```r
# Export current plot
ggsave("my_analysis_chart.png", width = 12, height = 8, dpi = 300)
```

### Export Data to CSV

```r
# Save your query results
write.csv(country_arpu, "my_country_analysis.csv", row.names = FALSE)
write.csv(age_arpu, "my_age_analysis.csv", row.names = FALSE)
```

### Create Summary Report

```r
# Compile key metrics
summary_report <- data.frame(
  Metric = c("Total Users", "Total Revenue", "ARPU", "D7 Retention", "Conversion Rate"),
  Value = c(
    "1,007",
    "$10,934.28",
    "$10.86",
    "65.6%",
    "51.5%"
  ),
  Benchmark = c(
    "N/A",
    "N/A",
    "$1-5",
    "10-20%",
    "2-5%"
  ),
  Performance = c(
    "Excellent",
    "Strong",
    "2x above average",
    "3-6x above average",
    "10-25x above average"
  )
)

View(summary_report)
write.csv(summary_report, "my_kpi_summary.csv", row.names = FALSE)
```

---

## 🎯 Learning Checkpoints

After completing this guide, you should be able to:

- [  ] Connect R to MySQL database
- [  ] Write and execute SQL queries for KPIs
- [  ] Calculate descriptive statistics in R
- [  ] Create visualizations with ggplot2
- [  ] Calculate confidence intervals
- [  ] Perform t-tests for group comparisons
- [  ] Export charts as high-quality PNG files
- [  ] Export data to CSV for reports

---

## 🚀 Advanced Challenges (Optional)

If you want to go deeper:

1. **Create a Dashboard**: Use `flexdashboard` or `shiny` to create an interactive dashboard
2. **Predictive Modeling**: Build a model to predict which users will make purchases
3. **Cohort Analysis**: Track retention by registration month cohort
4. **A/B Test Simulation**: Compare metrics between two user groups
5. **Automated Reporting**: Schedule R scripts to run daily and email results

---

## 📚 Resources for Learning More

- **ggplot2 Tutorial**: https://r-graphics.org/
- **dplyr Cheatsheet**: https://dplyr.tidyverse.org/
- **Statistical Testing in R**: https://www.statmethods.net/stats/ttest.html
- **SQL for Data Analysis**: https://mode.com/sql-tutorial/

---

## ✅ Deliverables Checklist

- [  ] Ran SQL queries in SQL Workbench to understand data
- [  ] Executed R scripts interactively in RStudio
- [  ] Created at least 3 custom visualizations
- [  ] Calculated confidence intervals manually
- [  ] Performed at least one statistical test
- [  ] Exported charts and data files
- [  ] Documented key findings in your own words

---

**Next Step**: Once you've completed the hands-on exercises, you can use the pre-generated files from the automated analysis as your official deliverables, but you'll have learned the process by doing it yourself!

**Questions?** Try experimenting with the code - change colors, add labels, filter data differently. The best way to learn is by doing!

