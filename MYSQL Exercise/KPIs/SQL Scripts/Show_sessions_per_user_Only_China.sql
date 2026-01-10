SELECT
    u.user_id,
    u.firstName,
    u.lastName,
    COUNT(s.session_id) AS session_per_user
FROM users u
JOIN sessions s ON s.player_id = u.user_id
WHERE u.country = 'CHINA'
GROUP BY u.user_id, u.firstName, u.lastName
ORDER BY session_per_user DESC;