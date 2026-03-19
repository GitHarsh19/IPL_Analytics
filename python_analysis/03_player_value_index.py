import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from db_connection import load_table

plt.style.use('seaborn-v0_8-whitegrid')

# -------------------------------------------
# 3.1 Top 15 Batters by Value Index (Horizontal Bar)
# -------------------------------------------
batter_idx = load_table("batter_value_index")
top15 = batter_idx.nlargest(15, 'player_value_index')

fig, ax = plt.subplots(figsize=(12, 8))
colors = plt.cm.RdYlGn(np.linspace(0.3, 0.9, len(top15)))[::-1]
bars = ax.barh(top15['batter'], top15['player_value_index'], color=colors, height=0.6)

for i, (val, runs) in enumerate(zip(top15['player_value_index'], top15['career_runs'])):
    ax.text(val + 0.5, i, f'{val:.1f}  ({int(runs)} runs)', va='center', fontsize=9)

ax.set_xlabel('Player Value Index', fontsize=12)
ax.set_title('Top 15 IPL Batters by Player Value Index', fontsize=16, fontweight='bold')
ax.invert_yaxis()
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/05_batter_value_index.png', dpi=150, bbox_inches='tight')
plt.show()


# -------------------------------------------
# 3.2 Impact vs Consistency Scatter Plot (Batters)
# -------------------------------------------
# Filter for meaningful sample
df = batter_idx[batter_idx['career_runs'] >= 500].copy()

fig, ax = plt.subplots(figsize=(12, 8))

# Size = career runs, Color = player value index
scatter = ax.scatter(
    df['consistency_cv'], 
    df['career_sr'], 
    s=df['career_runs'] / 10,      # Bubble size = career runs
    c=df['player_value_index'],     # Color = value index
    cmap='RdYlGn',
    alpha=0.7,
    edgecolors='gray',
    linewidth=0.5
)

# Label top players
top_players = df.nlargest(10, 'player_value_index')
for _, row in top_players.iterrows():
    ax.annotate(row['batter'], 
                (row['consistency_cv'], row['career_sr']),
                xytext=(5, 5), textcoords='offset points', fontsize=8,
                fontweight='bold')

plt.colorbar(scatter, label='Player Value Index')
ax.set_xlabel('Consistency (CV) — Lower is Better →', fontsize=12)
ax.set_ylabel('Career Strike Rate', fontsize=12)
ax.set_title('IPL Batters: Strike Rate vs Consistency\n(Bubble size = Career Runs)', fontsize=16, fontweight='bold')

# Add quadrant labels
ax.axhline(y=df['career_sr'].median(), color='gray', linestyle='--', alpha=0.3)
ax.axvline(x=df['consistency_cv'].median(), color='gray', linestyle='--', alpha=0.3)

plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/06_impact_vs_consistency.png', dpi=150, bbox_inches='tight')
plt.show()


# -------------------------------------------
# 3.3 Top 15 Bowlers by Value Index
# -------------------------------------------
bowler_idx = load_table("bowler_value_index")
top15_bowl = bowler_idx.nlargest(15, 'bowler_value_index')

fig, ax = plt.subplots(figsize=(12, 8))
colors = plt.cm.RdYlGn(np.linspace(0.3, 0.9, len(top15_bowl)))[::-1]
bars = ax.barh(top15_bowl['bowler'], top15_bowl['bowler_value_index'], color=colors, height=0.6)

for i, (val, wkts) in enumerate(zip(top15_bowl['bowler_value_index'], top15_bowl['career_wickets'])):
    ax.text(val + 0.5, i, f'{val:.1f}  ({int(wkts)} wkts)', va='center', fontsize=9)

ax.set_xlabel('Bowler Value Index', fontsize=12)
ax.set_title('Top 15 IPL Bowlers by Bowler Value Index', fontsize=16, fontweight='bold')
ax.invert_yaxis()
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/07_bowler_value_index.png', dpi=150, bbox_inches='tight')
plt.show()