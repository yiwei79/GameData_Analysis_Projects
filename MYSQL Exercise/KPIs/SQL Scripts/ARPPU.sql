SELECT
	COUNT(DISTINCT t.player_id) AS paying_users,
    COALESCE(SUM(t.totalPrice),0) AS total_revenue,
    COALESCE(SUM(t.totalPrice),0) / COUNT(DISTINCT t.player_id) AS ARPPU
FROM transactions t;