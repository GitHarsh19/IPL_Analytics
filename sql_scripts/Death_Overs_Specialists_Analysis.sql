--  Top Death Overs Batters (Minimum 100 death balls faced) --
SELECT 
    bs.batter,                          -- was: batter
    SUM(bs.death_runs) AS total_death_runs,
    SUM(bs.death_balls) AS total_death_balls,
    ROUND(SUM(bs.death_runs) * 100.0 / NULLIF(SUM(bs.death_balls), 0), 2) AS death_sr,
    COUNT(DISTINCT bs.season) AS seasons_played,
    sub.death_boundaries,
    ROUND(sub.death_boundaries * 100.0 / NULLIF(SUM(bs.death_balls), 0), 2) AS death_boundary_pct
FROM batter_stats bs
JOIN (
    SELECT 
        batter,
        COUNT(CASE WHEN phase = 'Death' AND batsman_runs IN (4, 6) THEN 1 END) AS death_boundaries
    FROM deliveries
    GROUP BY batter
) sub ON bs.batter = sub.batter
GROUP BY bs.batter, sub.death_boundaries
HAVING SUM(bs.death_balls) >= 100
ORDER BY death_sr DESC
LIMIT 20;


-- Top Death Overs Bowlers (Minimum 100 death balls bowled) --
SELECT 
    bowler,
    SUM(death_wickets) AS total_death_wickets,
    SUM(death_balls) AS total_death_balls,
    ROUND(SUM(death_runs_conceded) * 6.0 / NULLIF(SUM(death_balls), 0), 2) AS death_economy,
    ROUND(SUM(death_balls) * 1.0 / NULLIF(SUM(death_wickets), 0), 2) AS death_bowling_sr,
    COUNT(DISTINCT season) AS seasons_played
FROM bowler_stats
GROUP BY bowler
HAVING SUM(death_balls) >= 100
ORDER BY death_economy ASC
LIMIT 20;

-- Death Over Consistency — Batters with 150+ SR across 3+ seasons --
WITH death_by_season AS (
    SELECT 
        batter,
        season,
        SUM(death_runs) AS death_runs,
        SUM(death_balls) AS death_balls,
        CASE WHEN SUM(death_balls) >= 15 
             THEN ROUND(SUM(death_runs) * 100.0 / SUM(death_balls), 2) 
             ELSE NULL END AS death_sr
    FROM batter_stats
    GROUP BY batter, season
    HAVING SUM(death_balls) >= 15
)
SELECT 
    batter,
    COUNT(*) AS qualifying_seasons,
    COUNT(CASE WHEN death_sr >= 150 THEN 1 END) AS seasons_above_150,
    ROUND(AVG(death_sr), 2) AS avg_death_sr,
    ROUND(STDDEV(death_sr), 2) AS sr_std_dev
FROM death_by_season
WHERE death_sr IS NOT NULL
GROUP BY batter
HAVING COUNT(*) >= 3 AND COUNT(CASE WHEN death_sr >= 150 THEN 1 END) >= 3
ORDER BY avg_death_sr DESC;