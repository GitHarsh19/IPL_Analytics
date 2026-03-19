-- Overall Win % Batting First vs Chasing --
SELECT 
    CASE 
        WHEN winner = batting_first_team THEN 'Batting First Won'
        WHEN winner = chasing_team THEN 'Chasing Team Won'
    END AS outcome,
    COUNT(*) AS matches,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct
FROM match_summary
WHERE winner IS NOT NULL
GROUP BY 
    CASE 
        WHEN winner = batting_first_team THEN 'Batting First Won'
        WHEN winner = chasing_team THEN 'Chasing Team Won'
    END;

-- Chasing Success by Target range --
SELECT 
    CASE 
        WHEN first_innings_score < 130 THEN 'Under 130'
        WHEN first_innings_score BETWEEN 130 AND 149 THEN '130-149'
        WHEN first_innings_score BETWEEN 150 AND 169 THEN '150-169'
        WHEN first_innings_score BETWEEN 170 AND 185 THEN '170-185'
        WHEN first_innings_score BETWEEN 186 AND 200 THEN '186-200'
        WHEN first_innings_score > 200 THEN '200+'
    END AS target_range,
    COUNT(*) AS matches,
    SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END) AS chasing_wins,
    ROUND(SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chase_win_pct
FROM match_summary
WHERE first_innings_score IS NOT NULL
GROUP BY 
    CASE 
        WHEN first_innings_score < 130 THEN 'Under 130'
        WHEN first_innings_score BETWEEN 130 AND 149 THEN '130-149'
        WHEN first_innings_score BETWEEN 150 AND 169 THEN '150-169'
        WHEN first_innings_score BETWEEN 170 AND 185 THEN '170-185'
        WHEN first_innings_score BETWEEN 186 AND 200 THEN '186-200'
        WHEN first_innings_score > 200 THEN '200+'
    END
ORDER BY chase_win_pct DESC;

-- Chasing Success by Venue --
SELECT 
    venue,
    COUNT(*) AS matches,
    ROUND(AVG(first_innings_score), 1) AS avg_first_innings,
    SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END) AS chasing_wins,
    ROUND(SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chase_win_pct
FROM match_summary
WHERE first_innings_score IS NOT NULL
GROUP BY venue
HAVING COUNT(*) >= 10
ORDER BY chase_win_pct DESC;

