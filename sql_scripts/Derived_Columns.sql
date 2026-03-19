-- adding a phase column for PP overs --
ALTER TABLE deliveries ADD COLUMN phase VARCHAR(10);

-- Tag each ball with its phase -- 
UPDATE deliveries
SET phase = CASE
    WHEN "over" BETWEEN 0 AND 5 THEN 'Powerplay'    -- Overs 1-6 (0-indexed: 0-5)
    WHEN "over" BETWEEN 6 AND 14 THEN 'Middle'      -- Overs 7-15
    WHEN "over" BETWEEN 15 AND 19 THEN 'Death'      -- Overs 16-20
END;

-- Verifying the distribution -- 
SELECT phase, COUNT(*) AS balls, 
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct
FROM deliveries
GROUP BY phase
ORDER BY MIN("over");


-- doing time based analysis --
ALTER TABLE deliveries ADD COLUMN season VARCHAR(10);

UPDATE deliveries d
SET season = m.season
FROM matches m
WHERE d.match_id = m.id;

SELECT season, COUNT(*) AS total_balls
FROM deliveries
GROUP BY season
ORDER BY season;

-- add venue to deliveries --
ALTER TABLE deliveries ADD COLUMN venue VARCHAR(100);

UPDATE deliveries d
SET venue = m.venue
FROM matches m
WHERE d.match_id = m.id;

SELECT venue FROM deliveries group by venue;
-- !! venue names are not standardized !! -- 