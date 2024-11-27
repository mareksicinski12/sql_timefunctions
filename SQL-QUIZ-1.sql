WITH UserAverageScore AS (
	SELECT
		u.Id, 
		u.DisplayName AS Nickname, 
		AVG(c.Score) AS AverageScore
	FROM 
		users u 
	LEFT OUTER JOIN 
		comments c ON u.Id = c.UserId
	GROUP BY 
		u.Id, u.DisplayName
),
GlobalAverageScore AS (
	SELECT 
		AVG(AverageScore) AS GlobalAverage 
	FROM	
		UserAverageScore
)

SELECT 	
	u.Id,
	u.Nickname,
	u.AverageScore,
	CASE 
		WHEN u.AverageScore >= (SELECT GlobalAverage FROM GlobalAverageScore) THEN 'Good Poster'
		ELSE 'Troll'
	END AS Marking 
FROM 
	UserAverageScore u
WHERE 
	u.Id = 12
