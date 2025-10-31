-- =====================================================
-- KPI Queries Library - Part 2
-- Game Analytics Pipeline
-- =====================================================
-- Comprehensive SQL queries for calculating KPIs
-- Organized by category for easy navigation
-- All queries are compatible with MySQL syntax
-- =====================================================

-- =====================================================
-- SECTION 1: DATA QUALITY & VALIDATION
-- =====================================================

-- Query 1.1: Table Record Counts
-- Purpose: Verify data collection success
SELECT 
    'users' as table_name, COUNT(*) as row_count FROM users
UNION ALL
SELECT 'sessions', COUNT(*) FROM sessions
UNION ALL
SELECT 'purchases', COUNT(*) FROM purchases
UNION ALL
SELECT 'items', COUNT(*) FROM items;

-- Query 1.2: Date Range Coverage
-- Purpose: Understand temporal scope of data
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
FROM sessions
UNION ALL
SELECT 
    'purchases',
    MIN(purchase_date),
    MAX(purchase_date),
    DATEDIFF(MAX(purchase_date), MIN(purchase_date))
FROM purchases;

-- Query 1.3: Check for Orphaned Sessions
-- Purpose: Verify referential integrity
SELECT COUNT(*) as orphaned_sessions
FROM sessions s
LEFT JOIN users u ON s.user_id = u.user_id
WHERE u.user_id IS NULL;

-- Query 1.4: Check for Orphaned Purchases
-- Purpose: Verify referential integrity
SELECT COUNT(*) as orphaned_purchases
FROM purchases p
LEFT JOIN sessions s ON p.session_id = s.session_id
WHERE s.session_id IS NULL;

-- Query 1.5: Sessions with NULL duration
-- Purpose: Identify incomplete sessions
SELECT COUNT(*) as incomplete_sessions
FROM sessions
WHERE end_time IS NULL OR duration_seconds IS NULL;


-- =====================================================
-- SECTION 2: USER ENGAGEMENT METRICS
-- =====================================================

-- Query 2.1: Daily Active Users (DAU)
-- Purpose: Track daily engagement over time
SELECT 
    DATE(start_time) as date,
    COUNT(DISTINCT user_id) as dau
FROM sessions
GROUP BY DATE(start_time)
ORDER BY date;

-- Query 2.2: Weekly Active Users (WAU)
-- Purpose: Track weekly engagement
SELECT 
    YEARWEEK(start_time) as year_week,
    DATE(MIN(start_time)) as week_start,
    COUNT(DISTINCT user_id) as wau
FROM sessions
GROUP BY YEARWEEK(start_time)
ORDER BY year_week;

-- Query 2.3: Monthly Active Users (MAU)
-- Purpose: Track monthly engagement
SELECT 
    DATE_FORMAT(start_time, '%Y-%m') as month,
    COUNT(DISTINCT user_id) as mau
FROM sessions
GROUP BY DATE_FORMAT(start_time, '%Y-%m')
ORDER BY month;

-- Query 2.4: Stickiness Ratio (DAU/MAU)
-- Purpose: Measure user engagement quality
WITH daily_users AS (
    SELECT 
        DATE(start_time) as date,
        DATE_FORMAT(start_time, '%Y-%m') as month,
        COUNT(DISTINCT user_id) as dau
    FROM sessions
    GROUP BY DATE(start_time), DATE_FORMAT(start_time, '%Y-%m')
),
monthly_users AS (
    SELECT 
        DATE_FORMAT(start_time, '%Y-%m') as month,
        COUNT(DISTINCT user_id) as mau
    FROM sessions
    GROUP BY DATE_FORMAT(start_time, '%Y-%m')
)
SELECT 
    d.month,
    AVG(d.dau) as avg_dau,
    m.mau,
    (AVG(d.dau) / m.mau) * 100 as stickiness_ratio
FROM daily_users d
JOIN monthly_users m ON d.month = m.month
GROUP BY d.month, m.mau
ORDER BY d.month;

-- Query 2.5: Total Unique Users
-- Purpose: Overall user base size
SELECT COUNT(DISTINCT user_id) as total_users
FROM users;


-- =====================================================
-- SECTION 3: RETENTION METRICS
-- =====================================================

-- Query 3.1: D1 Retention (Day 1)
-- Purpose: % of users who return 1 day after registration
WITH first_sessions AS (
    SELECT 
        u.user_id,
        DATE(u.registration_date) as registration_date,
        MIN(DATE(s.start_time)) as first_session_date
    FROM users u
    LEFT JOIN sessions s ON u.user_id = s.user_id
    GROUP BY u.user_id, DATE(u.registration_date)
),
day1_returns AS (
    SELECT DISTINCT 
        fs.user_id
    FROM first_sessions fs
    INNER JOIN sessions s ON fs.user_id = s.user_id
    WHERE DATE(s.start_time) = DATE_ADD(fs.registration_date, INTERVAL 1 DAY)
)
SELECT 
    COUNT(DISTINCT d1.user_id) as d1_returners,
    COUNT(DISTINCT fs.user_id) as total_users,
    (COUNT(DISTINCT d1.user_id) * 100.0 / COUNT(DISTINCT fs.user_id)) as d1_retention_pct
FROM first_sessions fs
LEFT JOIN day1_returns d1 ON fs.user_id = d1.user_id;

-- Query 3.2: D3 Retention (Day 3)
-- Purpose: % of users who return 3 days after registration
WITH first_sessions AS (
    SELECT 
        u.user_id,
        DATE(u.registration_date) as registration_date
    FROM users u
),
day3_returns AS (
    SELECT DISTINCT 
        fs.user_id
    FROM first_sessions fs
    INNER JOIN sessions s ON fs.user_id = s.user_id
    WHERE DATEDIFF(DATE(s.start_time), fs.registration_date) >= 1
      AND DATEDIFF(DATE(s.start_time), fs.registration_date) <= 3
)
SELECT 
    COUNT(DISTINCT d3.user_id) as d3_returners,
    COUNT(DISTINCT fs.user_id) as total_users,
    (COUNT(DISTINCT d3.user_id) * 100.0 / COUNT(DISTINCT fs.user_id)) as d3_retention_pct
FROM first_sessions fs
LEFT JOIN day3_returns d3 ON fs.user_id = d3.user_id;

-- Query 3.3: D7 Retention (Day 7)
-- Purpose: % of users who return 7 days after registration
WITH first_sessions AS (
    SELECT 
        u.user_id,
        DATE(u.registration_date) as registration_date
    FROM users u
),
day7_returns AS (
    SELECT DISTINCT 
        fs.user_id
    FROM first_sessions fs
    INNER JOIN sessions s ON fs.user_id = s.user_id
    WHERE DATEDIFF(DATE(s.start_time), fs.registration_date) >= 1
      AND DATEDIFF(DATE(s.start_time), fs.registration_date) <= 7
)
SELECT 
    COUNT(DISTINCT d7.user_id) as d7_returners,
    COUNT(DISTINCT fs.user_id) as total_users,
    (COUNT(DISTINCT d7.user_id) * 100.0 / COUNT(DISTINCT fs.user_id)) as d7_retention_pct
FROM first_sessions fs
LEFT JOIN day7_returns d7 ON fs.user_id = d7.user_id;

-- Query 3.4: Cohort Retention Analysis
-- Purpose: Track retention by registration cohort (month)
WITH cohorts AS (
    SELECT 
        user_id,
        DATE_FORMAT(registration_date, '%Y-%m') as cohort_month,
        registration_date
    FROM users
),
cohort_activity AS (
    SELECT 
        c.cohort_month,
        c.user_id,
        TIMESTAMPDIFF(MONTH, c.registration_date, s.start_time) as months_since_registration
    FROM cohorts c
    LEFT JOIN sessions s ON c.user_id = s.user_id
)
SELECT 
    cohort_month,
    months_since_registration,
    COUNT(DISTINCT user_id) as active_users
FROM cohort_activity
WHERE months_since_registration >= 0
GROUP BY cohort_month, months_since_registration
ORDER BY cohort_month, months_since_registration;

-- Query 3.5: User Lifecycle Stages
-- Purpose: Categorize users by engagement level
SELECT 
    CASE 
        WHEN session_count = 0 THEN 'Never Active'
        WHEN session_count = 1 THEN 'One-Time User'
        WHEN session_count BETWEEN 2 AND 5 THEN 'Casual User'
        WHEN session_count BETWEEN 6 AND 10 THEN 'Regular User'
        ELSE 'Power User'
    END as user_stage,
    COUNT(*) as user_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM users)) as percentage
FROM (
    SELECT 
        u.user_id,
        COUNT(s.session_id) as session_count
    FROM users u
    LEFT JOIN sessions s ON u.user_id = s.user_id
    GROUP BY u.user_id
) user_sessions
GROUP BY user_stage
ORDER BY 
    CASE user_stage
        WHEN 'Never Active' THEN 1
        WHEN 'One-Time User' THEN 2
        WHEN 'Casual User' THEN 3
        WHEN 'Regular User' THEN 4
        WHEN 'Power User' THEN 5
    END;


-- =====================================================
-- SECTION 4: MONETIZATION METRICS
-- =====================================================

-- Query 4.1: ARPU (Average Revenue Per User)
-- Purpose: Total revenue divided by all users
SELECT 
    COALESCE(SUM(p.amount), 0) as total_revenue,
    COUNT(DISTINCT u.user_id) as total_users,
    COALESCE(SUM(p.amount), 0) / COUNT(DISTINCT u.user_id) as arpu
FROM users u
LEFT JOIN purchases p ON u.user_id = p.user_id;

-- Query 4.2: ARPPU (Average Revenue Per Paying User)
-- Purpose: Average revenue from users who made at least one purchase
SELECT 
    COUNT(DISTINCT user_id) as paying_users,
    SUM(total_spent) as total_revenue,
    AVG(total_spent) as arppu,
    MIN(total_spent) as min_spent,
    MAX(total_spent) as max_spent
FROM (
    SELECT 
        user_id,
        SUM(amount) as total_spent
    FROM purchases
    GROUP BY user_id
) paying_user_revenue;

-- Query 4.3: Conversion Rate
-- Purpose: % of users who made at least one purchase
SELECT 
    COUNT(DISTINCT u.user_id) as total_users,
    COUNT(DISTINCT p.user_id) as paying_users,
    (COUNT(DISTINCT p.user_id) * 100.0 / COUNT(DISTINCT u.user_id)) as conversion_rate_pct
FROM users u
LEFT JOIN purchases p ON u.user_id = p.user_id;

-- Query 4.4: Revenue by Item Type
-- Purpose: Identify most profitable items
SELECT 
    i.item_id,
    i.item_name,
    i.price as catalog_price,
    COUNT(p.purchase_id) as purchase_count,
    SUM(p.amount) as total_revenue,
    AVG(p.amount) as avg_transaction_value
FROM items i
LEFT JOIN purchases p ON i.item_id = p.item_id
GROUP BY i.item_id, i.item_name, i.price
ORDER BY total_revenue DESC;

-- Query 4.5: Revenue Concentration (Whale Analysis)
-- Purpose: Analyze revenue distribution (top 10% vs rest)
WITH user_revenue AS (
    SELECT 
        user_id,
        SUM(amount) as total_spent,
        COUNT(*) as purchase_count
    FROM purchases
    GROUP BY user_id
),
revenue_percentiles AS (
    SELECT 
        user_id,
        total_spent,
        purchase_count,
        NTILE(10) OVER (ORDER BY total_spent DESC) as decile
    FROM user_revenue
)
SELECT 
    CASE 
        WHEN decile = 1 THEN 'Top 10% (Whales)'
        WHEN decile <= 3 THEN 'Top 30% (Dolphins)'
        ELSE 'Bottom 70% (Minnows)'
    END as user_segment,
    COUNT(*) as user_count,
    SUM(total_spent) as segment_revenue,
    AVG(total_spent) as avg_revenue_per_user,
    (SUM(total_spent) * 100.0 / (SELECT SUM(total_spent) FROM user_revenue)) as pct_total_revenue
FROM revenue_percentiles
GROUP BY 
    CASE 
        WHEN decile = 1 THEN 'Top 10% (Whales)'
        WHEN decile <= 3 THEN 'Top 30% (Dolphins)'
        ELSE 'Bottom 70% (Minnows)'
    END
ORDER BY segment_revenue DESC;

-- Query 4.6: Lifetime Value (LTV) Estimate
-- Purpose: Estimate user value over entire lifecycle
SELECT 
    AVG(total_revenue) as avg_ltv,
    MIN(total_revenue) as min_ltv,
    MAX(total_revenue) as max_ltv,
    STDDEV(total_revenue) as ltv_std_dev
FROM (
    SELECT 
        u.user_id,
        COALESCE(SUM(p.amount), 0) as total_revenue
    FROM users u
    LEFT JOIN purchases p ON u.user_id = p.user_id
    GROUP BY u.user_id
) user_ltv;

-- Query 4.7: Revenue Over Time
-- Purpose: Track daily revenue trends
SELECT 
    DATE(purchase_date) as date,
    COUNT(DISTINCT user_id) as paying_users,
    COUNT(*) as transaction_count,
    SUM(amount) as daily_revenue,
    AVG(amount) as avg_transaction_value
FROM purchases
GROUP BY DATE(purchase_date)
ORDER BY date;


-- =====================================================
-- SECTION 5: SESSION METRICS
-- =====================================================

-- Query 5.1: Average Sessions Per User
-- Purpose: Measure user engagement frequency
SELECT 
    COUNT(DISTINCT s.session_id) as total_sessions,
    COUNT(DISTINCT u.user_id) as total_users,
    COUNT(DISTINCT s.session_id) / COUNT(DISTINCT u.user_id) as avg_sessions_per_user
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id;

-- Query 5.2: Average Session Duration
-- Purpose: Measure typical session length
SELECT 
    COUNT(*) as sessions_with_duration,
    AVG(duration_seconds) as avg_duration_seconds,
    AVG(duration_seconds) / 60 as avg_duration_minutes,
    MIN(duration_seconds) as min_duration_seconds,
    MAX(duration_seconds) as max_duration_seconds,
    STDDEV(duration_seconds) as std_dev_seconds
FROM sessions
WHERE duration_seconds IS NOT NULL;

-- Query 5.3: Session Duration Distribution
-- Purpose: Understand session length patterns
SELECT 
    CASE 
        WHEN duration_seconds < 60 THEN '<1 min'
        WHEN duration_seconds < 180 THEN '1-3 min'
        WHEN duration_seconds < 300 THEN '3-5 min'
        WHEN duration_seconds < 600 THEN '5-10 min'
        WHEN duration_seconds < 1800 THEN '10-30 min'
        ELSE '30+ min'
    END as duration_bucket,
    COUNT(*) as session_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM sessions WHERE duration_seconds IS NOT NULL)) as percentage
FROM sessions
WHERE duration_seconds IS NOT NULL
GROUP BY 
    CASE 
        WHEN duration_seconds < 60 THEN '<1 min'
        WHEN duration_seconds < 180 THEN '1-3 min'
        WHEN duration_seconds < 300 THEN '3-5 min'
        WHEN duration_seconds < 600 THEN '5-10 min'
        WHEN duration_seconds < 1800 THEN '10-30 min'
        ELSE '30+ min'
    END
ORDER BY 
    CASE duration_bucket
        WHEN '<1 min' THEN 1
        WHEN '1-3 min' THEN 2
        WHEN '3-5 min' THEN 3
        WHEN '5-10 min' THEN 4
        WHEN '10-30 min' THEN 5
        ELSE 6
    END;

-- Query 5.4: Sessions Per User Distribution
-- Purpose: Understand user engagement frequency distribution
SELECT 
    session_count_bucket,
    COUNT(*) as user_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM users)) as percentage
FROM (
    SELECT 
        u.user_id,
        CASE 
            WHEN COUNT(s.session_id) = 0 THEN '0 sessions'
            WHEN COUNT(s.session_id) = 1 THEN '1 session'
            WHEN COUNT(s.session_id) BETWEEN 2 AND 5 THEN '2-5 sessions'
            WHEN COUNT(s.session_id) BETWEEN 6 AND 10 THEN '6-10 sessions'
            WHEN COUNT(s.session_id) BETWEEN 11 AND 20 THEN '11-20 sessions'
            ELSE '20+ sessions'
        END as session_count_bucket
    FROM users u
    LEFT JOIN sessions s ON u.user_id = s.user_id
    GROUP BY u.user_id
) user_session_counts
GROUP BY session_count_bucket
ORDER BY 
    CASE session_count_bucket
        WHEN '0 sessions' THEN 1
        WHEN '1 session' THEN 2
        WHEN '2-5 sessions' THEN 3
        WHEN '6-10 sessions' THEN 4
        WHEN '11-20 sessions' THEN 5
        ELSE 6
    END;

-- Query 5.5: Time-of-Day Analysis
-- Purpose: Identify peak playing hours
SELECT 
    HOUR(start_time) as hour_of_day,
    COUNT(*) as session_count,
    COUNT(DISTINCT user_id) as unique_users,
    AVG(duration_seconds) / 60 as avg_duration_minutes
FROM sessions
GROUP BY HOUR(start_time)
ORDER BY hour_of_day;


-- =====================================================
-- SECTION 6: DEMOGRAPHIC SEGMENTATION - COUNTRY
-- =====================================================

-- Query 6.1: User Count by Country
-- Purpose: Geographic distribution of user base
SELECT 
    country,
    COUNT(*) as user_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM users)) as percentage
FROM users
GROUP BY country
ORDER BY user_count DESC;

-- Query 6.2: ARPU by Country
-- Purpose: Revenue performance by geography
SELECT 
    u.country,
    COUNT(DISTINCT u.user_id) as total_users,
    COUNT(DISTINCT p.user_id) as paying_users,
    COALESCE(SUM(p.amount), 0) as total_revenue,
    COALESCE(SUM(p.amount), 0) / COUNT(DISTINCT u.user_id) as arpu,
    (COUNT(DISTINCT p.user_id) * 100.0 / COUNT(DISTINCT u.user_id)) as conversion_rate
FROM users u
LEFT JOIN purchases p ON u.user_id = p.user_id
GROUP BY u.country
ORDER BY arpu DESC;

-- Query 6.3: Engagement by Country
-- Purpose: Session metrics by geography
SELECT 
    u.country,
    COUNT(DISTINCT u.user_id) as total_users,
    COUNT(s.session_id) as total_sessions,
    COUNT(s.session_id) / COUNT(DISTINCT u.user_id) as avg_sessions_per_user,
    AVG(s.duration_seconds) / 60 as avg_session_minutes
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id
WHERE s.duration_seconds IS NOT NULL
GROUP BY u.country
ORDER BY avg_sessions_per_user DESC;


-- =====================================================
-- SECTION 7: DEMOGRAPHIC SEGMENTATION - AGE
-- =====================================================

-- Query 7.1: User Count by Age Group
-- Purpose: Age distribution of user base
SELECT 
    CASE 
        WHEN age < 18 THEN '<18'
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '45+'
    END as age_group,
    COUNT(*) as user_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM users)) as percentage,
    AVG(age) as avg_age
FROM users
GROUP BY age_group
ORDER BY 
    CASE age_group
        WHEN '<18' THEN 1
        WHEN '18-25' THEN 2
        WHEN '26-35' THEN 3
        WHEN '36-45' THEN 4
        ELSE 5
    END;

-- Query 7.2: ARPU by Age Group
-- Purpose: Revenue performance by age segment
SELECT 
    CASE 
        WHEN u.age < 18 THEN '<18'
        WHEN u.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '45+'
    END as age_group,
    COUNT(DISTINCT u.user_id) as total_users,
    COUNT(DISTINCT p.user_id) as paying_users,
    COALESCE(SUM(p.amount), 0) as total_revenue,
    COALESCE(SUM(p.amount), 0) / COUNT(DISTINCT u.user_id) as arpu,
    (COUNT(DISTINCT p.user_id) * 100.0 / COUNT(DISTINCT u.user_id)) as conversion_rate
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
    END;

-- Query 7.3: Engagement by Age Group
-- Purpose: Session metrics by age segment
SELECT 
    CASE 
        WHEN u.age < 18 THEN '<18'
        WHEN u.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '45+'
    END as age_group,
    COUNT(DISTINCT u.user_id) as total_users,
    COUNT(s.session_id) as total_sessions,
    COUNT(s.session_id) / COUNT(DISTINCT u.user_id) as avg_sessions_per_user,
    AVG(s.duration_seconds) / 60 as avg_session_minutes
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id
WHERE s.duration_seconds IS NOT NULL
GROUP BY age_group
ORDER BY 
    CASE age_group
        WHEN '<18' THEN 1
        WHEN '18-25' THEN 2
        WHEN '26-35' THEN 3
        WHEN '36-45' THEN 4
        ELSE 5
    END;


-- =====================================================
-- SECTION 8: DEMOGRAPHIC SEGMENTATION - GENDER
-- =====================================================

-- Query 8.1: User Count by Gender
-- Purpose: Gender distribution of user base
SELECT 
    CASE 
        WHEN gender < 0.33 THEN 'Male'
        WHEN gender < 0.67 THEN 'Neutral'
        ELSE 'Female'
    END as gender_category,
    COUNT(*) as user_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM users)) as percentage
FROM users
GROUP BY gender_category
ORDER BY user_count DESC;

-- Query 8.2: ARPU by Gender
-- Purpose: Revenue performance by gender
SELECT 
    CASE 
        WHEN u.gender < 0.33 THEN 'Male'
        WHEN u.gender < 0.67 THEN 'Neutral'
        ELSE 'Female'
    END as gender_category,
    COUNT(DISTINCT u.user_id) as total_users,
    COUNT(DISTINCT p.user_id) as paying_users,
    COALESCE(SUM(p.amount), 0) as total_revenue,
    COALESCE(SUM(p.amount), 0) / COUNT(DISTINCT u.user_id) as arpu,
    (COUNT(DISTINCT p.user_id) * 100.0 / COUNT(DISTINCT u.user_id)) as conversion_rate
FROM users u
LEFT JOIN purchases p ON u.user_id = p.user_id
GROUP BY gender_category
ORDER BY arpu DESC;

-- Query 8.3: Engagement by Gender
-- Purpose: Session metrics by gender
SELECT 
    CASE 
        WHEN u.gender < 0.33 THEN 'Male'
        WHEN u.gender < 0.67 THEN 'Neutral'
        ELSE 'Female'
    END as gender_category,
    COUNT(DISTINCT u.user_id) as total_users,
    COUNT(s.session_id) as total_sessions,
    COUNT(s.session_id) / COUNT(DISTINCT u.user_id) as avg_sessions_per_user,
    AVG(s.duration_seconds) / 60 as avg_session_minutes
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id
WHERE s.duration_seconds IS NOT NULL
GROUP BY gender_category
ORDER BY avg_sessions_per_user DESC;


-- =====================================================
-- SECTION 9: CROSS-SEGMENT ANALYSIS
-- =====================================================

-- Query 9.1: Country × Age Group Revenue Heatmap
-- Purpose: Identify high-value demographic combinations
SELECT 
    u.country,
    CASE 
        WHEN u.age < 18 THEN '<18'
        WHEN u.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '45+'
    END as age_group,
    COUNT(DISTINCT u.user_id) as user_count,
    COALESCE(SUM(p.amount), 0) as total_revenue,
    COALESCE(SUM(p.amount), 0) / COUNT(DISTINCT u.user_id) as arpu
FROM users u
LEFT JOIN purchases p ON u.user_id = p.user_id
GROUP BY u.country, age_group
ORDER BY total_revenue DESC
LIMIT 20;

-- Query 9.2: High-Value User Profile
-- Purpose: Characteristics of top spenders
WITH top_spenders AS (
    SELECT user_id
    FROM purchases
    GROUP BY user_id
    ORDER BY SUM(amount) DESC
    LIMIT 10
)
SELECT 
    u.country,
    CASE 
        WHEN u.age < 18 THEN '<18'
        WHEN u.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN u.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN u.age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '45+'
    END as age_group,
    CASE 
        WHEN u.gender < 0.33 THEN 'Male'
        WHEN u.gender < 0.67 THEN 'Neutral'
        ELSE 'Female'
    END as gender_category,
    COUNT(*) as top_spender_count
FROM users u
INNER JOIN top_spenders ts ON u.user_id = ts.user_id
GROUP BY u.country, age_group, gender_category
ORDER BY top_spender_count DESC;


-- =====================================================
-- SECTION 10: SUMMARY STATISTICS
-- =====================================================

-- Query 10.1: Comprehensive KPI Summary
-- Purpose: One-stop overview of all key metrics
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM sessions) as total_sessions,
    (SELECT COUNT(*) FROM purchases) as total_purchases,
    (SELECT COALESCE(SUM(amount), 0) FROM purchases) as total_revenue,
    (SELECT COALESCE(SUM(amount), 0) / COUNT(DISTINCT user_id) FROM users LEFT JOIN purchases p ON users.user_id = p.user_id) as arpu,
    (SELECT COUNT(DISTINCT user_id) FROM purchases) as paying_users,
    (SELECT COUNT(DISTINCT user_id) * 100.0 / COUNT(*) FROM purchases, users) as conversion_rate,
    (SELECT AVG(duration_seconds) / 60 FROM sessions WHERE duration_seconds IS NOT NULL) as avg_session_minutes,
    (SELECT COUNT(*) / COUNT(DISTINCT user_id) FROM sessions) as avg_sessions_per_user;

-- =====================================================
-- END OF KPI QUERIES
-- =====================================================
-- Usage: Execute these queries in SQL Workbench or via R
-- Each query is self-contained and can be run independently
-- Results will be used for statistical analysis in R
-- =====================================================

