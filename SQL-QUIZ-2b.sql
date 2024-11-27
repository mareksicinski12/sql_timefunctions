WITH QuestionWithAcceptedAnswer AS (
    SELECT 
        q.Id AS QuestionId,
        q.CreationDate AS QuestionCreationDate,
        a.CreationDate AS AnswerCreationDate,
        EXTRACT(EPOCH FROM (a.CreationDate - q.CreationDate)) / 86400 AS ResponseTimeInDays
    FROM 
        posts q
    INNER JOIN 
        posts a ON q.AcceptedAnswerId = a.Id
    WHERE 
        q.PostTypeId = 1  -- Nur Fragen
        AND q.Tags LIKE '%time-series%' -- Tag-Filter
)
SELECT 
    AVG(ResponseTimeInDays) AS AverageResponseTimeInDays
FROM 
    QuestionWithAcceptedAnswer;
