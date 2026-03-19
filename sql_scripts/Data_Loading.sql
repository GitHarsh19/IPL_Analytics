-- Drop old tables if they exist
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS matches;

CREATE TABLE matches (
    id INT PRIMARY KEY,
    season VARCHAR(10),
    city VARCHAR(50),
    date DATE,
    match_type VARCHAR(20),
    player_of_match VARCHAR(50),
    venue VARCHAR(100),
    team1 VARCHAR(50),
    team2 VARCHAR(50),
    toss_winner VARCHAR(50),
    toss_decision VARCHAR(10),
    winner VARCHAR(50),
    result VARCHAR(10),
    result_margin INT,
    target_runs INT,
    target_overs FLOAT,
    super_over VARCHAR(5),
    method VARCHAR(10),
    umpire1 VARCHAR(50),
    umpire2 VARCHAR(50)
);

-- Create deliveries table ("over" is quoted because it's a reserved keyword)
CREATE TABLE deliveries (
    match_id INT,
    inning INT,
    batting_team VARCHAR(50),
    bowling_team VARCHAR(50),
    "over" INT,
    ball INT,
    batter VARCHAR(50),
    bowler VARCHAR(50),
    non_striker VARCHAR(50),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    extras_type VARCHAR(20),
    is_wicket INT,
    player_dismissed VARCHAR(50),
    dismissal_kind VARCHAR(30),
    fielder VARCHAR(50)
);

-- Now load the data
\copy matches FROM '/Users/harshitagarwal/Desktop/Projects/IPL_Analytics/matches.csv' WITH CSV HEADER NULL '';
\copy deliveries FROM '/Users/harshitagarwal/Desktop/Projects/IPL_Analytics/deliveries.csv' WITH CSV HEADER NULL '';


select * from matches limit 10;
select count(*) from deliveries;
commit;
