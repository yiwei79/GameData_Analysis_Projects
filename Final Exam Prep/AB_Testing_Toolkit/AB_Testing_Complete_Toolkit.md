# A/B Testing Complete Toolkit

**Purpose**: Complete framework for analyzing A/B tests and making business decisions
**Use For**: Question 5 (worth 4 points - 44% of exam grade)
**Time Allocation**: 40-45 minutes

---

## A/B Testing Analysis Workflow (6 Steps)

### STEP 1: Understand the Problem (2 minutes)

**Checklist**:
- [ ] What is being tested? (feature change, difficulty adjustment, UI change, etc.)
- [ ] What are the groups? (Control = B, Treatment = A, or vice versa)
- [ ] What is the primary metric? (success rate, session length, revenue, etc.)
- [ ] What is the hypothesis? (A will be better/worse than B)
- [ ] What is the business goal? (increase retention, increase revenue, improve UX)

**Example from exam**:
- Testing: Level 20 difficulty (Group A = easier, Group B = original harder)
- Primary metric: Level completion success rate
- Hypothesis: Easier level will increase success rate
- Business goal: Improve player retention and reduce frustration

---

### STEP 2: Load and Explore Data (5 minutes)

**Load data**:
```r
# If CSV file provided
data <- read.csv("sweet.sql", header = TRUE)

# If MySQL database
library(RMySQL)
con <- dbConnect(MySQL(),
                 user = "your_username",
                 password = "your_password",
                 dbname = "your_database",
                 host = "localhost")
data <- dbGetQuery(con, "SELECT * FROM your_table")
dbDisconnect(con)
```

**Quick exploration**:
```r
# View first few rows
head(data)

# Check structure and data types
str(data)

# Check group sizes
table(data$group)

# Summary statistics
summary(data)

# Check for missing values
sum(is.na(data))
```

**What to look for**:
- Are group sizes balanced? (should be roughly equal)
- Are there any missing values?
- Do the column names match what the question asks for?
- Is the data format correct (dates, numbers, categories)?

---

### STEP 3: Calculate Group Metrics (10 minutes)

#### For PROPORTIONS (success rate, completion rate, conversion rate):

```r
library(dplyr)

# Calculate success/failure counts by group
group_summary <- data %>%
    group_by(group) %>%
    summarize(
        total_attempts = n(),
        successes = sum(success == 1),  # Adjust column name as needed
        failures = sum(success == 0),
        success_rate = mean(success) * 100
    )

print(group_summary)
```

**Example output**:
```
  group total_attempts successes failures success_rate
1 A              1000       280      720         28.0
2 B              1000       220      780         22.0
```

#### For MEANS (session length, revenue, time spent):

```r
group_means <- data %>%
    group_by(group) %>%
    summarize(
        count = n(),
        mean_value = mean(metric, na.rm = TRUE),  # Replace 'metric' with actual column
        sd_value = sd(metric, na.rm = TRUE)
    )

print(group_means)
```

**Write down these numbers** - you'll need them for your answer!

---

### STEP 4: Run Statistical Test (10 minutes)

#### Decision: Which test to use?

**Use the Statistical_Testing_Decision_Tree.md to decide:**

- **Comparing proportions** (%, rates, success/failure)? → **Chi-squared test**
- **Comparing means** (averages, continuous values)? → **t-test**

#### OPTION A: Chi-Squared Test (most common for A/B tests)

```r
# Extract group data
group_a <- group_summary %>% filter(group == "A")
group_b <- group_summary %>% filter(group == "B")

# Create contingency table
#           Success  Failure
# Group A      X        Y
# Group B      Z        W
contingency_table <- matrix(
    c(group_a$successes, group_a$failures,
      group_b$successes, group_b$failures),
    nrow = 2,
    byrow = TRUE
)
rownames(contingency_table) <- c("Group_A", "Group_B")
colnames(contingency_table) <- c("Success", "Failure")

# ALWAYS print table to verify
print(contingency_table)

# Run chi-squared test
chi_result <- chisq.test(contingency_table)
print(chi_result)

# Extract p-value
p_value <- chi_result$p.value
cat("p-value:", p_value, "\n")
```

#### OPTION B: t-test (if comparing means)

```r
# Run t-test
t_result <- t.test(metric ~ group, data = data)
print(t_result)

# Extract p-value
p_value <- t_result$p.value
cat("p-value:", p_value, "\n")
```

**Write down the p-value!**

---

### STEP 5: Interpret Results (5 minutes)

#### Statistical Significance:

```r
if (p_value < 0.05) {
    cat("SIGNIFICANT: p-value =", round(p_value, 4), "\n")
    cat("Reject null hypothesis: There IS a significant difference\n")
} else {
    cat("NOT SIGNIFICANT: p-value =", round(p_value, 4), ")\n")
    cat("Fail to reject null hypothesis: No significant difference\n")
}
```

#### Effect Size (Practical Significance):

```r
# For proportions
difference <- group_a$success_rate - group_b$success_rate
cat("Effect size:", round(difference, 2), "percentage points\n")

# For means
difference <- mean_a - mean_b
cat("Effect size:", round(difference, 2), "units\n")
```

#### Business Impact Calculation:

```r
# Example: If 1 million players play this level annually
total_players <- 1000000
additional_successes <- total_players * (difference / 100)
cat("Potential impact:", round(additional_successes), "additional successes per year\n")
```

---

### STEP 6: Make Business Recommendation (8 minutes)

#### Decision Framework:

```
IF p-value < 0.05 AND effect is positive (desirable):
    → RECOMMEND: Implement the change for all users
    → REASON: Statistically significant improvement

IF p-value < 0.05 AND effect is negative (undesirable):
    → RECOMMEND: DO NOT implement, revert to control
    → REASON: Change makes things significantly worse

IF p-value ≥ 0.05:
    → RECOMMEND: Need more data OR no clear winner
    → REASON: Difference not statistically significant (could be random)
```

#### Answer Template for Q5:

```markdown
**Recommendation**: [Implement Change / Do Not Implement / Need More Data]

**Statistical Evidence**:
- Group A [metric]: X% (n = N)
- Group B [metric]: Y% (n = N)
- Absolute difference: Z percentage points
- Relative improvement: [(X-Y)/Y * 100]%
- Chi-squared test: χ² = [value], p-value = [value]
- Result: [Statistically significant / Not significant] at α = 0.05 level

**Business Reasoning**:
- The [easier/harder] [feature description] in Group A resulted in a [higher/lower] [metric name]
- This represents a [X%] [improvement/decline] compared to Group B (the control group)
- Estimated business impact: [describe quantitative impact if possible]
- Player experience implication: [how this affects players]
- Alignment with business goals: [retention/revenue/engagement]

**Recommendation Justification**:
Because the difference is [statistically significant/not significant] (p = [value]) and
represents a [meaningful/negligible] [improvement/decline] of [X percentage points],
I recommend [implementing/not implementing/running longer test]. This decision balances
statistical evidence with business objectives of [specific goal] while considering
[player experience/revenue impact/retention].

**Additional Considerations**:
- [Any caveats: sample size, test duration, external factors]
- [Secondary metrics to monitor: session length, engagement, churn]
- [Potential risks or trade-offs: difficulty perception, long-term effects]
- [Next steps: gradual rollout, monitoring plan]
```

---

## Common A/B Test Scenarios & Decisions

| Scenario | Group A | Group B | p-value | Difference | Decision | Reasoning |
|----------|---------|---------|---------|------------|----------|-----------|
| Easier level difficulty | 28% success | 22% success | 0.001 | +6 pts | **Implement** | Significant improvement, better UX |
| Harder level difficulty | 18% success | 22% success | 0.01 | -4 pts | **Don't implement** | Significant decline, worse UX |
| Price increase | $5 ARPU | $4 ARPU | 0.03 | +$1 | **Implement** | Significant revenue increase (25%) |
| Minor UI change | 25% click | 25.1% click | 0.8 | +0.1 pts | **No clear winner** | Not significant, too small |
| New feature | 30% engagement | 28% engagement | 0.06 | +2 pts | **Need more data** | Marginally significant, borderline |

---

## Red Flags to Watch For

### Sample Size Issues:
- **Too small** (< 100 per group): Results unreliable, need more data
- **Unbalanced** groups: May indicate selection bias or technical issue

### Effect Size Issues:
- **Statistically significant BUT tiny effect** (e.g., 0.1% difference): May not be practically meaningful
- **Large effect BUT not significant**: Likely due to small sample size

### Test Integrity Issues:
- **Multiple comparisons**: Testing 10 metrics increases false positive rate (should correct alpha)
- **Peeking early**: Checking results multiple times inflates error rate
- **Stopping early**: Don't stop test just because it reached significance

### Data Quality Issues:
- **Missing data**: Check if missing values are random or systematic
- **Outliers**: Extreme values can skew means (less issue for proportions)
- **Time effects**: Ensure both groups tested during same time period

---

## Quick Decision Checklist

**Before writing your answer, verify**:
- [ ] Calculated metrics correctly for both groups
- [ ] Ran appropriate statistical test
- [ ] p-value is clearly stated and interpreted
- [ ] Effect size (difference) is calculated
- [ ] Business impact is described
- [ ] Recommendation is clear (implement/don't implement/need more data)
- [ ] Reasoning connects statistics to business goals
- [ ] Mentioned considerations or caveats

---

## Example Walkthrough: Easier Level Difficulty

**Scenario**: Game developer tested easier version of Level 20 (Group A) vs original (Group B)

**Data Summary**:
- Group A: 280 successes / 1000 attempts = 28% success rate
- Group B: 220 successes / 1000 attempts = 22% success rate

**Statistical Test**:
```
Chi-squared test: χ² = 10.23, p-value = 0.0014
Result: SIGNIFICANT (p < 0.05)
```

**Effect Size**:
- Absolute difference: 28% - 22% = 6 percentage points
- Relative improvement: (6/22) * 100 = 27.3% improvement

**Business Impact**:
- If 500,000 players attempt Level 20 annually
- Additional successes: 500,000 * 0.06 = 30,000 more players completing level
- Better retention, less frustration, higher progression

**Recommendation**:
**IMPLEMENT the easier Level 20 version**

**Justification**:
The easier difficulty resulted in a statistically significant (p = 0.0014) and
practically meaningful improvement of 6 percentage points (27.3% relative increase).
This aligns with business goals of improving player retention and reducing churn at
this critical level. The change will lead to an estimated 30,000 additional completions
annually, improving player experience without compromising game challenge progression.

**Considerations**:
- Monitor long-term retention to ensure easier level doesn't reduce challenge satisfaction
- Track completion rates of subsequent levels (Level 21-25) to verify no negative impact
- Consider gradual rollout (50% of users first) before full deployment

---

## Time Management for Q5

**Total time**: 40-45 minutes

**Breakdown**:
- Step 1 (Understand): 2 min
- Step 2 (Load & explore): 5 min
- Step 3 (Calculate metrics): 10 min
- Step 4 (Statistical test): 10 min
- Step 5 (Interpret): 5 min
- Step 6 (Write recommendation): 8-10 min
- Review answer: 2-3 min

**If running short on time**:
- Skip detailed exploration (Step 2) - just load and check group sizes
- Use contingency table from group summary directly (don't recalculate)
- Keep recommendation concise but complete

**Don't skip**:
- Statistical test (core requirement)
- Clear p-value statement
- Explicit recommendation
- Basic justification

---

## Key Formulas to Remember

### Success Rate (Proportion):
```
Success Rate = (Number of Successes / Total Attempts) * 100
```

### Effect Size (Absolute Difference):
```
Effect Size = Group A Metric - Group B Metric
```

### Relative Improvement:
```
Relative Improvement = ((Group A - Group B) / Group B) * 100
```

### Chi-Squared Test (in R):
```r
chisq.test(contingency_table)
```

### Interpreting p-value:
```
p < 0.05  → Reject null hypothesis (significant difference)
p ≥ 0.05  → Fail to reject null hypothesis (no significant difference)
```

---

## Final Tips for Q5

1. **Read the question carefully**: Identify what is being compared and what the business goal is

2. **Show your work**: Write out key numbers (success rates, p-value, effect size)

3. **Use proper statistical language**:
   - "statistically significant" (not just "significant")
   - "reject/fail to reject null hypothesis" (not "accept")
   - State significance level (α = 0.05)

4. **Connect to business**: Don't just report statistics - explain what they mean for the business

5. **Be decisive**: Make a clear recommendation (implement/don't implement/need more data)

6. **Consider trade-offs**: Mention any caveats or risks

7. **Check your logic**: Does your recommendation match your statistical results?

**Good luck on Q5 - this is the big one!**
