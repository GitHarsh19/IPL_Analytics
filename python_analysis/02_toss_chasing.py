import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import run_query

plt.style.use('seaborn-v0_8-whitegrid')

# -------------------------------------------
# 2.1 Toss Win % Trend Over Seasons
# -------------------------------------------
df_toss = run_query("""
    SELECT 
        season,
        ROUND(SUM(toss_winner_won) * 100.0 / COUNT(*), 2) AS toss_win_pct,
        ROUND(SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS field_choice_pct
    FROM match_summary
    GROUP BY season
    ORDER BY season
""")

fig, ax1 = plt.subplots(figsize=(14, 6))

# Toss win % as bars
bars = ax1.bar(df_toss['season'], df_toss['toss_win_pct'], alpha=0.6, color='#2196F3', label='Toss Winner Win %')
ax1.axhline(y=50, color='red', linestyle='--', linewidth=1, alpha=0.7, label='50% baseline')
ax1.set_xlabel('Season', fontsize=12)
ax1.set_ylabel('Toss Winner Win %', fontsize=12, color='#2196F3')

# Field choice % as line on secondary axis
ax2 = ax1.twinx()
ax2.plot(df_toss['season'], df_toss['field_choice_pct'], color='#FF5722', marker='o', linewidth=2, label='Chose to Field %')
ax2.set_ylabel('Chose to Field %', fontsize=12, color='#FF5722')

# Combined legend
lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2, loc='upper left', fontsize=10)

plt.title('Toss Impact & Field Choice Trend Across Seasons', fontsize=16, fontweight='bold')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/03_toss_impact_trend.png', dpi=150, bbox_inches='tight')
plt.show()


# -------------------------------------------
# 2.2 Chasing Success by Target Range (Horizontal Bar)
# -------------------------------------------
df_chase = run_query("""
    SELECT 
        CASE 
            WHEN first_innings_score < 130 THEN '1. Under 130'
            WHEN first_innings_score BETWEEN 130 AND 149 THEN '2. 130-149'
            WHEN first_innings_score BETWEEN 150 AND 169 THEN '3. 150-169'
            WHEN first_innings_score BETWEEN 170 AND 185 THEN '4. 170-185'
            WHEN first_innings_score BETWEEN 186 AND 200 THEN '5. 186-200'
            WHEN first_innings_score > 200 THEN '6. 200+'
        END AS target_range,
        COUNT(*) AS matches,
        ROUND(SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS chase_win_pct
    FROM match_summary
    WHERE first_innings_score IS NOT NULL
    GROUP BY 1
    ORDER BY 1
""")

colors = ['#4CAF50' if x > 50 else '#F44336' for x in df_chase['chase_win_pct']]

fig, ax = plt.subplots(figsize=(10, 6))
bars = ax.barh(df_chase['target_range'], df_chase['chase_win_pct'], color=colors, height=0.6)

# Add match count labels
for i, (pct, matches) in enumerate(zip(df_chase['chase_win_pct'], df_chase['matches'])):
    ax.text(pct + 1, i, f'{pct}% ({matches} matches)', va='center', fontsize=10)

ax.axvline(x=50, color='gray', linestyle='--', linewidth=1, alpha=0.7)
ax.set_xlabel('Chasing Win %', fontsize=12)
ax.set_title('Chasing Success Rate by Target Range', fontsize=16, fontweight='bold')
ax.set_xlim(0, 100)
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/04_chasing_by_target.png', dpi=150, bbox_inches='tight')
plt.show()