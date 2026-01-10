SELECT users.country,
COUNT(sessions.session_id) as total_sessions,
AVG(TIMESTAMPDIFF(SECOND, sessions.start, sessions.end)) AS avg_session_length_seconds,
AVG(TIMESTAMPDIFF(MINUTE, sessions.start, sessions.end)) AS avg_session_length_minutes,
AVG(TIMESTAMPDIFF(HOUR, sessions.start, sessions.end)) AS avg_session_length_hours
FROM users
JOIN sessions ON users.user_id = sessions.player_id
GROUP by users.country
ORDER BY avg_session_length_minutes DESC;