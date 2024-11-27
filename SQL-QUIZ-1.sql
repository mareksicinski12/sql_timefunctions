--CREATE OR REPLACE VIEW top_posts AS 
	WITH RankedPosts AS (
		SELECT 
			q.Id AS PostId,
			q.Title AS PostTitle,
			q.LasActivityDate,
			q.Tags,
			q.Score,
			RANK() OVER (PARTITION BY DATE(q.LasActivityDate) ORDER BY q.Score DESC) AS PostRankPerDay
		FROM
			posts q
		WHERE
			q.PostTypeId = 1
	),
	TopPosts AS (
		SELECT 
			rp.PostId,
			rp.PostTitle,
			rp.LasActivityDate,
			rp.Tags,
			rp.PostRankPerDay,
			ARRAY(
				SELECT 
					a.Body
				FROM
					posts a
				WHERE  
					rp.PostId = a.ParentId AND a.PostTypeId = 2 
				ORDER BY 
					a.Score DESC
				LIMIT 3
					
			) AS TopAnswers
		
		FROM 
			RankedPosts rp
		WHERE 
			rp.PostRankPerDay <= 10
	)
	SELECT 
		PostId,
    	PostTitle,
    	LasActivityDate,
    	Tags,
		PostRankPerDay,
    	TopAnswers
	FROM
		TopPosts
	WHERE 
		PostRankPerDay = 2


