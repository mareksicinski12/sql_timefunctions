CREATE OR REPLACE VIEW top_posts AS
WITH ranked_posts AS (
    -- Wir holen die 10 besten Posts für jeden Tag (basierend auf LastActivityDate und Score)
    SELECT 
        p.Id AS post_id,
        p.Title AS post_title,
        p.LasActivityDate,
        p.Score AS post_score,
        t.TagName AS post_tag,
        ROW_NUMBER() OVER (PARTITION BY p.LasActivityDate ORDER BY p.Score DESC) AS rank
    FROM 
        posts p
    JOIN 
        tags t ON t.Id = ANY(string_to_array(p.Tags, ',')::int[])
    WHERE 
        p.PostTypeId = 1  -- Wir gehen davon aus, dass nur Fragen berücksichtigt werden
),
top_answers AS (
    -- Wir holen die besten 3 Antworten pro Post basierend auf ihrem Score
    SELECT 
        a.ParentId AS post_id,
        a.Body AS answer_text,
        a.Score AS answer_score,
        ROW_NUMBER() OVER (PARTITION BY a.ParentId ORDER BY a.Score DESC) AS rank
    FROM 
        posts a
    WHERE 
        a.PostTypeId = 2  -- Wir gehen davon aus, dass nur Antworten berücksichtigt werden
)
SELECT 
    rp.post_id,
    rp.post_title,
    rp.LasActivityDate,
    rp.post_tag,
    -- Erstelle ein Array der besten 3 Antworten (maximal 3)
    ARRAY(
        SELECT answer_text 
        FROM top_answers 
        WHERE post_id = rp.post_id AND rank <= 3
        ORDER BY answer_score DESC
    ) AS top_answers
FROM 
    ranked_posts rp
WHERE 
    rp.rank <= 10  -- Nur die besten 10 Posts pro Tag
ORDER BY 
    rp.LasActivityDate, rp.rank;
