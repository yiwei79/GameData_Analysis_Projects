CREATE VIEW view_mau AS
SELECT
	DATE_FORMAT(start, '%Y-%m') AS month,
    COUNT(DISTINCT s.player_id) MAU
FROM sessions s
GROUP BY DATE_FORMAT(start, '%Y-%m')
ORDER BY month DESC;