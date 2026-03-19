-- Venue list --
SELECT venue, COUNT(*) FROM matches GROUP BY venue ORDER BY venue;

-- City list --
SELECT city, COUNT(*) FROM matches GROUP BY city ORDER BY city;


SELECT COUNT(*) FROM batter_stats;
SELECT COUNT(*) FROM bowler_stats;
SELECT COUNT(*) FROM match_summary;
SELECT DISTINCT phase FROM deliveries;