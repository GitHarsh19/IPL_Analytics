-- CTE --> Ball-by-Ball Run Rate Progression --

-- Shows cumulative run rate after each over for a specific match
WITH over_runs AS (
    SELECT 
        match_id,
        inning,
        batting_team,
        "over",
        SUM(total_runs) AS runs_in_over,
        SUM(SUM(total_runs)) OVER (
            PARTITION BY match_id, inning 
            ORDER BY "over"
        ) AS cumulative_runs,
        ("over" + 1) AS overs_completed
    FROM deliveries
    GROUP BY match_id, inning, batting_team, "over"
)
SELECT 
    match_id,
    inning,
    batting_team,
    overs_completed,
    runs_in_over,
    cumulative_runs,
    ROUND(cumulative_runs * 1.0 / overs_completed, 2) AS current_run_rate
FROM over_runs
WHERE match_id = (SELECT id FROM matches ORDER BY date DESC LIMIT 1)
ORDER BY inning, overs_completed;


-- RANK --

WITH season_batting AS (
    SELECT 
        batter,
        season,
        SUM(runs_scored) AS total_runs,
        ROUND(AVG(strike_rate), 2) AS avg_sr,
        RANK() OVER (PARTITION BY season ORDER BY SUM(runs_scored) DESC) AS rank_in_season
    FROM batter_stats
    GROUP BY batter, season
)
SELECT * FROM season_batting
WHERE rank_in_season <= 5
ORDER BY season, rank_in_season;


-- LAG —-> Season-over-Season Performance Change --

WITH yearly_runs AS (
    SELECT 
        batter,
        season,
        SUM(runs_scored) AS runs
    FROM batter_stats
    GROUP BY batter, season
),
with_prev AS (
    SELECT 
        batter,
        season,
        runs,
        LAG(runs) OVER (PARTITION BY batter ORDER BY season) AS prev_season_runs
    FROM yearly_runs
)
SELECT 
    batter,
    season,
    runs,
    prev_season_runs,
    CASE 
        WHEN prev_season_runs > 0 
        THEN ROUND((runs - prev_season_runs) * 100.0 / prev_season_runs, 1)
        ELSE NULL 
    END AS pct_change
FROM with_prev
WHERE prev_season_runs IS NOT NULL
ORDER BY ABS(runs - prev_season_runs) DESC
LIMIT 20;

-- ROW_NUMBER —-> Identify Each Player's Best Innings --

WITH innings_scores AS (
    SELECT 
        batter,
        match_id,
        SUM(batsman_runs) AS innings_runs,
        COUNT(CASE WHEN extras_type IS NULL OR extras_type NOT IN ('wides') THEN 1 END) AS balls,
        COUNT(CASE WHEN batsman_runs = 4 THEN 1 END) AS fours,
        COUNT(CASE WHEN batsman_runs = 6 THEN 1 END) AS sixes,
        ROW_NUMBER() OVER (
            PARTITION BY batter 
            ORDER BY SUM(batsman_runs) DESC
        ) AS innings_rank
    FROM deliveries
    GROUP BY batter, match_id
)

SELECT 
    i.batter,
    i.innings_runs,
    i.balls,
    i.fours,
    i.sixes,
    ROUND(i.innings_runs * 100.0 / NULLIF(i.balls, 0), 2) AS strike_rate,
    m.season,
    m.venue
    
FROM innings_scores i
JOIN matches m ON i.match_id = m.id
WHERE i.innings_rank = 1  -- Best innings for each player
ORDER BY i.innings_runs DESC
LIMIT 20;