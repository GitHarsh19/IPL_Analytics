-- BATTER STATS TABLES -- 

CREATE TABLE batter_stats AS
SELECT 
    d.batter,
    d.season,
    COUNT(CASE WHEN d.extras_type IS NULL 
               OR d.extras_type NOT IN ('wides') THEN 1 END) AS balls_faced,
    SUM(d.batsman_runs) AS runs_scored,
    COUNT(CASE WHEN d.batsman_runs = 4 THEN 1 END) AS fours,
    COUNT(CASE WHEN d.batsman_runs = 6 THEN 1 END) AS sixes,
    SUM(CASE WHEN d.batsman_runs = 0 
              AND (d.extras_type IS NULL OR d.extras_type NOT IN ('wides','noballs')) 
         THEN 1 ELSE 0 END) AS dot_balls,
    
    -- Phase-wise runs
    SUM(CASE WHEN d.phase = 'Powerplay' THEN d.batsman_runs ELSE 0 END) AS powerplay_runs,
    SUM(CASE WHEN d.phase = 'Middle' THEN d.batsman_runs ELSE 0 END) AS middle_runs,
    SUM(CASE WHEN d.phase = 'Death' THEN d.batsman_runs ELSE 0 END) AS death_runs,
    
    -- Phase-wise balls
    COUNT(CASE WHEN d.phase = 'Powerplay' 
               AND (d.extras_type IS NULL OR d.extras_type NOT IN ('wides')) THEN 1 END) AS powerplay_balls,
    COUNT(CASE WHEN d.phase = 'Middle' 
               AND (d.extras_type IS NULL OR d.extras_type NOT IN ('wides')) THEN 1 END) AS middle_balls,
    COUNT(CASE WHEN d.phase = 'Death' 
               AND (d.extras_type IS NULL OR d.extras_type NOT IN ('wides')) THEN 1 END) AS death_balls,
    
    -- Dismissals (how many times out)
    COUNT(CASE WHEN d.is_wicket = 1 AND d.player_dismissed = d.batter THEN 1 END) AS times_dismissed,
    
    -- Matches played
    COUNT(DISTINCT d.match_id) AS matches

FROM deliveries d
GROUP BY d.batter, d.season;

-- Add computed columns
ALTER TABLE batter_stats ADD COLUMN strike_rate NUMERIC(6,2);
ALTER TABLE batter_stats ADD COLUMN average NUMERIC(6,2);
ALTER TABLE batter_stats ADD COLUMN boundary_pct NUMERIC(5,2);
ALTER TABLE batter_stats ADD COLUMN death_strike_rate NUMERIC(6,2);

UPDATE batter_stats
SET 
    strike_rate = CASE WHEN balls_faced > 0 THEN ROUND(runs_scored * 100.0 / balls_faced, 2) ELSE 0 END,
    average = CASE WHEN times_dismissed > 0 THEN ROUND(runs_scored * 1.0 / times_dismissed, 2) ELSE runs_scored END,
    boundary_pct = CASE WHEN balls_faced > 0 THEN ROUND((fours + sixes) * 100.0 / balls_faced, 2) ELSE 0 END,
    death_strike_rate = CASE WHEN death_balls > 0 THEN ROUND(death_runs * 100.0 / death_balls, 2) ELSE 0 END;

-- Verify: Top 10 run scorers all-time
SELECT batter, SUM(runs_scored) AS total_runs, 
       ROUND(AVG(strike_rate), 2) AS avg_sr
FROM batter_stats
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;


-- BOWLER STATS TABLES --
CREATE TABLE bowler_stats AS
SELECT 
    d.bowler,
    d.season,
    COUNT(CASE WHEN d.extras_type IS NULL 
               OR d.extras_type NOT IN ('wides', 'noballs') THEN 1 END) AS balls_bowled,
    SUM(d.total_runs) AS runs_conceded,
    SUM(d.is_wicket) AS wickets,
    SUM(CASE WHEN d.batsman_runs = 0 
              AND d.extra_runs = 0 THEN 1 ELSE 0 END) AS dot_balls,
    
    -- Phase-wise wickets
    SUM(CASE WHEN d.phase = 'Powerplay' THEN d.is_wicket ELSE 0 END) AS powerplay_wickets,
    SUM(CASE WHEN d.phase = 'Middle' THEN d.is_wicket ELSE 0 END) AS middle_wickets,
    SUM(CASE WHEN d.phase = 'Death' THEN d.is_wicket ELSE 0 END) AS death_wickets,
    
    -- Phase-wise runs conceded
    SUM(CASE WHEN d.phase = 'Death' THEN d.total_runs ELSE 0 END) AS death_runs_conceded,
    COUNT(CASE WHEN d.phase = 'Death' 
               AND (d.extras_type IS NULL OR d.extras_type NOT IN ('wides','noballs')) 
          THEN 1 END) AS death_balls,
    
    -- Matches
    COUNT(DISTINCT d.match_id) AS matches

FROM deliveries d
GROUP BY d.bowler, d.season;

-- Add computed columns
ALTER TABLE bowler_stats ADD COLUMN economy NUMERIC(5,2);
ALTER TABLE bowler_stats ADD COLUMN bowling_average NUMERIC(6,2);
ALTER TABLE bowler_stats ADD COLUMN bowling_sr NUMERIC(6,2);
ALTER TABLE bowler_stats ADD COLUMN death_economy NUMERIC(5,2);

UPDATE bowler_stats
SET 
    economy = CASE WHEN balls_bowled > 0 THEN ROUND(runs_conceded * 6.0 / balls_bowled, 2) ELSE 0 END,
    bowling_average = CASE WHEN wickets > 0 THEN ROUND(runs_conceded * 1.0 / wickets, 2) ELSE 0 END,
    bowling_sr = CASE WHEN wickets > 0 THEN ROUND(balls_bowled * 1.0 / wickets, 2) ELSE 0 END,
    death_economy = CASE WHEN death_balls > 0 THEN ROUND(death_runs_conceded * 6.0 / death_balls, 2) ELSE 0 END;

-- Verify: Top 10 wicket takers all-time
SELECT bowler, SUM(wickets) AS total_wickets, 
       ROUND(AVG(economy), 2) AS avg_economy
FROM bowler_stats
GROUP BY bowler
ORDER BY total_wickets DESC
LIMIT 10;

-- MATCH SUMMARY TABLE --
CREATE TABLE match_summary AS
SELECT 
    m.id AS match_id,
    m.season,
    m.city,
    m.venue,
    m.date,
    m.team1,
    m.team2,
    m.toss_winner,
    m.toss_decision,
    m.winner,
    m.result,
    m.result_margin,
    m.player_of_match,
    
    -- Did toss winner win the match?
    CASE WHEN m.toss_winner = m.winner THEN 1 ELSE 0 END AS toss_winner_won,
    
    -- Batting first team & score
    CASE 
        WHEN m.toss_decision = 'bat' THEN m.toss_winner
        ELSE CASE WHEN m.toss_winner = m.team1 THEN m.team2 ELSE m.team1 END
    END AS batting_first_team,
    
    CASE 
        WHEN m.toss_decision = 'field' THEN m.toss_winner
        ELSE CASE WHEN m.toss_winner = m.team1 THEN m.team2 ELSE m.team1 END
    END AS chasing_team

FROM matches m
WHERE m.winner IS NOT NULL;  -- Exclude no-results

-- Add first innings and second innings scores
ALTER TABLE match_summary ADD COLUMN first_innings_score INT;
ALTER TABLE match_summary ADD COLUMN second_innings_score INT;

UPDATE match_summary ms
SET first_innings_score = sub.total
FROM (
    SELECT match_id, SUM(total_runs) AS total
    FROM deliveries WHERE inning = 1
    GROUP BY match_id
) sub
WHERE ms.match_id = sub.match_id;

UPDATE match_summary ms
SET second_innings_score = sub.total
FROM (
    SELECT match_id, SUM(total_runs) AS total
    FROM deliveries WHERE inning = 2
    GROUP BY match_id
) sub
WHERE ms.match_id = sub.match_id;

-- Verify
SELECT * FROM match_summary;
-- !! ids are a problem here !! --