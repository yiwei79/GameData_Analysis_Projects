SELECT
	u.user_id,
    u.firstName,
    u.lastName,
    COUNT(s.session_id) AS number_of_sessions 
FROM users u
LEFT JOIN sessions s ON u.user_id = s.player_id
GROUP BY u.user_id, u.firstName, u.lastName
ORDER BY number_of_sessions DESC