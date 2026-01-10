CREATE VIEW show_num_session_per_country AS
SELECT
	u.country,
	COUNT(session_id) AS session_per_country
FROM sessions s
JOIN users u ON u.user_id = s.player_id
GROUP BY u.country
ORDER BY session_per_country DESC;