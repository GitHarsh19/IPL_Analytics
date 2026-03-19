-- Scoring Trends Across Seasons --
SELECT 
    season,
    COUNT(DISTINCT match_id) AS matches,
    ROUND(AVG(first_innings_score), 1) AS avg_first_innings,
    ROUND(AVG(second_innings_score), 1) AS avg_second_innings,
    MAX(first_innings_score) AS highest_score,
    MIN(first_innings_score) AS lowest_score
FROM match_summary
GROUP BY season
ORDER BY season;

-- Phase-wise Run Rate Evolution --
SELECT 
    m.season,
    d.phase,
    ROUND(SUM(d.total_runs) * 6.0 / 
        NULLIF(COUNT(CASE WHEN d.extras_type IS NULL 
                          OR d.extras_type NOT IN ('wides', 'noballs') THEN 1 END), 0), 2) AS run_rate,
    ROUND(SUM(d.is_wicket) * 6.0 / 
        NULLIF(COUNT(CASE WHEN d.extras_type IS NULL 
                          OR d.extras_type NOT IN ('wides', 'noballs') THEN 1 END), 0), 2) AS wickets_per_over,
    ROUND(COUNT(CASE WHEN d.batsman_runs IN (4, 6) THEN 1 END) * 100.0 / COUNT(*), 2) AS boundary_pct
FROM deliveries d
JOIN matches m ON d.match_id = m.id
GROUP BY m.season, d.phase
ORDER BY m.season, MIN(d."over");

-- Powerplay Strategy Shift --
SELECT 
    m.season,
    ROUND(SUM(CASE WHEN d.phase = 'Powerplay' THEN d.total_runs ELSE 0 END) * 100.0 / 
        NULLIF(SUM(d.total_runs), 0), 2) AS powerplay_run_share,
    ROUND(SUM(CASE WHEN d.phase = 'Death' THEN d.total_runs ELSE 0 END) * 100.0 / 
        NULLIF(SUM(d.total_runs), 0), 2) AS death_run_share,
    ROUND(SUM(CASE WHEN d.phase = 'Powerplay' THEN d.is_wicket ELSE 0 END) * 100.0 / 
        NULLIF(SUM(d.is_wicket), 0), 2) AS powerplay_wicket_share
FROM deliveries d
JOIN matches m ON d.match_id = m.id
GROUP BY m.season
ORDER BY m.season;
