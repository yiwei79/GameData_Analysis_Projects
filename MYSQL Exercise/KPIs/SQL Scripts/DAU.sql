SELECT
	DATE(start) AS date,
    COUNT(DISTINCT s.player_id) AS DAU
FROM sessions s
GROUP BY DATE(start)
ORDER BY date DESC;