WITH AnswerInterval AS(
	SELECT
		Id AS QusetionId, 
		ParentId AS AnswerId,
		CreationDate AS AnswerCreationDate,
		LAG(CreationDate) OVER(PARTITION BY ParentId ORDER BY CreationDate) AS PreviousAnswer
	FROM 
		posts  
	WHERE 
		PostTypeId = 2
)
SELECT 
	ROUND(AVG(EXTRACT(EPOCH FROM (AnswerCreationDate - PreviousAnswer))) / 86400) 
FROM 
	AnswerInterval
