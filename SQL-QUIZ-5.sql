SELECT 
    REGEXP_REPLACE(WebsiteUrl, 'https?://([^/]+).*', '\1') AS domain, 
    COUNT(*) AS domain_count
FROM 
    users
WHERE 
    WebsiteUrl IS NOT NULL
GROUP BY 
    domain
ORDER BY 
    domain_count DESC;
