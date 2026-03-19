import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db_connection import run_query

plt.style.use('seaborn-v0_8-whitegrid')

# -------------------------------------------
# 5.1 Death Over Batting — SR vs Boundary %
# -------------------------------------------
df_death = run_query("""
    SELECT 
        bs.batter,
        SUM(bs.death_runs) AS death_runs,
        SUM(bs.death_balls) AS death_balls,
        ROUND(SUM(bs.death_runs) * 100.0 / NULLIF(SUM(bs.death_balls), 0), 2) AS death_sr,
        sub.death_boundaries,
        ROUND(sub.death_boundaries * 100.0 / NULLIF(SUM(bs.death_balls), 0), 2) AS death_boundary_pct
    FROM batter_stats bs
    JOIN (
        SELECT batter, COUNT(CASE WHEN phase = 'Death' AND batsman_runs IN (4, 6) THEN 1 END) AS death_boundaries
        FROM deliveries GROUP BY batter
    ) sub ON bs.batter = sub.batter
    GROUP BY bs.batter, sub.death_boundaries
    HAVING SUM(bs.death_balls) >= 80
""")

fig, ax = plt.subplots(figsize=(12, 8))
scatter = ax.scatter(df_death['death_boundary_pct'], df_death['death_sr'], 
                     s=df_death['death_balls'] / 3, alpha=0.6, 
                     c=df_death['death_runs'], cmap='YlOrRd',
                     edgecolors='gray', linewidth=0.5)

# Label top performers
top = df_death.nlargest(8, 'death_sr')
for _, row in top.iterrows():
    ax.annotate(row['batter'], (row['death_boundary_pct'], row['death_sr']),
                xytext=(5, 5), textcoords='offset points', fontsize=9, fontweight='bold')

plt.colorbar(scatter, label='Total Death Runs')
ax.set_xlabel('Death Overs Boundary %', fontsize=12)
ax.set_ylabel('Death Overs Strike Rate', fontsize=12)
ax.set_title('Death Over Specialists: Strike Rate vs Boundary %\n(Bubble size = Balls Faced)', 
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/10_death_over_batters.png', dpi=150, bbox_inches='tight')
plt.show()


# -------------------------------------------
# 5.2 Death Over Bowlers — Economy vs Wickets
# -------------------------------------------
df_death_bowl = run_query("""
    SELECT 
        bowler,
        SUM(death_wickets) AS death_wickets,
        SUM(death_balls) AS death_balls,
        ROUND(SUM(death_runs_conceded) * 6.0 / NULLIF(SUM(death_balls), 0), 2) AS death_economy
    FROM bowler_stats
    GROUP BY bowler
    HAVING SUM(death_balls) >= 80
""")

fig, ax = plt.subplots(figsize=(12, 8))
scatter = ax.scatter(df_death_bowl['death_wickets'], df_death_bowl['death_economy'],
                     s=df_death_bowl['death_balls'] / 3, alpha=0.6,
                     c=df_death_bowl['death_economy'], cmap='RdYlGn_r',
                     edgecolors='gray', linewidth=0.5)

# Label best (low economy + high wickets)
best = df_death_bowl.nsmallest(8, 'death_economy')
for _, row in best.iterrows():
    ax.annotate(row['bowler'], (row['death_wickets'], row['death_economy']),
                xytext=(5, 5), textcoords='offset points', fontsize=9, fontweight='bold')

ax.set_xlabel('Death Over Wickets', fontsize=12)
ax.set_ylabel('Death Over Economy', fontsize=12)
ax.set_title('Death Over Bowlers: Economy vs Wickets\n(Bubble size = Balls Bowled)', 
             fontsize=16, fontweight='bold')
ax.invert_yaxis()  # Lower economy at top
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/11_death_over_bowlers.png', dpi=150, bbox_inches='tight')
plt.show()