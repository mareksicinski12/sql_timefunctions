WITH AnswerTime AS(
	SELECT 
		q.Id AS QuestionId,
		a.Id AS AnswerId, 
		EXTRACT(
			EPOCH FROM (a.CreationDate - q.CreationDate))
			AS TimeToAnswer
	FROM 
		posts q JOIN posts a ON a.ParentId = q.Id
	WHERE 
		q.PostTypeId = 1 
		AND a.PostTypeId = 2 
		AND q.AcceptedAnswerId IS NOT NULL
	
)
SELECT *
FROM AnswerTime
WHERE TimeToAnswer > 0
ORDER BY TimeToAnswer ASC 
OFFSET 3 LIMIT 1	

