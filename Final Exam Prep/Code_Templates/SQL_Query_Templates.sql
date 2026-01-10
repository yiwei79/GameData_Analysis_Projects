-- ================================================================
-- SQL Query Templates for Data Analysis Exam
-- ================================================================
-- Purpose: Copy-paste ready SQL queries for Q2 and data analysis
-- Use: Adapt by changing table names, column names, conditions
-- ================================================================

-- ================================================================
-- TEMPLATE 1: DAU (Daily Active Users)
-- ================================================================
-- Description: Count unique users per day

SELECT
    DATE(session_start_time) AS date,
    COUNT(DISTINCT user_id) AS DAU
FROM sessions
GROUP BY DATE(session_start_time)
ORDER BY date;

-- ADAPT BY:
-- - Change 'session_start_time' to your date column
-- - Change 'user_id' to your user identifier column
-- - Change 'sessions' to your table name

-- ================================================================
-- TEMPLATE 2: MAU (Monthly Active Users)
-- ================================================================
-- Description: Count unique users per month

SELECT
    DATE_FORMAT(session_start_time, '%Y-%m') AS month,
    COUNT(DISTINCT user_id) AS MAU
FROM sessions
GROUP BY DATE_FORMAT(session_start_time, '%Y-%m')
ORDER BY month;

-- ADAPT BY:
-- - Change 'session_start_time' to your date column
-- - Change 'user_id' to your user identifier column
-- - Use '%Y' for year only, '%Y-%m-%d' for full date

-- ================================================================
-- TEMPLATE 3: ARPU (Average Revenue Per User)
-- ================================================================
-- Description: Total revenue divided by ALL users (paying + non-paying)

SELECT
    ROUND(SUM(transaction_amount) / COUNT(DISTINCT users.user_id), 2) AS ARPU
FROM users
LEFT JOIN transactions ON users.user_id = transactions.user_id;

-- KEY: Use LEFT JOIN to include ALL users (even non-paying)
-- KEY: Divide by COUNT(DISTINCT users.user_id) = total users

-- ================================================================
-- TEMPLATE 4: ARPPU (Average Revenue Per PAYING User)
-- ================================================================
-- Description: Total revenue divided by PAYING users only

SELECT
    ROUND(SUM(transaction_amount) / COUNT(DISTINCT user_id), 2) AS ARPPU
FROM transactions;

-- KEY: No JOIN needed, just query transactions table
-- KEY: Divide by COUNT(DISTINCT transactions.user_id) = paying users only
-- KEY: ARPU < ARPPU always (ARPU includes non-paying users)

-- ================================================================
-- TEMPLATE 5: Conversion Rate (% of Users Who Pay)
-- ================================================================
-- Description: Percentage of users who made at least one purchase

SELECT
    COUNT(DISTINCT paying_users.user_id) * 100.0 / COUNT(DISTINCT all_users.user_id) AS conversion_rate
FROM
    (SELECT DISTINCT user_id FROM users) AS all_users
LEFT JOIN
    (SELECT DISTINCT user_id FROM transactions) AS paying_users
ON all_users.user_id = paying_users.user_id;

-- KEY: Multiply by 100.0 (not 100) to get percentage with decimals

-- Alternative simpler version if you have a transactions table:
SELECT
    (SELECT COUNT(DISTINCT user_id) FROM transactions) * 100.0 /
    (SELECT COUNT(DISTINCT user_id) FROM users) AS conversion_rate;

-- ================================================================
-- TEMPLATE 6: D1 Retention (Day 1 Retention Rate)
-- ================================================================
-- Description: % of new users who return the day after registration

-- Step 1: Create view of user signup dates
CREATE VIEW user_cohorts AS
SELECT
    user_id,
    DATE(registration_date) AS signup_date
FROM users;

-- Step 2: Create view of all session dates per user
CREATE VIEW user_session_dates AS
SELECT DISTINCT
    user_id,
    DATE(session_start) AS session_date
FROM sessions;

-- Step 3: Check if user returned on D1 (signup_date + 1 day)
SELECT
    uc.user_id,
    uc.signup_date,
    CASE
        WHEN usd.session_date = DATE_ADD(uc.signup_date, INTERVAL 1 DAY) THEN 1
        ELSE 0
    END AS returned_d1
FROM user_cohorts uc
LEFT JOIN user_session_dates usd
    ON uc.user_id = usd.user_id
    AND usd.session_date = DATE_ADD(uc.signup_date, INTERVAL 1 DAY);

-- Step 4: Calculate D1 retention rate
SELECT
    COUNT(CASE WHEN returned_d1 = 1 THEN 1 END) * 100.0 / COUNT(*) AS d1_retention_rate
FROM d1_return_status;

-- For D3: Change INTERVAL 1 DAY to INTERVAL 3 DAY
-- For D7: Change INTERVAL 1 DAY to INTERVAL 7 DAY

-- ================================================================
-- TEMPLATE 7: Average Session Duration
-- ================================================================
-- Description: Average time users spend in a session

SELECT
    ROUND(AVG(TIMESTAMPDIFF(SECOND, start_time, end_time)), 2) AS avg_duration_seconds
FROM sessions
WHERE end_time IS NOT NULL;

-- Convert to minutes: divide by 60
SELECT
    ROUND(AVG(TIMESTAMPDIFF(SECOND, start_time, end_time)) / 60, 2) AS avg_duration_minutes
FROM sessions
WHERE end_time IS NOT NULL;

-- Convert to hours: divide by 3600
SELECT
    ROUND(AVG(TIMESTAMPDIFF(SECOND, start_time, end_time)) / 3600, 2) AS avg_duration_hours
FROM sessions
WHERE end_time IS NOT NULL;

-- KEY: Always filter WHERE end_time IS NOT NULL to avoid errors

-- ================================================================
-- TEMPLATE 8: Session Count Per User
-- ================================================================
-- Description: Number of sessions for each user

SELECT
    user_id,
    COUNT(session_id) AS session_count
FROM sessions
GROUP BY user_id
ORDER BY session_count DESC;

-- For average sessions per user:
SELECT
    ROUND(AVG(session_count), 2) AS avg_sessions_per_user
FROM (
    SELECT user_id, COUNT(session_id) AS session_count
    FROM sessions
    GROUP BY user_id
) AS user_session_counts;

-- ================================================================
-- TEMPLATE 9: LEFT JOIN Pattern (CRITICAL for exam!)
-- ================================================================
-- Description: Keep ALL users even if they have no sessions

SELECT
    u.user_id,
    u.username,
    COUNT(s.session_id) AS session_count
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id
GROUP BY u.user_id, u.username
ORDER BY session_count DESC;

-- KEY DIFFERENCE:
-- LEFT JOIN: Returns ALL users (0 sessions counted as 0)
-- INNER JOIN: Returns ONLY users who have at least 1 session

-- Common exam question: "How many rows will this query return?"
-- LEFT JOIN: Returns number of rows in LEFT table (users)
-- INNER JOIN: Returns number of matching rows only

-- ================================================================
-- TEMPLATE 10: Date Filtering
-- ================================================================
-- Description: Filter data by date ranges

-- Filter by date range
SELECT *
FROM sessions
WHERE DATE(start_time) BETWEEN '2020-01-01' AND '2020-12-31';

-- Filter by specific month
SELECT *
FROM sessions
WHERE DATE_FORMAT(start_time, '%Y-%m') = '2020-06';

-- Filter by specific year
SELECT *
FROM sessions
WHERE YEAR(start_time) = 2020;

-- Filter last 30 days
SELECT *
FROM sessions
WHERE DATE(start_time) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- ================================================================
-- TEMPLATE 11: Revenue by Item (Sales Analysis)
-- ================================================================
-- Description: Total revenue and count per item

SELECT
    item_id,
    COUNT(*) AS purchase_count,
    SUM(amount) AS total_revenue,
    ROUND(AVG(amount), 2) AS avg_price
FROM transactions
GROUP BY item_id
ORDER BY total_revenue DESC;

-- With item names (JOIN with items table):
SELECT
    i.item_name,
    COUNT(t.transaction_id) AS purchase_count,
    SUM(t.amount) AS total_revenue,
    ROUND(AVG(t.amount), 2) AS avg_price
FROM items i
LEFT JOIN transactions t ON i.item_id = t.item_id
GROUP BY i.item_id, i.item_name
ORDER BY total_revenue DESC;

-- ================================================================
-- TEMPLATE 12: User Demographics Breakdown
-- ================================================================
-- Description: User count by country, age, gender, etc.

-- By country
SELECT
    country,
    COUNT(*) AS user_count
FROM users
GROUP BY country
ORDER BY user_count DESC;

-- By age group
SELECT
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        ELSE '45+'
    END AS age_group,
    COUNT(*) AS user_count
FROM users
GROUP BY age_group
ORDER BY age_group;

-- ================================================================
-- TEMPLATE 13: Top N Users by Metric
-- ================================================================
-- Description: Find top users by revenue, sessions, etc.

-- Top 10 users by revenue
SELECT
    u.user_id,
    u.username,
    SUM(t.amount) AS total_spent
FROM users u
JOIN transactions t ON u.user_id = t.user_id
GROUP BY u.user_id, u.username
ORDER BY total_spent DESC
LIMIT 10;

-- Top 10 users by session count
SELECT
    u.user_id,
    u.username,
    COUNT(s.session_id) AS session_count
FROM users u
JOIN sessions s ON u.user_id = s.user_id
GROUP BY u.user_id, u.username
ORDER BY session_count DESC
LIMIT 10;

-- ================================================================
-- TEMPLATE 14: Cohort Analysis (Users by Signup Month)
-- ================================================================
-- Description: Group users by when they signed up

SELECT
    DATE_FORMAT(registration_date, '%Y-%m') AS cohort_month,
    COUNT(*) AS new_users
FROM users
GROUP BY cohort_month
ORDER BY cohort_month;

-- ================================================================
-- TEMPLATE 15: Funnel Analysis (Multi-Step Conversion)
-- ================================================================
-- Description: Track users through multiple steps

SELECT
    'Step 1: Registered' AS step,
    COUNT(DISTINCT user_id) AS user_count
FROM users

UNION ALL

SELECT
    'Step 2: First Session' AS step,
    COUNT(DISTINCT user_id) AS user_count
FROM sessions

UNION ALL

SELECT
    'Step 3: Made Purchase' AS step,
    COUNT(DISTINCT user_id) AS user_count
FROM transactions;

-- ================================================================
-- KEY SQL PATTERNS TO REMEMBER
-- ================================================================

-- COUNT vs COUNT DISTINCT
-- -----------------------------------------------
COUNT(user_id)              -- Counts ALL rows (including duplicates)
COUNT(DISTINCT user_id)     -- Counts UNIQUE users only
-- ALWAYS use COUNT DISTINCT for user-level metrics (DAU, MAU)

-- Date Functions
-- -----------------------------------------------
DATE(timestamp_column)                      -- Extract date: 2020-01-15
DATE_FORMAT(timestamp_column, '%Y-%m')      -- Format: 2020-01
DATE_FORMAT(timestamp_column, '%Y')         -- Extract year: 2020
YEAR(timestamp_column)                      -- Extract year: 2020
MONTH(timestamp_column)                     -- Extract month: 1-12
DAY(timestamp_column)                       -- Extract day: 1-31
TIMESTAMPDIFF(SECOND, start, end)           -- Difference in seconds
TIMESTAMPDIFF(MINUTE, start, end)           -- Difference in minutes
DATE_ADD(date, INTERVAL 1 DAY)              -- Add 1 day
DATE_SUB(date, INTERVAL 1 DAY)              -- Subtract 1 day

-- Percentage Calculation
-- -----------------------------------------------
ROUND(numerator * 100.0 / denominator, 2)   -- ALWAYS use 100.0 (not 100)
-- Using 100.0 ensures decimal division, not integer division

-- NULL Handling
-- -----------------------------------------------
COALESCE(column, 0)                         -- Replace NULL with 0
WHERE column IS NOT NULL                    -- Filter out NULLs
WHERE column IS NULL                        -- Filter only NULLs

-- CASE WHEN (Conditional Logic)
-- -----------------------------------------------
CASE
    WHEN condition1 THEN value1
    WHEN condition2 THEN value2
    ELSE default_value
END AS new_column_name

-- Example: Categorize age
CASE
    WHEN age < 18 THEN 'Minor'
    WHEN age >= 18 AND age < 65 THEN 'Adult'
    ELSE 'Senior'
END AS age_category

-- ================================================================
-- JOIN TYPES COMPARISON
-- ================================================================

-- INNER JOIN: Only matching rows from both tables
SELECT *
FROM users u
INNER JOIN sessions s ON u.user_id = s.user_id;
-- Returns: Only users who have at least 1 session

-- LEFT JOIN: All rows from left table + matching from right
SELECT *
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id;
-- Returns: ALL users, with NULL for users who have no sessions

-- RIGHT JOIN: All rows from right table + matching from left
SELECT *
FROM users u
RIGHT JOIN sessions s ON u.user_id = s.user_id;
-- Returns: ALL sessions, with NULL for sessions with no user match

-- Common Exam Question:
-- "How many rows will this query return?"
-- - INNER JOIN: Depends on matches (often less than either table)
-- - LEFT JOIN: Same as left table row count
-- - RIGHT JOIN: Same as right table row count

-- ================================================================
-- AGGREGATION FUNCTIONS
-- ================================================================

COUNT(*)                        -- Count all rows
COUNT(column)                   -- Count non-NULL values
COUNT(DISTINCT column)          -- Count unique values
SUM(column)                     -- Sum of values
AVG(column)                     -- Average of values
MIN(column)                     -- Minimum value
MAX(column)                     -- Maximum value
ROUND(column, decimals)         -- Round to N decimal places

-- Example: Multiple aggregations
SELECT
    user_id,
    COUNT(*) AS total_sessions,
    SUM(revenue) AS total_revenue,
    AVG(session_length) AS avg_session_length,
    MIN(session_date) AS first_session,
    MAX(session_date) AS last_session
FROM sessions
GROUP BY user_id;

-- ================================================================
-- SUBQUERY PATTERNS
-- ================================================================

-- Subquery in SELECT (scalar subquery)
SELECT
    user_id,
    (SELECT COUNT(*) FROM sessions WHERE sessions.user_id = users.user_id) AS session_count
FROM users;

-- Subquery in FROM (derived table)
SELECT
    AVG(session_count) AS avg_sessions_per_user
FROM (
    SELECT user_id, COUNT(*) AS session_count
    FROM sessions
    GROUP BY user_id
) AS user_sessions;

-- Subquery in WHERE (filter)
SELECT *
FROM users
WHERE user_id IN (SELECT DISTINCT user_id FROM transactions);

-- ================================================================
-- COMMON EXAM GOTCHAS
-- ================================================================

-- GOTCHA 1: COUNT(*) vs COUNT(column)
SELECT COUNT(*) FROM sessions;              -- Counts all rows
SELECT COUNT(end_time) FROM sessions;       -- Counts only non-NULL end_time
-- If end_time can be NULL, these give different results!

-- GOTCHA 2: Integer division
SELECT 5 / 2;                               -- Returns 2 (integer)
SELECT 5.0 / 2;                             -- Returns 2.5 (decimal)
SELECT 5 * 100 / 2;                         -- Returns 250 (int)
SELECT 5 * 100.0 / 2;                       -- Returns 250.0 (decimal)
-- ALWAYS use .0 for percentage calculations!

-- GOTCHA 3: GROUP BY with aggregation
-- Rule: Every column in SELECT must be either:
-- (1) In GROUP BY clause, OR
-- (2) Inside an aggregation function

-- CORRECT:
SELECT country, COUNT(*) AS user_count
FROM users
GROUP BY country;

-- WRONG:
SELECT country, username, COUNT(*) AS user_count
FROM users
GROUP BY country;
-- Error: 'username' is not in GROUP BY or aggregation

-- GOTCHA 4: LEFT JOIN with WHERE
SELECT *
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id
WHERE s.session_id IS NOT NULL;
-- This actually behaves like INNER JOIN!
-- Because WHERE filters out NULL sessions from LEFT JOIN

-- To keep NULL sessions, use:
SELECT *
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id AND s.session_type = 'active';

-- ================================================================
-- EXAM TIPS
-- ================================================================

-- 1. Always verify table and column names
SHOW TABLES;
DESCRIBE table_name;
SHOW COLUMNS FROM table_name;

-- 2. Test with LIMIT first
SELECT * FROM large_table LIMIT 10;

-- 3. Use meaningful aliases
SELECT
    u.user_id,
    s.session_id
FROM users AS u
LEFT JOIN sessions AS s ON u.user_id = s.user_id;

-- 4. Format for readability
-- Good:
SELECT
    user_id,
    COUNT(*) AS session_count
FROM sessions
WHERE DATE(start_time) >= '2020-01-01'
GROUP BY user_id
ORDER BY session_count DESC;

-- Bad:
SELECT user_id, COUNT(*) AS session_count FROM sessions WHERE DATE(start_time) >= '2020-01-01' GROUP BY user_id ORDER BY session_count DESC;

-- 5. Comment your queries
-- Calculate ARPU (Average Revenue Per User)
SELECT ROUND(SUM(amount) / COUNT(DISTINCT user_id), 2) AS ARPU
FROM users
LEFT JOIN transactions ON users.user_id = transactions.user_id;

-- ================================================================
-- QUICK REFERENCE CARD
-- ================================================================

-- User Metrics:
-- DAU: COUNT(DISTINCT user_id) per DATE(session_date)
-- MAU: COUNT(DISTINCT user_id) per DATE_FORMAT(date, '%Y-%m')
-- New Users: COUNT(*) FROM users WHERE DATE(registration_date) = '2020-01-01'

-- Revenue Metrics:
-- ARPU: SUM(revenue) / COUNT(DISTINCT all_users)
-- ARPPU: SUM(revenue) / COUNT(DISTINCT paying_users)
-- Total Revenue: SUM(transaction_amount)

-- Engagement Metrics:
-- Avg Session Duration: AVG(TIMESTAMPDIFF(SECOND, start, end))
-- Sessions per User: COUNT(sessions) / COUNT(DISTINCT users)

-- Retention:
-- D1: Count users with session on (signup_date + 1 day) / Total new users

-- ================================================================
-- END OF SQL TEMPLATES
-- ================================================================

-- Use Ctrl+F / Cmd+F to search for keywords:
-- - Template numbers (TEMPLATE 1, TEMPLATE 2, etc.)
-- - Metrics (DAU, MAU, ARPU, retention, etc.)
-- - Operations (JOIN, GROUP BY, CASE WHEN, etc.)
