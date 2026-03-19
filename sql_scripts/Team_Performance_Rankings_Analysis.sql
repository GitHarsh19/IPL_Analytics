-- Overall Team Rankings with Win % --
WITH team_matches AS (
    SELECT winner AS team, COUNT(*) AS wins FROM match_summary GROUP BY winner
),
total_matches AS (
    SELECT team, COUNT(*) AS played FROM (
        SELECT team1 AS team FROM match_summary
        UNION ALL
        SELECT team2 FROM match_summary
    ) t
    GROUP BY team
)
SELECT 
    tm.team,
    tm.played,
    COALESCE(tw.wins, 0) AS wins,
    tm.played - COALESCE(tw.wins, 0) AS losses,
    ROUND(COALESCE(tw.wins, 0) * 100.0 / tm.played, 2) AS win_pct
FROM total_matches tm
LEFT JOIN team_matches tw ON tm.team = tw.team
WHERE tm.played >= 20
ORDER BY win_pct DESC;

-- Team Performance by Phase (Run Rate) --
SELECT 
    d.batting_team,
    d.phase,
    ROUND(SUM(d.total_runs) * 6.0 / 
        NULLIF(COUNT(CASE WHEN d.extras_type IS NULL 
                          OR d.extras_type NOT IN ('wides', 'noballs') THEN 1 END), 0), 2) AS batting_rr,
    COUNT(DISTINCT d.match_id) AS matches
FROM deliveries d
GROUP BY d.batting_team, d.phase
HAVING COUNT(DISTINCT d.match_id) >= 20
ORDER BY d.batting_team, MIN(d."over");

-- Best Chasing Teams --
SELECT 
    chasing_team,
    COUNT(*) AS chasing_matches,
    SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END) AS chasing_wins,
    ROUND(SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chase_win_pct
FROM match_summary
GROUP BY chasing_team
HAVING COUNT(*) >= 20
ORDER BY chase_win_pct DESC;