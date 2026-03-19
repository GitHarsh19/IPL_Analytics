-- Venue Profiles --
SELECT 
    ms.venue,
    ms.city,
    COUNT(*) AS total_matches,
    ROUND(AVG(ms.first_innings_score), 1) AS avg_first_innings,
    ROUND(AVG(ms.second_innings_score), 1) AS avg_second_innings,
    ROUND(SUM(CASE WHEN ms.winner = ms.batting_first_team THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS bat_first_win_pct,
    ROUND(SUM(CASE WHEN ms.winner = ms.chasing_team THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chase_win_pct
FROM match_summary ms
GROUP BY ms.venue, ms.city
HAVING COUNT(*) >= 10
ORDER BY avg_first_innings DESC;

-- Phase-wise Run Rates by Venue --
SELECT 
    d.venue,
    d.phase,
    COUNT(DISTINCT d.match_id) AS matches,
    ROUND(SUM(d.total_runs) * 6.0 / 
        NULLIF(COUNT(CASE WHEN d.extras_type IS NULL 
                          OR d.extras_type NOT IN ('wides', 'noballs') THEN 1 END), 0), 2) AS run_rate,
    ROUND(SUM(d.is_wicket) * 6.0 / 
        NULLIF(COUNT(CASE WHEN d.extras_type IS NULL 
                          OR d.extras_type NOT IN ('wides', 'noballs') THEN 1 END), 0), 2) AS wickets_per_over
FROM deliveries d
WHERE d.venue IN (
    SELECT venue FROM matches GROUP BY venue HAVING COUNT(*) >= 15
)
GROUP BY d.venue, d.phase
ORDER BY d.venue, MIN(d."over");


-- Boundary Percentage by Venue --
SELECT 
    venue,
    COUNT(*) AS total_balls,
    COUNT(CASE WHEN batsman_runs = 4 THEN 1 END) AS fours,
    COUNT(CASE WHEN batsman_runs = 6 THEN 1 END) AS sixes,
    ROUND((COUNT(CASE WHEN batsman_runs IN (4, 6) THEN 1 END)) * 100.0 / COUNT(*), 2) AS boundary_pct,
    ROUND(COUNT(CASE WHEN batsman_runs = 6 THEN 1 END) * 100.0 / 
        NULLIF(COUNT(CASE WHEN batsman_runs IN (4, 6) THEN 1 END), 0), 2) AS six_share_of_boundaries
FROM deliveries
WHERE venue IN (SELECT venue FROM matches GROUP BY venue HAVING COUNT(*) >= 15)
GROUP BY venue
ORDER BY boundary_pct DESC;