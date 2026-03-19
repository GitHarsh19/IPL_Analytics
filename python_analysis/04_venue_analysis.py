import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import run_query

plt.style.use('seaborn-v0_8-whitegrid')

# -------------------------------------------
# 4.1 Venue Comparison Heatmap
# -------------------------------------------
df_venue = run_query("""
    SELECT 
        venue,
        COUNT(*) AS matches,
        ROUND(AVG(first_innings_score), 1) AS avg_1st_innings,
        ROUND(SUM(CASE WHEN winner = chasing_team THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS chase_win_pct,
        ROUND(SUM(toss_winner_won) * 100.0 / COUNT(*), 1) AS toss_win_pct
    FROM match_summary
    GROUP BY venue
    HAVING COUNT(*) >= 15
    ORDER BY avg_1st_innings DESC
""")

# Prepare heatmap data
heatmap_data = df_venue.set_index('venue')[['avg_1st_innings', 'chase_win_pct', 'toss_win_pct']]
heatmap_data.columns = ['Avg 1st Innings', 'Chase Win %', 'Toss Win %']

# Normalize for color mapping (each column scaled 0-1)
heatmap_normalized = (heatmap_data - heatmap_data.min()) / (heatmap_data.max() - heatmap_data.min())

fig, ax = plt.subplots(figsize=(10, 12))
sns.heatmap(heatmap_normalized, annot=heatmap_data.values, fmt='.1f', 
            cmap='RdYlGn', linewidths=0.5, ax=ax,
            cbar_kws={'label': 'Relative Scale'})
ax.set_title('IPL Venue Intelligence Heatmap', fontsize=16, fontweight='bold')
ax.set_ylabel('')
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/08_venue_heatmap.png', dpi=150, bbox_inches='tight')
plt.show()


# -------------------------------------------
# 4.2 Phase-wise Run Rate by Venue (Grouped Bar)
# -------------------------------------------
df_phase_venue = run_query("""
    SELECT 
        d.venue,
        d.phase,
        ROUND(SUM(d.total_runs) * 6.0 / 
            NULLIF(COUNT(CASE WHEN d.extras_type IS NULL 
                              OR d.extras_type NOT IN ('wides', 'noballs') THEN 1 END), 0), 2) AS run_rate
    FROM deliveries d
    WHERE d.venue IN (
        SELECT venue FROM matches GROUP BY venue HAVING COUNT(*) >= 20
    )
    GROUP BY d.venue, d.phase
""")

pivot = df_phase_venue.pivot(index='venue', columns='phase', values='run_rate')
pivot = pivot[['Powerplay', 'Middle', 'Death']]
pivot = pivot.sort_values('Death', ascending=True)

fig, ax = plt.subplots(figsize=(12, 10))
pivot.plot(kind='barh', ax=ax, color=['#4CAF50', '#FF9800', '#F44336'], width=0.7)
ax.set_xlabel('Run Rate', fontsize=12)
ax.set_title('Phase-wise Run Rate by Venue', fontsize=16, fontweight='bold')
ax.legend(title='Phase')
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/09_venue_phase_runrate.png', dpi=150, bbox_inches='tight')
plt.show()