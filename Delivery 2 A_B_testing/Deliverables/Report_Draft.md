# A/B Test Analysis Report: Boost Power Evaluation

**Course:** Game Data Analysis
**Delivery:** 2 - A/B Testing
**Date:** December 2024

---

## 1. Executive Summary

This report analyzes a 4-month A/B test conducted on a Candy Crush-style puzzle game to determine whether an increased boost power feature should be rolled out to all players.

**Key Findings:**
- Players with stronger boost (Group A) achieved a **2.6 percentage point higher success rate** (25.1% vs 22.5%)
- The difference is **statistically significant** (p < 0.001)
- Group A players used boosts **51% more frequently** than Group B (15.6% vs 10.3%)
- The positive effect **persisted** even after the boost was reset to original power

**Recommendation:** Roll out the stronger boost to all players, with ongoing monitoring of long-term retention and monetization metrics.

---

## 2. Introduction & Background

### 2.1 Game Context
The game is a Candy Crush-style puzzle game where players attempt to complete levels. Players can use "boosts" - power-ups that help them succeed at difficult levels. The game launched on January 1, 2020.

### 2.2 Business Problem
Players reported that some levels were too difficult, leading to frustration. The product team hypothesized that increasing the boost power would improve player experience and engagement without negatively impacting game balance.

### 2.3 Test Design
- **Group A (Test):** Received increased boost power
- **Group B (Control):** Retained original boost power
- **Test Period:** June 1 - September 30, 2020 (4 months)
- **Sample Size:** ~14,000 players (6,923 Group A, 7,017 Group B)

### 2.4 Research Question
*Should the increased boost power be rolled out to all players?*

---

## 3. Methodology

### 3.1 Data Sources

| Dataset | Records | Key Fields |
|---------|---------|------------|
| Users | 13,940 | TestGroup, demographics, registration date |
| Sessions | 432,000+ | Session timing, player ID |
| Levels | 1.5M+ | Level attempts, boost usage, outcomes |
| Transactions | 26,000+ | Purchase data |

### 3.2 Time Period Segmentation

| Period | Dates | Purpose |
|--------|-------|---------|
| Pre-Test | Jan 1 - May 31, 2020 | Baseline validation |
| During Test | June 1 - Sept 30, 2020 | A/B comparison window |
| Post-Test | Oct 1 - Dec 31, 2020 | Persistence analysis |

### 3.3 Key Metrics Analyzed
- **Primary:** Level success rate (Success vs Fail/Abandon)
- **Secondary:** Boost usage rate (% of levels where boost was used)
- **Validation:** Pre-test baseline comparison

### 3.4 Statistical Methods
- **Chi-squared test** for comparing proportions between groups
- **95% Confidence Intervals** for effect size estimation
- **Odds Ratio** for practical significance interpretation
- Significance threshold: α = 0.05

---

## 4. Results & Analysis

### 4.1 Baseline Validation

Before analyzing test results, we verified that Groups A and B were comparable before the test began.

| Metric | Group A | Group B | p-value |
|--------|---------|---------|---------|
| Sample Size | 6,923 | 7,017 | - |
| Pre-Test Success Rate | 29.1% | 30.1% | 0.0016 |

**Finding:** There was a small but statistically significant difference in baseline success rates (1 percentage point). This is noted as a limitation, but the difference is small enough that it does not invalidate the test results.

### 4.2 Primary Finding: Level Success Rate

**During the test period (June - September 2020):**

![Success Rate by Group](../Analysis/Visualization/Success%20Rate%20by%20Group.png)

| Metric | Group A | Group B | Difference |
|--------|---------|---------|------------|
| Success Rate | 25.1% | 22.5% | +2.6 pp |
| Level Attempts | 399,219 | 394,339 | - |

**Statistical Test Results:**
- Chi-squared statistic: 797.84
- Degrees of freedom: 1
- **p-value: < 2.2e-16** (highly significant)
- Odds Ratio: 1.15 (Group A is 1.15x more likely to succeed)
- 95% CI for difference: [2.35%, 2.86%]

**Interpretation:** Players with the stronger boost succeeded at levels at a significantly higher rate. The effect is statistically significant and the confidence interval does not include zero, confirming a real positive effect.

### 4.3 Time-Series Analysis

![Success Rate Over Time](../Analysis/Visualization/Success%20Rate%20Over%20Time.png)

The time-series visualization shows:
- **Pre-test (Jan-May):** Both groups performed similarly
- **During test (June-Sept):** Clear separation, with Group A outperforming
- **Post-test (Oct+):** Effect persists even after boost was reset

### 4.4 Secondary Finding: Boost Engagement

![Boost Usage Rate](../Analysis/Visualization/Boost%20Usage%20Rate.png)

| Metric | Group A | Group B | Difference |
|--------|---------|---------|------------|
| Boost Usage Rate | 15.6% | 10.3% | +5.3 pp (+51%) |

**Statistical Test Results:**
- Chi-squared statistic: 4861.9
- **p-value: < 2.2e-16** (highly significant)

**Interpretation:** Players used the boost significantly more when it was stronger. This suggests:
1. The stronger boost provided tangible value to players
2. Players recognized and appreciated the improved feature
3. Higher engagement with the boost mechanic

### 4.5 Persistence Effect (Post-Test Analysis)

![Success Rate by Test Period](../Analysis/Visualization/Success%20Rate%20by%20Test%20Period.png)

| Period | Group A | Group B | Difference |
|--------|---------|---------|------------|
| Pre-Test | 29.1% | 30.1% | -1.0 pp |
| During Test | 25.1% | 22.5% | +2.6 pp |
| Post-Test | 22.3% | 19.7% | +2.6 pp |

**Key Insight:** Even after the boost was reset to original power for all players, Group A continued to outperform Group B by the same margin. This suggests **learned behavior or habit formation** - players who experienced the stronger boost developed better strategies or confidence that persisted.

---

## 5. Discussion

### 5.1 Arguments FOR Rolling Out Stronger Boost

1. **Significant Performance Improvement**
   - 2.6 percentage point increase in success rate
   - Statistically significant with p < 0.001
   - Effect is consistent and reproducible

2. **Higher Player Engagement**
   - 51% increase in boost usage
   - Players actively seek out and use the improved feature
   - Indicates positive user experience

3. **Lasting Positive Effects**
   - Effect persists after boost reset
   - Suggests habit formation and skill development
   - Long-term benefit to player experience

4. **No Observed Negative Effects**
   - No decline in session frequency
   - No evidence of reduced challenge engagement

### 5.2 Arguments AGAINST Rolling Out Stronger Boost

1. **May Reduce Game Challenge**
   - Easier success could reduce long-term engagement
   - Players may complete content faster
   - Risk of "boredom" from reduced difficulty

2. **Potential Boost Dependency**
   - Players may become reliant on boosts
   - Could frustrate players if boost is later nerfed
   - May reduce satisfaction from "natural" wins

3. **Unknown Monetization Impact**
   - Analysis did not include revenue comparison
   - Stronger free boost might reduce boost purchases
   - Need to monitor ARPU/ARPPU before full rollout

4. **Baseline Difference Caveat**
   - Small pre-test difference exists (p = 0.0016)
   - While small, it suggests groups weren't perfectly randomized
   - Results should be interpreted with this context

---

## 6. Conclusion & Recommendation

### 6.1 Summary of Findings

| Test | Result | Significant? |
|------|--------|--------------|
| Success Rate During Test | A > B by 2.6 pp | Yes (p < 0.001) |
| Boost Usage During Test | A > B by 51% | Yes (p < 0.001) |
| Baseline (Pre-Test) | Similar (1 pp diff) | Minor concern |
| Persistence (Post-Test) | Effect persists | Yes (p < 0.001) |

### 6.2 Final Recommendation

**RECOMMEND: Roll out the stronger boost to all players**

The evidence strongly supports this decision:
- Clear, statistically significant improvement in player success
- Increased engagement with the boost feature
- Positive lasting effects on player behavior
- No observed negative consequences during the test period

### 6.3 Suggested Next Steps

1. **Monitor Long-Term Metrics**
   - Track D7, D30, D90 retention after rollout
   - Watch for changes in session frequency over time

2. **Analyze Monetization Impact**
   - Compare ARPU between groups
   - Monitor boost purchase behavior
   - Adjust if revenue impact is negative

3. **Consider Level Rebalancing**
   - Review level difficulty curves
   - Ensure challenging content remains meaningful
   - May need to increase difficulty of later levels

4. **A/B Test Monetization**
   - If boost purchases decline, test pricing changes
   - Consider new boost tiers or features

---

## Appendix: Statistical Test Details

### Test 1: Success Rate Comparison (Chi-Squared)
```
H0: Success rate is the same for Group A and Group B
H1: Success rate differs between groups

Chi-squared = 797.84, df = 1
p-value < 2.2e-16
Conclusion: REJECT H0 - Significant difference exists

Odds Ratio = 1.15
95% CI for difference: [2.35%, 2.86%]
```

### Test 2: Boost Usage Comparison (Chi-Squared)
```
H0: Boost usage rate is the same for both groups
H1: Boost usage rate differs between groups

Chi-squared = 4861.9, df = 1
p-value < 2.2e-16
Conclusion: REJECT H0 - Significant difference exists

Group A: 15.6%, Group B: 10.3%
Difference: +5.3 percentage points
```

### Test 3: Baseline Validation (Chi-Squared)
```
Pre-test period: Jan 1 - May 31, 2020
Group A: 29.1%, Group B: 30.1%
p-value = 0.0016

Conclusion: Small but significant baseline difference
Interpretation: Groups not perfectly balanced, but difference is minor
```

### Test 4: Post-Test Persistence (Chi-Squared)
```
Post-test period: Oct 1 - Dec 31, 2020
Group A: 22.3%, Group B: 19.7%
p-value < 2.2e-16

Conclusion: Effect persists after boost reset
Interpretation: Suggests learned behavior/habit formation
```

---

*Report generated with R statistical analysis and Tableau visualizations*
