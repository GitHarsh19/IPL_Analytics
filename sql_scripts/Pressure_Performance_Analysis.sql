-- analysing the performance of batters under pressure --
WITH chase_pressure AS (
    SELECT 
        d.batter,
        d.match_id,
        d."over",
        SUM(d.batsman_runs) AS runs,
        COUNT(CASE WHEN d.extras_type IS NULL OR d.extras_type NOT IN ('wides') THEN 1 END) AS balls,
        -- Calculate required run rate at each point
        ms.first_innings_score + 1 AS target,
        SUM(SUM(d.total_runs)) OVER (PARTITION BY d.match_id ORDER BY d."over") AS cumulative_team_runs
    FROM deliveries d
    JOIN match_summary ms ON d.match_id = ms.match_id
    WHERE d.inning = 2
    GROUP BY d.batter, d.match_id, d."over", ms.first_innings_score
)
SELECT 
    batter,
    COUNT(DISTINCT match_id) AS pressure_chases,
    SUM(runs) AS total_runs_in_pressure,
    SUM(balls) AS total_balls_in_pressure,
    ROUND(SUM(runs) * 100.0 / NULLIF(SUM(balls), 0), 2) AS pressure_strike_rate
FROM chase_pressure
WHERE (target - cumulative_team_runs) * 6.0 / NULLIF((20 - "over") * 6, 0) > 10  -- RRR > 10
GROUP BY batter
HAVING SUM(balls) >= 50
ORDER BY pressure_strike_rate DESC
LIMIT 20;