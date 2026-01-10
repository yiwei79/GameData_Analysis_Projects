CREATE VIEW view_d1_return_status AS
SELECT
	uc.user_id,
    uc.signup_date,
    uc.country,
    CASE
		WHEN usd.session_date = uc.signup_date + INTERVAL 1 DAY
		THEN 1
        ELSE 0
	END AS returned_d1
FROM user_cohorts uc
LEFT JOIN view_user_session_dates usd
	ON uc.user_id = usd.player_id
    AND usd.session_date = uc.signup_date + INTERVAL 1 DAY;