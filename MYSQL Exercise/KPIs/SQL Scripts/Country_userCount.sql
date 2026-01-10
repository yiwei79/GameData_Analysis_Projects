SELECT country, COUNT(*) AS user_count
FROM users
GROUP BY country
ORDER BY user_count DESC