CREATE VIEW view_d1_retention_by_cohort AS
SELECT
	signup_date AS cohort_date,
    COUNT(DISTINCT user_id) AS new_users,
    SUM(returned_d1) AS d1_retained_user,
    ROUND(SUM(returned_d1) * 100 / COUNT(DISTINCT user_id), 2) AS d1_retention_rate
FROM view_d1_return_status
GROUP BY signup_date
ORDER BY signup_date;