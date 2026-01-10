CREATE VIEW view_d1_retention_rate AS
SELECT
	country,
    COUNT(user_id) AS new_users,
    SUM(returned_d1) AS retained_user,
    ROUND(SUM(returned_d1) * 100.00 / COUNT(DISTINCT user_id), 2) AS d1_retention_rate
FROM view_d1_return_status
GROUP BY country
ORDER BY d1_retention_rate DESC;