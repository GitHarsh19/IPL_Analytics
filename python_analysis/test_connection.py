from db_connection import load_table, run_query

# Test loading tables
matches = load_table("match_summary")
deliveries = load_table("deliveries")
batter_idx = load_table("batter_value_index")
bowler_idx = load_table("bowler_value_index")
innings = load_table("innings_scores")

print(f"Match Summary: {len(matches)} rows")
print(f"Deliveries: {len(deliveries)} rows")
print(f"Batter Value Index: {len(batter_idx)} rows")
print(f"Bowler Value Index: {len(bowler_idx)} rows")
print(f"Innings Scores: {len(innings)} rows")
print("\nConnection successful!")