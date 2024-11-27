WITH Percentiles AS (
    SELECT
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY Views) AS Views90Percentile,
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY UpVotes) AS UpVotes90Percentile
    FROM 
        users
),
UserStats AS (
    -- Berechne die individuellen Views und Upvotes der Nutzer und füge Perzentile hinzu
    SELECT
        u.Id AS UserId,
        u.Views,
        u.UpVotes,
        p.Views90Percentile,
        p.UpVotes90Percentile
    FROM 
        users u
    CROSS JOIN 
        Percentiles p
),
UserCategories AS (
    -- Ordne Benutzer nach den Kategorien 
    SELECT
        UserId,
        CASE 
            WHEN Views > Views90Percentile THEN 'besonders häufig'
            ELSE 'normal viele'
        END AS Profilaufrufe,
        CASE 
            WHEN UpVotes > UpVotes90Percentile THEN 'besonders viele'
            ELSE 'normal viele'
        END AS UpVotesCategory
    FROM 
        UserStats
),
ResponseTimes AS (
    -- Berechne die durchschnittliche Antwortzeit pro Benutzer (in Tagen)
    SELECT
        q.OwnerUserId AS UserId,
        AVG(EXTRACT(EPOCH FROM (a.CreationDate - q.CreationDate)) / 86400) AS AvgResponseTimeInDays
    FROM 
        posts q
    INNER JOIN 
        posts a ON q.Id = a.ParentId
    WHERE 
        q.PostTypeId = 1 
    GROUP BY 
        q.OwnerUserId
),
CombinedData AS (
    -- Kombiniere Kategorien mit den Antwortzeiten
    SELECT
        uc.Profilaufrufe,
        uc.UpVotesCategory,
        rt.AvgResponseTimeInDays
    FROM 
        UserCategories uc
    LEFT JOIN 
        ResponseTimes rt ON uc.UserId = rt.UserId
),
AggregatedResults AS (
    -- Berechne die durchschnittliche Antwortzeit für jede Kategorie
    SELECT
        Profilaufrufe,
        UpVotesCategory,
        AVG(AvgResponseTimeInDays) AS AvgResponseTimeByCategory
    FROM 
        CombinedData
    GROUP BY 
        GROUPING SETS (
            (Profilaufrufe, UpVotesCategory), 
            (Profilaufrufe),                 
            (UpVotesCategory)                
        )
),
GlobalAverage AS (
    -- Berechne die globale durchschnittliche Antwortzeit aller Benutzer
    SELECT 
        AVG(AvgResponseTimeInDays) AS GlobalAvgResponseTime
    FROM 
        ResponseTimes
)
SELECT 
    ar.Profilaufrufe,
    ar.UpVotesCategory,
    ROUND(ar.AvgResponseTimeByCategory, 2) AS AvgResponseTimeByCategory,
    ROUND(ga.GlobalAvgResponseTime, 2) AS GlobalAvgResponseTime,  
    CASE 
        WHEN ar.AvgResponseTimeByCategory > ga.GlobalAvgResponseTime THEN 'langsamer'
        ELSE 'schneller'
    END AS Vergleich
FROM 
    AggregatedResults ar
CROSS JOIN 
    GlobalAverage ga  
ORDER BY 
    ar.Profilaufrufe NULLS LAST, 
    ar.UpVotesCategory NULLS LAST;