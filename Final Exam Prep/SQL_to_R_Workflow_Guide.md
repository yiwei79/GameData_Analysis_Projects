# SQL → R Workflow Guide (Actual Exam Process)

**Purpose**: This is the EXACT workflow you'll use in tomorrow's exam
**Files**: sweet.sql (SQL database) → R (statistical analysis)

---

## Overview: How the Exam Works

In the exam, you'll receive:
1. **sweet.sql** file with game data
2. **Access to MySQL** database
3. **Access to R/RStudio** for statistical analysis

**Workflow**:
```
sweet.sql → Load into MySQL → Query with SQL → Export to R → Run statistical tests
```

---

## Option 1: Load SQL into MySQL (Most Realistic)

### Step 1: Load Data into MySQL Database

**If you have MySQL Workbench or command line access:**

```bash
# In Terminal/Command Line
mysql -u your_username -p your_database < sweet.sql

# OR in MySQL Workbench:
# File → Run SQL Script → Select sweet.sql
```

**Alternative: Use MySQL Workbench GUI**
1. Open MySQL Workbench
2. Connect to your database
3. File → Run SQL Script
4. Select `sweet.sql`
5. Execute

---

### Step 2: Verify Data Loaded

```sql
-- In MySQL Workbench or command line
USE your_database;

-- Check data loaded
SELECT COUNT(*) FROM game_sessions;
-- Expected: 200 rows

-- Preview data
SELECT * FROM game_sessions LIMIT 10;
```

---

### Step 3: Query Data for Q4 (Session Length Comparison)

**SQL Query for Q4**:
```sql
-- Get session lengths by group for t-test in R
SELECT
    test_group,
    session_length_minutes
FROM game_sessions
ORDER BY test_group;

-- Preview statistics
SELECT
    test_group,
    COUNT(*) as n,
    ROUND(AVG(session_length_minutes), 2) as avg_length,
    ROUND(STDDEV(session_length_minutes), 2) as std_dev
FROM game_sessions
GROUP BY test_group;
```

**Export results**: Save as CSV or copy to clipboard

---

### Step 4: Query Data for Q5 (A/B Testing)

**SQL Query for Q5**:
```sql
-- Get level 20 completion by group for chi-squared test in R
SELECT
    test_group,
    level_20_completed
FROM game_sessions
ORDER BY test_group;

-- Preview completion rates
SELECT
    test_group,
    COUNT(*) as total_attempts,
    SUM(level_20_completed) as completions,
    COUNT(*) - SUM(level_20_completed) as failures,
    ROUND(SUM(level_20_completed) * 100.0 / COUNT(*), 1) as completion_rate
FROM game_sessions
GROUP BY test_group;
```

---

### Step 5: Load Data into R

**Method 1: Direct MySQL connection in R** (Recommended for exam)

```r
# Install package if needed (only once)
# install.packages("RMySQL")

library(RMySQL)

# Connect to database
con <- dbConnect(MySQL(),
                 user = "your_username",
                 password = "your_password",
                 dbname = "your_database",
                 host = "localhost")

# Query data for Q4
q4_data <- dbGetQuery(con, "
    SELECT test_group, session_length_minutes
    FROM game_sessions
")

# Query data for Q5
q5_data <- dbGetQuery(con, "
    SELECT test_group, level_20_completed
    FROM game_sessions
")

# Close connection
dbDisconnect(con)

# Preview data
head(q4_data)
head(q5_data)
```

**Method 2: Export SQL results to CSV, then load in R**

```sql
-- In MySQL, export to CSV
SELECT * FROM game_sessions
INTO OUTFILE '/tmp/sweet_data.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

```r
# In R, load CSV
data <- read.csv("/tmp/sweet_data.csv", header = TRUE)
```

---

## Option 2: Quick Practice Setup (If No MySQL Access)

**If you don't have MySQL set up right now, use this quick method for practice:**

### Load SQL File Directly into R

```r
# Install package if needed
# install.packages("sqldf")

library(sqldf)

# Read the SQL file and create a SQLite database in memory
# First, let's load the data directly as CSV (I'll show you how below)

# For now, read the sweet.sql INSERT statements as data
# This is a workaround for practice without MySQL

# Create the data frame manually from SQL
sweet_data <- read.csv("Final Exam Prep/sweet_data.csv")

# OR create from the SQL file values (quick alternative)
# We'll provide a CSV export for quick practice
```

---

## Quick Start for YOUR Practice Session RIGHT NOW

**Since you want to start practicing immediately, I've created both options:**

### Quick Method (Use this for practice NOW):

```r
# In R console
setwd("/Users/yiwei/GithubRepos/GameData_Analysis_Projects/Final Exam Prep")

# Option A: Load from CSV (fastest)
sweet_data <- read.csv("sweet_data.csv")

# Option B: Query the SQL file using sqldf package
library(sqldf)
# Read data using SQL queries on the CSV
sweet_data <- read.csv.sql("sweet_data.csv")

# Verify loaded
head(sweet_data)
str(sweet_data)

# You're ready for Q4 and Q5!
```

---

## Practice Workflow for Q4 and Q5

### Q4: Session Length Comparison

```r
# Extract session lengths by group
group_a_sessions <- sweet_data$session_length_minutes[sweet_data$test_group == "A"]
group_b_sessions <- sweet_data$session_length_minutes[sweet_data$test_group == "B"]

# Run t-test
t_result <- t.test(group_a_sessions, group_b_sessions)
print(t_result)

# Interpret
p_value <- t_result$p.value
if (p_value < 0.05) {
    cat("SIGNIFICANT: Groups have different session lengths (p =", p_value, ")\n")
} else {
    cat("NOT SIGNIFICANT: No significant difference (p =", p_value, ")\n")
}
```

---

### Q5: A/B Testing - Level 20 Difficulty

```r
library(dplyr)

# Calculate success rates by group
group_summary <- sweet_data %>%
    group_by(test_group) %>%
    summarize(
        total = n(),
        successes = sum(level_20_completed),
        failures = sum(level_20_completed == 0),
        success_rate = mean(level_20_completed) * 100
    )

print(group_summary)

# Prepare contingency table
group_a <- group_summary %>% filter(test_group == "A")
group_b <- group_summary %>% filter(test_group == "B")

contingency_table <- matrix(
    c(group_a$successes, group_a$failures,
      group_b$successes, group_b$failures),
    nrow = 2,
    byrow = TRUE
)

rownames(contingency_table) <- c("Group_A_Easier", "Group_B_Harder")
colnames(contingency_table) <- c("Success", "Failure")

# Run chi-squared test
chi_result <- chisq.test(contingency_table)
print(chi_result)

# Interpret
p_value <- chi_result$p.value
if (p_value < 0.05) {
    cat("SIGNIFICANT: Difficulty level affects completion rate (p =", p_value, ")\n")
    cat("Recommendation: ",
        ifelse(group_a$success_rate > group_b$success_rate,
               "LOWER DIFFICULTY (implement easier version)",
               "KEEP ORIGINAL DIFFICULTY"), "\n")
} else {
    cat("NOT SIGNIFICANT: No clear difference (p =", p_value, ")\n")
}
```

---

## Tomorrow's Exam: Expected Data File

**The exam will give you**:
- A file called `sweet.sql` (or similar name)
- Instructions to load it into MySQL or use it directly
- You'll query it with SQL, then analyze in R

**Your workflow tomorrow**:
1. Load sweet.sql into MySQL (or read directly)
2. Write SQL queries to explore the data
3. Export relevant data for Q4 and Q5
4. Load into R using RMySQL or CSV
5. Run statistical tests (t-test for Q4, chi-squared for Q5)
6. Interpret results and write recommendations

---

## Files Created for You

✅ **sweet.sql** - Complete SQL database with 200 game sessions
- 100 Group A players (easier difficulty)
- 100 Group B players (harder difficulty)
- Session length data for Q4
- Level 20 completion data for Q5

✅ **sweet_data.csv** - CSV export (will be created when you run conversion)

✅ **This guide** - SQL → R workflow instructions

---

## Quick Commands Summary

**Load in MySQL**:
```bash
mysql -u username -p database < sweet.sql
```

**Load in R (from MySQL)**:
```r
library(RMySQL)
con <- dbConnect(MySQL(), user="username", password="password", dbname="database", host="localhost")
data <- dbGetQuery(con, "SELECT * FROM game_sessions")
dbDisconnect(con)
```

**Load in R (from CSV - quick practice)**:
```r
sweet_data <- read.csv("Final Exam Prep/sweet_data.csv")
```

**Now you're ready to practice Q4 and Q5 with REAL SQL data!** 🎯
