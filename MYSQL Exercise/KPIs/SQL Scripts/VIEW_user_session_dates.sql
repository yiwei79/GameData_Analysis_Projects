CREATE VIEW view_user_session_dates AS
SELECT
	s.player_id,
    DATE(start) AS session_date
FROM sessions s
GROUP BY player_id, DATE(start)