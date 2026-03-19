import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from db_connection import run_query

# -------------------------------------------
# 7.1 Team Performance Radar — Top 4 Teams
# -------------------------------------------
df = run_query("""
    WITH team_stats AS (
        SELECT 
            batting_team AS team,
            ROUND(SUM(total_runs) * 6.0 / 
                NULLIF(COUNT(CASE WHEN extras_type IS NULL OR extras_type NOT IN ('wides','noballs') THEN 1 END), 0), 2) AS overall_rr,
            ROUND(SUM(CASE WHEN phase='Powerplay' THEN total_runs ELSE 0 END) * 6.0 / 
                NULLIF(COUNT(CASE WHEN phase='Powerplay' AND (extras_type IS NULL OR extras_type NOT IN ('wides','noballs')) THEN 1 END), 0), 2) AS pp_rr,
            ROUND(SUM(CASE WHEN phase='Death' THEN total_runs ELSE 0 END) * 6.0 / 
                NULLIF(COUNT(CASE WHEN phase='Death' AND (extras_type IS NULL OR extras_type NOT IN ('wides','noballs')) THEN 1 END), 0), 2) AS death_rr,
            ROUND(COUNT(CASE WHEN batsman_runs IN (4,6) THEN 1 END) * 100.0 / COUNT(*), 2) AS boundary_pct
        FROM deliveries
        GROUP BY batting_team
        HAVING COUNT(DISTINCT match_id) >= 50
    ),
    win_stats AS (
        SELECT 
            winner AS team,
            COUNT(*) AS wins
        FROM match_summary
        GROUP BY winner
    ),
    total_stats AS (
        SELECT team, COUNT(*) AS played FROM (
            SELECT team1 AS team FROM match_summary
            UNION ALL SELECT team2 FROM match_summary
        ) t GROUP BY team
    )
    SELECT 
        ts.team,
        ts.overall_rr,
        ts.pp_rr,
        ts.death_rr,
        ts.boundary_pct,
        ROUND(COALESCE(ws.wins, 0) * 100.0 / tot.played, 2) AS win_pct
    FROM team_stats ts
    LEFT JOIN win_stats ws ON ts.team = ws.team
    LEFT JOIN total_stats tot ON ts.team = tot.team
    ORDER BY win_pct DESC
""")

# Select top 4 teams by win %
top4 = df.head(4)
categories = ['Overall RR', 'Powerplay RR', 'Death RR', 'Boundary %', 'Win %']

fig, ax = plt.subplots(figsize=(10, 10), subplot_kw=dict(polar=True))
angles = np.linspace(0, 2 * np.pi, len(categories), endpoint=False).tolist()
angles += angles[:1]  # Close the polygon

colors = ['#FFB300', '#1E88E5', '#D32F2F', '#7B1FA2']

for i, (_, row) in enumerate(top4.iterrows()):
    # Normalize each metric to 0-100 scale
    values = [
        row['overall_rr'] / df['overall_rr'].max() * 100,
        row['pp_rr'] / df['pp_rr'].max() * 100,
        row['death_rr'] / df['death_rr'].max() * 100,
        row['boundary_pct'] / df['boundary_pct'].max() * 100,
        row['win_pct'] / df['win_pct'].max() * 100,
    ]
    values += values[:1]
    ax.plot(angles, values, 'o-', linewidth=2, label=row['team'], color=colors[i])
    ax.fill(angles, values, alpha=0.1, color=colors[i])

ax.set_xticks(angles[:-1])
ax.set_xticklabels(categories, fontsize=11)
ax.set_title('Top 4 IPL Teams — Performance Radar', fontsize=16, fontweight='bold', y=1.1)
ax.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1), fontsize=10)
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/14_team_radar.png', dpi=150, bbox_inches='tight')
plt.show()