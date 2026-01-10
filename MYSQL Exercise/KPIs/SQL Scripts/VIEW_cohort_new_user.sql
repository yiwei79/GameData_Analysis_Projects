CREATE VIEW user_cohorts AS
SELECT
	u.user_id,
	DATE(u.dateCreated) AS signup_date,
    u.country
FROM users u