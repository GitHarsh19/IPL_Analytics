import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from db_connection import run_query

plt.style.use('seaborn-v0_8-whitegrid')

# -------------------------------------------
# 6.1 What Factors Correlate with Winning?
# -------------------------------------------
df = run_query("""
    SELECT 
        ms.match_id,
        ms.first_innings_score,
        ms.toss_winner_won,
        ms.toss_decision,
        CASE WHEN ms.winner = ms.batting_first_team THEN 1 ELSE 0 END AS bat_first_won,
        
        -- Powerplay score for batting first team
        pp.pp_runs AS first_innings_pp_runs,
        pp.pp_wickets AS first_innings_pp_wickets,
        
        -- Death overs score
        death.death_runs AS first_innings_death_runs
        
    FROM match_summary ms
    LEFT JOIN (
        SELECT match_id, SUM(total_runs) AS pp_runs, SUM(is_wicket) AS pp_wickets
        FROM deliveries WHERE inning = 1 AND phase = 'Powerplay'
        GROUP BY match_id
    ) pp ON ms.match_id = pp.match_id
    LEFT JOIN (
        SELECT match_id, SUM(total_runs) AS death_runs
        FROM deliveries WHERE inning = 1 AND phase = 'Death'
        GROUP BY match_id
    ) death ON ms.match_id = death.match_id
    WHERE ms.first_innings_score IS NOT NULL
""")

# Encode toss_decision
df['chose_field'] = (df['toss_decision'] == 'field').astype(int)

# Select numeric columns for correlation
corr_cols = ['first_innings_score', 'bat_first_won', 'toss_winner_won', 
             'chose_field', 'first_innings_pp_runs', 'first_innings_pp_wickets',
             'first_innings_death_runs']

corr_matrix = df[corr_cols].corr()

# Rename for readability
rename_map = {
    'first_innings_score': '1st Inn Score',
    'bat_first_won': 'Bat 1st Won',
    'toss_winner_won': 'Toss Winner Won',
    'chose_field': 'Chose Field',
    'first_innings_pp_runs': 'PP Runs (1st)',
    'first_innings_pp_wickets': 'PP Wickets (1st)',
    'first_innings_death_runs': 'Death Runs (1st)'
}
corr_matrix = corr_matrix.rename(index=rename_map, columns=rename_map)

fig, ax = plt.subplots(figsize=(10, 8))
mask = np.triu(np.ones_like(corr_matrix, dtype=bool))
sns.heatmap(corr_matrix, mask=mask, annot=True, fmt='.2f', cmap='RdBu_r',
            center=0, linewidths=0.5, ax=ax, vmin=-1, vmax=1,
            square=True)
ax.set_title('Match Outcome Correlation Matrix', fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/12_correlation_matrix.png', dpi=150, bbox_inches='tight')
plt.show()


# -------------------------------------------
# 6.2 Score Distribution — 1st vs 2nd Innings
# -------------------------------------------
df_scores = run_query("""
    SELECT first_innings_score, second_innings_score
    FROM match_summary
    WHERE first_innings_score IS NOT NULL AND second_innings_score IS NOT NULL
""")

fig, ax = plt.subplots(figsize=(12, 6))
ax.hist(df_scores['first_innings_score'], bins=30, alpha=0.6, label='1st Innings', color='#2196F3', edgecolor='white')
ax.hist(df_scores['second_innings_score'], bins=30, alpha=0.6, label='2nd Innings', color='#FF5722', edgecolor='white')
ax.axvline(df_scores['first_innings_score'].mean(), color='#2196F3', linestyle='--', linewidth=2)
ax.axvline(df_scores['second_innings_score'].mean(), color='#FF5722', linestyle='--', linewidth=2)
ax.set_xlabel('Score', fontsize=12)
ax.set_ylabel('Frequency', fontsize=12)
ax.set_title('IPL Score Distribution: 1st vs 2nd Innings', fontsize=16, fontweight='bold')
ax.legend(fontsize=12)
plt.tight_layout()
plt.savefig('/Users/harshitagarwal/Desktop/DAP/IPL_Analytics/outputs/13_score_distribution.png', dpi=150, bbox_inches='tight')
plt.show()