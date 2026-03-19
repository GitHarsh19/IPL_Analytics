-- Overall Toss Impact Analysis --
SELECT 
    COUNT(*) AS total_matches,
    SUM(toss_winner_won) AS toss_winner_won_match,
    ROUND(SUM(toss_winner_won) * 100.0 / COUNT(*), 2) AS toss_win_pct
FROM match_summary;

-- Toss Impact by Decision (Bat vs Field) --
SELECT 
    toss_decision,
    COUNT(*) AS matches,
    SUM(toss_winner_won) AS toss_winner_won_match,
    ROUND(SUM(toss_winner_won) * 100.0 / COUNT(*), 2) AS win_pct
FROM match_summary
GROUP BY toss_decision
ORDER BY win_pct DESC;

-- Toss Impact by Venue (Minimum 10 matches) --
SELECT 
    venue,
    COUNT(*) AS matches,
    SUM(toss_winner_won) AS toss_wins,
    ROUND(SUM(toss_winner_won) * 100.0 / COUNT(*), 2) AS toss_win_pct,
    -- What do toss winners usually choose here?
    SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END) AS chose_field,
    ROUND(SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS field_choice_pct
FROM match_summary
GROUP BY venue
HAVING COUNT(*) >= 10
ORDER BY toss_win_pct DESC;

-- Toss Impact Trend Over Seasons --
SELECT 
    season,
    COUNT(*) AS matches,
    ROUND(SUM(toss_winner_won) * 100.0 / COUNT(*), 2) AS toss_win_pct,
    ROUND(SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS field_choice_pct
FROM match_summary
GROUP BY season
ORDER BY season;