import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import run_query

# Set style for all plots
plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("husl")

# -------------------------------------------
# 1.1 Average Score Per Season (Line Chart)
# -------------------------------------------
df = run_query("""
    SELECT 
        season,
        ROUND(AVG(first_innings_score), 1) AS avg_first_innings,
        ROUND(AVG(second_innings_score), 1) AS avg_second_innings
    FROM match_summary
    GROUP BY season
    ORDER BY season
""")

fig, ax = plt.subplots(figsize=(14, 6))
ax.plot(df['season'], df['avg_first_innings'], marker='o', linewidth=2, label='1st Innings Avg', color='#2196F3')
ax.plot(df['season'], df['avg_second_innings'], marker='s', linewidth=2, label='2nd Innings Avg', color='#FF5722')
ax.fill_between(df['season'], df['avg_first_innings'], df['avg_second_innings'], alpha=0.1, color='gray')
ax.set_xlabel('Season', fontsize=12)
ax.set_ylabel('Average Score', fontsize=12)
ax.set_title('IPL Average Innings Score by Season', fontsize=16, fontweight='bold')
ax.legend(fontsize=11)
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/01_scoring_trends.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: /Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/01_scoring_trends.png")


# -------------------------------------------
# 1.2 Phase-wise Run Rate Evolution (Grouped Bar)
# -------------------------------------------
df_phase = run_query("""
    SELECT 
        m.season,
        d.phase,
        ROUND(SUM(d.total_runs) * 6.0 / 
            NULLIF(COUNT(CASE WHEN d.extras_type IS NULL 
                              OR d.extras_type NOT IN ('wides', 'noballs') THEN 1 END), 0), 2) AS run_rate
    FROM deliveries d
    JOIN matches m ON d.match_id = m.id
    GROUP BY m.season, d.phase
    ORDER BY m.season
""")

# Pivot for plotting
pivot = df_phase.pivot(index='season', columns='phase', values='run_rate')
pivot = pivot[['Powerplay', 'Middle', 'Death']]  # Ensure order

fig, ax = plt.subplots(figsize=(14, 6))
pivot.plot(kind='bar', ax=ax, width=0.8, color=['#4CAF50', '#FF9800', '#F44336'])
ax.set_xlabel('Season', fontsize=12)
ax.set_ylabel('Run Rate', fontsize=12)
ax.set_title('Phase-wise Run Rate Evolution Across IPL Seasons', fontsize=16, fontweight='bold')
ax.legend(title='Phase', fontsize=11)
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/02_phase_run_rate.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved: /Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/02_phase_run_rate.png")