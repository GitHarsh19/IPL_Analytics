-- 6.1 Check for orphan deliveries (no matching match)
SELECT COUNT(*) AS orphan_balls
FROM deliveries d
LEFT JOIN matches m ON d.match_id = m.id
WHERE m.id IS NULL;

-- 6.2 Check for matches with no deliveries
SELECT COUNT(*) AS matches_without_balls
FROM matches m
LEFT JOIN deliveries d ON m.id = d.match_id
WHERE d.match_id IS NULL;

-- 6.3 Verify team names are now consistent
SELECT DISTINCT batting_team FROM deliveries
EXCEPT
SELECT DISTINCT team1 FROM matches;
-- Should return empty or only teams that appeared in one table

-- 6.4 Check phase tagging completeness
SELECT 
    COUNT(*) AS total,
    COUNT(phase) AS has_phase,
    COUNT(*) - COUNT(phase) AS missing_phase
FROM deliveries;

-- 6.5 Spot check: Does Virat Kohli's career total look right?
SELECT SUM(runs_scored) AS career_runs
FROM batter_stats 
WHERE batter = 'V Kohli';