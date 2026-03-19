-- checking row counts and renaming them -- 
select count(*) as total_matches from matches;
select count(*) as total_deliveries from deliveries;

-- distinct seasons available --
select distinct season from matches order by season;

-- distinct team names --
select distinct team1 from matches order by team1;
-- there are several errors in team names in both team1 and team2 -- 

-- checking for null in important columns --
SELECT 
    COUNT(*) as total,
    COUNT(winner) as has_winner,
    COUNT(city) as has_city,
    COUNT(result_margin) as has_margin,
    COUNT(player_of_match) as has_potm,
    COUNT(toss_winner) as has_toss_winner,
    count(toss_decision ) as has_toss_decision,
    
FROM matches;

-- check deliveries also -- 
SELECT * FROM deliveries LIMIT 10;

-- check extras in deliveries -- 
SELECT DISTINCT extras_type FROM deliveries;

-- check dismissal's type --
SELECT DISTINCT dismissal_kind FROM deliveries WHERE is_wicket = 1;

