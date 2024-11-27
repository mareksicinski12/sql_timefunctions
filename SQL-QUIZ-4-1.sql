CREATE OR REPLACE VIEW top_posts AS
WITH RankedPosts AS (
    -- Finde die 10 besten Posts pro Tag nach Score
    SELECT 
        p.Id AS PostId,
        p.Title,
        p.LasActivityDate,
        p.Tags,
        p.Score,
        ROW_NUMBER() OVER (
            PARTITION BY DATE(p.LasActivityDate) 
            ORDER BY p.Score DESC
        ) AS Rank
    FROM 
        posts p
    WHERE 
        p.PostTypeId = 1 
),
TopDailyPosts AS (
    -- Behalte nur die Top 10 Posts pro Tag
    SELECT 
        rp.PostId,
        rp.Title,
        rp.LasActivityDate,
        rp.Tags
    FROM 
        RankedPosts rp
    WHERE 
        rp.Rank <= 10
		
),
TopAnswers AS (
    -- Suche die besten Antworten pro Post
    SELECT 
        a.ParentId AS QuestionId,
        a.Body AS AnswerText,
        a.Score,
        ROW_NUMBER() OVER (
            PARTITION BY a.ParentId 
            ORDER BY a.Score DESC
        ) AS AnswerRank
    FROM 
        posts a
    WHERE 
        a.PostTypeId = 2 
		
),
TopAnswersLimited AS (
    -- Begrenze die Antworten auf maximal 3 pro Frage
    SELECT
        ta.QuestionId,
        ARRAY_AGG(ta.AnswerText) AS TopAnswers
    FROM 
        TopAnswers ta
    WHERE 
        ta.AnswerRank <= 3
    GROUP BY 
        ta.QuestionId
)
SELECT 
    tdp.PostId,
    tdp.Title,
    tdp.LasActivityDate,
    tdp.Tags,
    COALESCE(tal.TopAnswers, ARRAY[]::TEXT[]) AS TopAnswers -- Falls keine Antworten existieren
FROM 
    TopDailyPosts tdp
LEFT JOIN 
    TopAnswersLimited tal ON tdp.PostId = tal.QuestionId
ORDER BY 
    tdp.LasActivityDate DESC, tdp.PostId;
