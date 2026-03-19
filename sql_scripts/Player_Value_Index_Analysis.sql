-- Batter Value Index --
CREATE TABLE batter_value_index AS
WITH career_stats AS (
    SELECT 
        batter,
        SUM(runs_scored) AS career_runs,
        SUM(balls_faced) AS career_balls,
        CASE WHEN SUM(balls_faced) > 0 THEN ROUND(SUM(runs_scored) * 100.0 / SUM(balls_faced), 2) ELSE 0 END AS career_sr,
        CASE WHEN SUM(times_dismissed) > 0 THEN ROUND(SUM(runs_scored) * 1.0 / SUM(times_dismissed), 2) ELSE 0 END AS career_avg,
        ROUND(SUM(fours + sixes) * 100.0 / NULLIF(SUM(balls_faced), 0), 2) AS career_boundary_pct,
        CASE WHEN SUM(death_balls) > 0 THEN ROUND(SUM(death_runs) * 100.0 / SUM(death_balls), 2) ELSE 0 END AS career_death_sr,
        COUNT(DISTINCT season) AS seasons
    FROM batter_stats
    GROUP BY batter
    HAVING SUM(balls_faced) >= 200  -- Minimum qualification
),
consistency AS (
    SELECT 
        batter,
        ROUND(STDDEV(innings_runs) / NULLIF(AVG(innings_runs), 0), 2) AS cv,
        ROUND(COUNT(CASE WHEN innings_runs >= 30 THEN 1 END) * 100.0 / COUNT(*), 2) AS impact_pct
    FROM innings_scores
    GROUP BY batter
    HAVING COUNT(*) >= 15
)
SELECT 
    cs.batter,
    cs.career_runs,
    cs.career_sr,
    cs.career_avg,
    cs.career_boundary_pct,
    cs.career_death_sr,
    cs.seasons,
    c.cv AS consistency_cv,
    c.impact_pct,
    
    -- PLAYER VALUE INDEX (weighted composite)
    -- Normalize each metric to 0-100 scale, then weight
    ROUND(
        -- Strike Rate component (weight: 25%)
        (cs.career_sr / (SELECT MAX(career_sr) FROM career_stats) * 100) * 0.25 +
        -- Average component (weight: 25%)
        (LEAST(cs.career_avg, 60) / 60.0 * 100) * 0.25 +
        -- Boundary % component (weight: 15%)
        (cs.career_boundary_pct / (SELECT MAX(career_boundary_pct) FROM career_stats) * 100) * 0.15 +
        -- Death SR component (weight: 15%)
        (LEAST(cs.career_death_sr, 200) / 200.0 * 100) * 0.15 +
        -- Consistency component (weight: 10%) — lower CV is better
        (1 - LEAST(COALESCE(c.cv, 1.5), 2) / 2.0) * 100 * 0.10 +
        -- Impact innings % component (weight: 10%)
        (COALESCE(c.impact_pct, 0) / (SELECT MAX(impact_pct) FROM consistency) * 100) * 0.10
    , 2) AS player_value_index

FROM career_stats cs
LEFT JOIN consistency c ON cs.batter = c.batter
ORDER BY player_value_index DESC;

-- View top 20
SELECT 
    batter, career_runs, career_sr, career_avg, 
    career_death_sr, consistency_cv, player_value_index
FROM batter_value_index
ORDER BY player_value_index DESC
LIMIT 20;



--  Bowler Value Index --

CREATE TABLE bowler_value_index AS
WITH career_stats AS (
    SELECT 
        bowler,
        SUM(wickets) AS career_wickets,
        SUM(balls_bowled) AS career_balls,
        CASE WHEN SUM(balls_bowled) > 0 THEN ROUND(SUM(runs_conceded) * 6.0 / SUM(balls_bowled), 2) ELSE 0 END AS career_economy,
        CASE WHEN SUM(wickets) > 0 THEN ROUND(SUM(runs_conceded) * 1.0 / SUM(wickets), 2) ELSE 0 END AS career_bowling_avg,
        CASE WHEN SUM(wickets) > 0 THEN ROUND(SUM(balls_bowled) * 1.0 / SUM(wickets), 2) ELSE 0 END AS career_bowling_sr,
        CASE WHEN SUM(death_balls) > 0 THEN ROUND(SUM(death_runs_conceded) * 6.0 / SUM(death_balls), 2) ELSE 0 END AS career_death_economy,
        SUM(dot_balls) AS career_dots,
        ROUND(SUM(dot_balls) * 100.0 / NULLIF(SUM(balls_bowled), 0), 2) AS dot_ball_pct,
        COUNT(DISTINCT season) AS seasons
    FROM bowler_stats
    GROUP BY bowler
    HAVING SUM(balls_bowled) >= 200  -- Minimum qualification
),
bowl_consistency AS (
    SELECT 
        bowler,
        ROUND(STDDEV(match_economy) / NULLIF(AVG(match_economy), 0), 2) AS economy_cv
    FROM (
        SELECT 
            bowler,
            match_id,
            CASE WHEN COUNT(CASE WHEN extras_type IS NULL OR extras_type NOT IN ('wides', 'noballs') THEN 1 END) > 0
                 THEN SUM(total_runs) * 6.0 / COUNT(CASE WHEN extras_type IS NULL OR extras_type NOT IN ('wides', 'noballs') THEN 1 END)
                 ELSE 0 END AS match_economy
        FROM deliveries
        GROUP BY bowler, match_id
        HAVING COUNT(CASE WHEN extras_type IS NULL OR extras_type NOT IN ('wides', 'noballs') THEN 1 END) >= 12
    ) match_stats
    GROUP BY bowler
    HAVING COUNT(*) >= 15
)
SELECT 
    cs.*,
    bc.economy_cv,
    
    -- BOWLER VALUE INDEX
    ROUND(
        -- Economy component (weight: 25%) — lower is better
        (1 - LEAST(cs.career_economy, 12) / 12.0) * 100 * 0.25 +
        -- Bowling SR component (weight: 20%) — lower is better
        (1 - LEAST(cs.career_bowling_sr, 30) / 30.0) * 100 * 0.20 +
        -- Death economy component (weight: 20%) — lower is better
        (1 - LEAST(cs.career_death_economy, 14) / 14.0) * 100 * 0.20 +
        -- Dot ball % component (weight: 15%)
        (cs.dot_ball_pct / (SELECT MAX(dot_ball_pct) FROM career_stats) * 100) * 0.15 +
        -- Consistency component (weight: 10%) — lower CV is better
        (1 - LEAST(COALESCE(bc.economy_cv, 0.5), 1) / 1.0) * 100 * 0.10 +
        -- Longevity component (weight: 10%)
        (LEAST(cs.seasons, 10) / 10.0 * 100) * 0.10
    , 2) AS bowler_value_index

FROM career_stats cs
LEFT JOIN bowl_consistency bc ON cs.bowler = bc.bowler
ORDER BY bowler_value_index DESC;

-- View top 20
SELECT 
    bowler, career_wickets, career_economy, career_bowling_avg,
    career_death_economy, economy_cv, bowler_value_index
FROM bowler_value_index
ORDER BY bowler_value_index DESC
LIMIT 20;