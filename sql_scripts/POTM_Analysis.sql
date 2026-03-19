-- What stats do POTM winners typically put up?
SELECT 
    ms.player_of_match,
    COUNT(*) AS potm_awards,
    ROUND(AVG(i.innings_runs), 1) AS avg_runs_in_potm_matches,
    ROUND(AVG(i.strike_rate), 1) AS avg_sr_in_potm_matches
FROM match_summary ms
JOIN innings_scores i ON ms.match_id = i.match_id AND ms.player_of_match = i.batter
GROUP BY ms.player_of_match
HAVING COUNT(*) >= 5
ORDER BY potm_awards DESC
LIMIT 20;