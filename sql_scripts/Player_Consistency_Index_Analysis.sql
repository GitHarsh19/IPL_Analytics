-- Innings-level Scores for Consistency Calculation --
CREATE TABLE innings_scores AS
SELECT 
    d.batter,
    d.match_id,
    m.season,
    m.venue,
    d.batting_team,
    SUM(d.batsman_runs) AS innings_runs,
    COUNT(CASE WHEN d.extras_type IS NULL OR d.extras_type NOT IN ('wides') THEN 1 END) AS balls_faced,
    COUNT(CASE WHEN d.batsman_runs = 4 THEN 1 END) AS fours,
    COUNT(CASE WHEN d.batsman_runs = 6 THEN 1 END) AS sixes,
    MAX(d.is_wicket) AS was_dismissed
FROM deliveries d
JOIN matches m ON d.match_id = m.id
GROUP BY d.batter, d.match_id, m.season, m.venue, d.batting_team;

-- Add strike rate column
ALTER TABLE innings_scores ADD COLUMN strike_rate NUMERIC(6,2);
UPDATE innings_scores
SET strike_rate = CASE WHEN balls_faced > 0 THEN ROUND(innings_runs * 100.0 / balls_faced, 2) ELSE 0 END;

-- Consistency Index — Batters (Minimum 30 innings) --
SELECT 
    batter,
    COUNT(*) AS total_innings,
    ROUND(AVG(innings_runs), 2) AS avg_runs_per_innings,
    ROUND(STDDEV(innings_runs), 2) AS std_dev_runs,
    -- Lower CV = more consistent
    ROUND(STDDEV(innings_runs) / NULLIF(AVG(innings_runs), 0), 2) AS coefficient_of_variation,
    ROUND(AVG(strike_rate), 2) AS avg_sr,
    -- How often do they score 30+?
    ROUND(COUNT(CASE WHEN innings_runs >= 30 THEN 1 END) * 100.0 / COUNT(*), 2) AS pct_30_plus,
    -- How often do they fail (under 10)?
    ROUND(COUNT(CASE WHEN innings_runs < 10 THEN 1 END) * 100.0 / COUNT(*), 2) AS pct_failures
FROM innings_scores
GROUP BY batter
HAVING COUNT(*) >= 30
ORDER BY coefficient_of_variation ASC
LIMIT 25;

-- Bowler Consistency — Economy Variation Across Matches --
WITH bowler_match_stats AS (
    SELECT 
        bowler,
        match_id,
        COUNT(CASE WHEN extras_type IS NULL OR extras_type NOT IN ('wides', 'noballs') THEN 1 END) AS balls,
        SUM(total_runs) AS runs_conceded,
        SUM(is_wicket) AS wickets,
        CASE WHEN COUNT(CASE WHEN extras_type IS NULL OR extras_type NOT IN ('wides', 'noballs') THEN 1 END) > 0
             THEN ROUND(SUM(total_runs) * 6.0 / COUNT(CASE WHEN extras_type IS NULL OR extras_type NOT IN ('wides', 'noballs') THEN 1 END), 2)
             ELSE 0 END AS match_economy
    FROM deliveries
    GROUP BY bowler, match_id
    HAVING COUNT(CASE WHEN extras_type IS NULL OR extras_type NOT IN ('wides', 'noballs') THEN 1 END) >= 12  -- At least 2 overs
)
SELECT 
    bowler,
    COUNT(*) AS matches,
    ROUND(AVG(match_economy), 2) AS avg_economy,
    ROUND(STDDEV(match_economy), 2) AS economy_std_dev,
    ROUND(STDDEV(match_economy) / NULLIF(AVG(match_economy), 0), 2) AS economy_cv,
    ROUND(AVG(wickets), 2) AS avg_wickets_per_match
FROM bowler_match_stats
GROUP BY bowler
HAVING COUNT(*) >= 30
ORDER BY economy_cv ASC
LIMIT 25;