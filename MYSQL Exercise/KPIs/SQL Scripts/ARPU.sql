SELECT
	COUNT(DISTINCT u.user_id) AS total_users,
    COALESCE(SUM(t.totalPrice),0) AS total_revenue,
    ROUND(COALESCE(SUM(t.totalPrice),0) / COUNT(DISTINCT u.user_id),2) AS ARPU
FROM users u
LEFT JOIN transactions t ON t.player_id = u.user_id