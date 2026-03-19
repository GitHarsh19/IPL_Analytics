-- Unique names in all teams --
SELECT DISTINCT team1 AS team_name FROM matches
UNION
SELECT DISTINCT team2 FROM matches
ORDER BY team_name;

-- 2.2 Update matches table — team1
UPDATE matches SET team1 = 'Delhi Capitals' WHERE team1 = 'Delhi Daredevils';
UPDATE matches SET team1 = 'Sunrisers Hyderabad' WHERE team1 = 'Deccan Chargers';
UPDATE matches SET team1 = 'Punjab Kings' WHERE team1 = 'Kings XI Punjab';
UPDATE matches SET team1 = 'Rising Pune Supergiants' WHERE team1 = 'Rising Pune Supergiant';
UPDATE matches SET team1 = 'Royal Challengers Bengaluru' WHERE team1 = 'Royal Challengers Bangalore';

-- 2.3 Update matches table — team2
UPDATE matches SET team2 = 'Delhi Capitals' WHERE team2 = 'Delhi Daredevils';
UPDATE matches SET team2 = 'Sunrisers Hyderabad' WHERE team2 = 'Deccan Chargers';
UPDATE matches SET team2 = 'Punjab Kings' WHERE team2 = 'Kings XI Punjab';
UPDATE matches SET team2 = 'Rising Pune Supergiants' WHERE team2 = 'Rising Pune Supergiant';
UPDATE matches SET team2 = 'Royal Challengers Bengaluru' WHERE team2 = 'Royal Challengers Bangalore';

-- 2.4 Update toss_winner and winner columns too
UPDATE matches SET toss_winner = 'Delhi Capitals' WHERE toss_winner = 'Delhi Daredevils';
UPDATE matches SET toss_winner = 'Sunrisers Hyderabad' WHERE toss_winner = 'Deccan Chargers';
UPDATE matches SET toss_winner = 'Punjab Kings' WHERE toss_winner = 'Kings XI Punjab';
UPDATE matches SET toss_winner = 'Rising Pune Supergiants' WHERE toss_winner = 'Rising Pune Supergiant';
UPDATE matches SET toss_winner = 'Royal Challengers Bengaluru' WHERE toss_winner = 'Royal Challengers Bangalore';

UPDATE matches SET winner = 'Delhi Capitals' WHERE winner = 'Delhi Daredevils';
UPDATE matches SET winner = 'Sunrisers Hyderabad' WHERE winner = 'Deccan Chargers';
UPDATE matches SET winner = 'Punjab Kings' WHERE winner = 'Kings XI Punjab';
UPDATE matches SET winner = 'Rising Pune Supergiants' WHERE winner = 'Rising Pune Supergiant';
UPDATE matches SET winner = 'Royal Challengers Bengaluru' WHERE winner = 'Royal Challengers Bangalore';

-- 2.5 Update deliveries table
UPDATE deliveries SET batting_team = 'Delhi Capitals' WHERE batting_team = 'Delhi Daredevils';
UPDATE deliveries SET batting_team = 'Sunrisers Hyderabad' WHERE batting_team = 'Deccan Chargers';
UPDATE deliveries SET batting_team = 'Punjab Kings' WHERE batting_team = 'Kings XI Punjab';
UPDATE deliveries SET batting_team = 'Rising Pune Supergiants' WHERE batting_team = 'Rising Pune Supergiant';
UPDATE deliveries SET batting_team = 'Royal Challengers Bengaluru' WHERE batting_team = 'Royal Challengers Bangalore';

UPDATE deliveries SET bowling_team = 'Delhi Capitals' WHERE bowling_team = 'Delhi Daredevils';
UPDATE deliveries SET bowling_team = 'Sunrisers Hyderabad' WHERE bowling_team = 'Deccan Chargers';
UPDATE deliveries SET bowling_team = 'Punjab Kings' WHERE bowling_team = 'Kings XI Punjab';
UPDATE deliveries SET bowling_team = 'Rising Pune Supergiants' WHERE bowling_team = 'Rising Pune Supergiant';
UPDATE deliveries SET bowling_team = 'Royal Challengers Bengaluru' WHERE bowling_team = 'Royal Challengers Bangalore';

-- 2.6 Verify — this should show clean, consistent names
SELECT DISTINCT team1 AS team_name FROM matches
UNION
SELECT DISTINCT team2 FROM matches
ORDER BY team_name;


-- Delhi stadium name standardization -- 
UPDATE matches SET venue = 'Arun Jaitley Stadium' WHERE venue IN (
    'Arun Jaitley Stadium, Delhi',
    'Feroz Shah Kotla'
);

-- Bengaluru stadium inconsistency fix --
UPDATE matches SET venue = 'M Chinnaswamy Stadium' WHERE venue IN (
    'M Chinnaswamy Stadium, Bengaluru',
    'M.Chinnaswamy Stadium'
);


UPDATE matches SET venue = 'Wankhede Stadium' WHERE venue = 'Wankhede Stadium, Mumbai';
UPDATE matches SET venue = 'Brabourne Stadium' WHERE venue = 'Brabourne Stadium, Mumbai';
UPDATE matches SET venue = 'Dr DY Patil Sports Academy' WHERE venue = 'Dr DY Patil Sports Academy, Mumbai';

UPDATE matches SET venue = 'Eden Gardens' WHERE venue = 'Eden Gardens, Kolkata';

UPDATE matches SET venue = 'MA Chidambaram Stadium' WHERE venue IN (
    'MA Chidambaram Stadium, Chepauk',
    'MA Chidambaram Stadium, Chepauk, Chennai'
);

UPDATE matches SET venue = 'Rajiv Gandhi International Stadium' WHERE venue IN (
    'Rajiv Gandhi International Stadium, Uppal',
    'Rajiv Gandhi International Stadium, Uppal, Hyderabad'
);

UPDATE matches SET venue = 'Punjab Cricket Association IS Bindra Stadium' WHERE venue IN (
    'Punjab Cricket Association IS Bindra Stadium, Mohali',
    'Punjab Cricket Association IS Bindra Stadium, Mohali, Chandigarh',
    'Punjab Cricket Association Stadium, Mohali'
);

UPDATE matches SET venue = 'Maharashtra Cricket Association Stadium' WHERE venue = 'Maharashtra Cricket Association Stadium, Pune';

UPDATE matches SET venue = 'Sawai Mansingh Stadium' WHERE venue = 'Sawai Mansingh Stadium, Jaipur';

UPDATE matches SET venue = 'Himachal Pradesh Cricket Association Stadium' WHERE venue = 'Himachal Pradesh Cricket Association Stadium, Dharamsala';

UPDATE matches SET venue = 'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium' WHERE venue = 'Dr. Y.S. Rajasekhara Reddy ACA-VDCA Cricket Stadium, Visakhapatnam';

UPDATE matches SET venue = 'Ekana Cricket Stadium' WHERE venue = 'Bharat Ratna Shri Atal Bihari Vajpayee Ekana Cricket Stadium, Lucknow';

UPDATE matches SET venue = 'Barsapara Cricket Stadium' WHERE venue = 'Barsapara Cricket Stadium, Guwahati';

UPDATE matches SET venue = 'Narendra Modi Stadium' WHERE venue IN (
    'Narendra Modi Stadium, Ahmedabad',
    'Sardar Patel Stadium, Motera'
);

UPDATE matches SET venue = 'Zayed Cricket Stadium' WHERE venue = 'Zayed Cricket Stadium, Abu Dhabi';

UPDATE matches SET venue = 'Maharaja Yadavindra Singh International Cricket Stadium' WHERE venue = 'Maharaja Yadavindra Singh International Cricket Stadium, Mullanpur';

UPDATE matches SET city = 'Bengaluru' WHERE city = 'Bangalore';

UPDATE matches SET city = 'Chandigarh' WHERE city = 'Mohali';


-- Filling NULL cities using venue mapping --
UPDATE matches SET city = 'Dubai' WHERE city IS NULL AND venue = 'Dubai International Cricket Stadium';
UPDATE matches SET city = 'Sharjah' WHERE city IS NULL AND venue = 'Sharjah Cricket Stadium';
UPDATE matches SET city = 'Abu Dhabi' WHERE city IS NULL AND venue IN ('Sheikh Zayed Stadium', 'Zayed Cricket Stadium');
UPDATE matches SET city = 'Bengaluru' WHERE city IS NULL AND venue = 'M Chinnaswamy Stadium';
UPDATE matches SET city = 'Mumbai' WHERE city IS NULL AND venue IN ('Wankhede Stadium', 'Brabourne Stadium', 'Dr DY Patil Sports Academy');
UPDATE matches SET city = 'Chennai' WHERE city IS NULL AND venue = 'MA Chidambaram Stadium';
UPDATE matches SET city = 'Kolkata' WHERE city IS NULL AND venue = 'Eden Gardens';
UPDATE matches SET city = 'Delhi' WHERE city IS NULL AND venue = 'Arun Jaitley Stadium';
UPDATE matches SET city = 'Hyderabad' WHERE city IS NULL AND venue = 'Rajiv Gandhi International Stadium';
UPDATE matches SET city = 'Chandigarh' WHERE city IS NULL AND venue = 'Punjab Cricket Association IS Bindra Stadium';
UPDATE matches SET city = 'Pune' WHERE city IS NULL AND venue = 'Maharashtra Cricket Association Stadium';
UPDATE matches SET city = 'Jaipur' WHERE city IS NULL AND venue = 'Sawai Mansingh Stadium';
UPDATE matches SET city = 'Ahmedabad' WHERE city IS NULL AND venue = 'Narendra Modi Stadium';


UPDATE deliveries d
SET venue = m.venue
FROM matches m
WHERE d.match_id = m.id;


-- verify --

-- Check venues are clean
SELECT venue, COUNT(*) AS matches
FROM matches
GROUP BY venue
ORDER BY matches DESC;

-- Check cities are clean
SELECT city, COUNT(*) AS matches
FROM matches
GROUP BY city
ORDER BY matches DESC;

-- Check no NULL cities remain
SELECT COUNT(*) AS null_cities
FROM matches
WHERE city IS NULL OR city = '';

-- Final count
SELECT 
    COUNT(DISTINCT venue) AS unique_venues,
    COUNT(DISTINCT city) AS unique_cities
FROM matches;