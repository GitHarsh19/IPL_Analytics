from db_connection import run_query

print("=" * 70)
print("IPL ANALYTICS — KEY FINDINGS SUMMARY")
print("=" * 70)

# 1. Toss Impact
toss = run_query("SELECT ROUND(SUM(toss_winner_won)*100.0/COUNT(*),1) AS pct FROM match_summary")
print(f"\n1. TOSS IMPACT: Toss winners win {toss['pct'][0]}% of matches")

# 2. Chasing vs Defending
chase = run_query("""
    SELECT ROUND(SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END)*100.0/COUNT(*),1) AS pct 
    FROM match_summary
""")
print(f"2. CHASING WIN %: Teams batting second win {chase['pct'][0]}% of matches")

# 3. 200+ chases
chase_200 = run_query("""
    SELECT 
        COUNT(*) AS total,
        SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END) AS wins
    FROM match_summary WHERE first_innings_score > 200
""")
print(f"3. CHASING 200+: {chase_200['wins'][0]}/{chase_200['total'][0]} successful")

# 4. Top Batter by Value Index
top_bat = run_query("SELECT batter, player_value_index FROM batter_value_index ORDER BY player_value_index DESC LIMIT 1")
print(f"4. TOP BATTER (Value Index): {top_bat['batter'][0]} ({top_bat['player_value_index'][0]})")

# 5. Top Bowler by Value Index
top_bowl = run_query("SELECT bowler, bowler_value_index FROM bowler_value_index ORDER BY bowler_value_index DESC LIMIT 1")
print(f"5. TOP BOWLER (Value Index): {top_bowl['bowler'][0]} ({top_bowl['bowler_value_index'][0]})")

# 6. Most consistent batter
consistent = run_query("""
    SELECT batter, ROUND(STDDEV(innings_runs)/NULLIF(AVG(innings_runs),0), 2) AS cv
    FROM innings_scores GROUP BY batter HAVING COUNT(*) >= 50 ORDER BY cv LIMIT 1
""")
print(f"6. MOST CONSISTENT BATTER (50+ innings): {consistent['batter'][0]} (CV: {consistent['cv'][0]})")

# 7. Death over king
death_king = run_query("""
    SELECT batter, ROUND(SUM(death_runs)*100.0/NULLIF(SUM(death_balls),0), 2) AS death_sr
    FROM batter_stats GROUP BY batter HAVING SUM(death_balls) >= 100
    ORDER BY death_sr DESC LIMIT 1
""")
print(f"7. DEATH OVER KING (100+ balls): {death_king['batter'][0]} (SR: {death_king['death_sr'][0]})")

# 8. Best venue for chasing
best_chase_venue = run_query("""
    SELECT venue, ROUND(SUM(CASE WHEN winner=chasing_team THEN 1 ELSE 0 END)*100.0/COUNT(*),1) AS pct
    FROM match_summary GROUP BY venue HAVING COUNT(*) >= 15
    ORDER BY pct DESC LIMIT 1
""")
print(f"8. BEST CHASE VENUE (15+ matches): {best_chase_venue['venue'][0]} ({best_chase_venue['pct'][0]}%)")

print("\n" + "=" * 70)
print("Use these findings in your README, Tableau dashboard, and interviews!")
print("=" * 70)