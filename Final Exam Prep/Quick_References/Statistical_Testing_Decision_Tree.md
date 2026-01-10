# Statistical Testing Decision Tree

**Purpose**: Quick reference to choose the right statistical test
**Use For**: Q4 (Statistical Test) and Q5 (A/B Testing Analysis)

---

## Quick Decision Flowchart

```
START: What type of data are you comparing?
│
├─ PROPORTIONS / PERCENTAGES / RATES / CATEGORIES
│  │  (Examples: success rate, conversion rate, % of users, yes/no outcomes)
│  │
│  ├─ Comparing TWO GROUPS (A vs B)?
│  │  │
│  │  ├─ ✓ Use: CHI-SQUARED TEST or PROPORTION TEST
│  │  │  R Code: chisq.test(contingency_table)
│  │  │  R Code: prop.test(x = c(succA, succB), n = c(totalA, totalB))
│  │  │
│  │  │  Example Question:
│  │  │  "Is there a significant difference in level completion rate
│  │  │   between Group A (28%) and Group B (22%)?"
│  │  │
│  │  └─ Answer: Chi-squared test → p-value → Interpret
│  │
│  └─ Comparing ONE GROUP to expected value?
│     │
│     └─ Use: BINOMIAL TEST
│        R Code: binom.test(successes, total, expected_prob)
│        Example: "Is our 55% success rate significantly different from expected 50%?"
│
│
├─ MEANS / AVERAGES / CONTINUOUS VALUES
│  │  (Examples: session length, revenue, age, time spent, scores)
│  │
│  ├─ Comparing TWO INDEPENDENT GROUPS (A vs B)?
│  │  │
│  │  ├─ ✓ Use: INDEPENDENT t-TEST
│  │  │  R Code: t.test(groupA, groupB)
│  │  │  R Code: t.test(metric ~ group, data = data)
│  │  │
│  │  │  Example Question:
│  │  │  "Is there a significant difference in average session length
│  │  │   between Group A (25 min) and Group B (20 min)?"
│  │  │
│  │  └─ Answer: t-test → p-value → Interpret
│  │
│  ├─ Comparing SAME GROUP before/after (paired data)?
│  │  │
│  │  └─ Use: PAIRED t-TEST
│  │     R Code: t.test(before, after, paired = TRUE)
│  │     Example: "Did session length change after the update for the same users?"
│  │
│  └─ Comparing MORE THAN 2 GROUPS?
│     │
│     └─ Use: ANOVA
│        R Code: aov(metric ~ group, data = data)
│        Example: "Is there a difference in revenue across 5 different regions?"
│
│
└─ DISTRIBUTIONS / SHAPES
   │  (Rare in exam - comparing if two datasets have the same distribution)
   │
   └─ Use: KOLMOGOROV-SMIRNOV TEST
      R Code: ks.test(groupA, groupB)
      Example: "Do Group A and Group B have the same distribution of session lengths?"
```

---

## Most Common for Exam

### **90% of exam questions will use one of these TWO tests:**

#### 1. CHI-SQUARED TEST (for proportions/rates)
- **When**: Comparing success rates, conversion rates, completion rates
- **Example**: "Group A: 28% success vs Group B: 22% success"
- **R Code**:
```r
contingency_table <- matrix(c(succA, failA, succB, failB), nrow=2, byrow=TRUE)
chi_result <- chisq.test(contingency_table)
p_value <- chi_result$p.value
```

#### 2. INDEPENDENT t-TEST (for means/averages)
- **When**: Comparing average session length, average revenue
- **Example**: "Group A: avg 25 min vs Group B: avg 20 min"
- **R Code**:
```r
t_result <- t.test(groupA_values, groupB_values)
p_value <- t_result$p.value
```

---

## Step-by-Step: How to Choose

### STEP 1: Identify your data type

**Ask yourself**: What am I measuring?

| If your metric is... | Data type | Test to use |
|---------------------|-----------|-------------|
| Success rate, % completion | Proportion | Chi-squared |
| Conversion rate, % of users | Proportion | Chi-squared |
| Win/loss, yes/no | Proportion | Chi-squared |
| Average session time | Mean | t-test |
| Average revenue | Mean | t-test |
| Average score, rating | Mean | t-test |

### STEP 2: Check your comparison

**Ask yourself**: What am I comparing?

- **Two groups** (A vs B)? → Chi-squared (proportions) or t-test (means)
- **Same group before/after**? → Paired t-test (means only)
- **More than 2 groups**? → ANOVA (rare in this exam)

### STEP 3: Run the test

See R_Statistical_Analysis_Library.R for copy-paste code

---

## p-Value Interpretation Guide

### The Golden Rule:
```
p < 0.05  → SIGNIFICANT
p ≥ 0.05  → NOT SIGNIFICANT
```

### Detailed Interpretation Table:

| p-value | Interpretation | Meaning | Decision |
|---------|----------------|---------|----------|
| **< 0.001** | Extremely significant | Very strong evidence | **Definitely significant** |
| **< 0.01** | Highly significant | Strong evidence | **Significant** |
| **< 0.05** | Significant | Sufficient evidence | **Significant** ← Standard threshold |
| **0.05 - 0.10** | Marginally significant | Weak evidence | **Borderline** (usually not significant) |
| **≥ 0.10** | Not significant | Insufficient evidence | **Not significant** |

### What p-value means:

**p-value = probability that observed difference is due to random chance**

- **Small p-value** (< 0.05): Unlikely due to chance → **Real difference exists**
- **Large p-value** (≥ 0.05): Could be due to chance → **No strong evidence of difference**

---

## Hypothesis Testing Language

### Null Hypothesis (H₀):
"There is **NO difference** between the groups"

### Alternative Hypothesis (H₁):
"There **IS a difference** between the groups"

### Decision Rules:

```
IF p < 0.05:
    → REJECT null hypothesis (H₀)
    → ACCEPT alternative hypothesis (H₁)
    → Conclusion: "There IS a significant difference"

IF p ≥ 0.05:
    → FAIL TO REJECT null hypothesis (H₀)
    → Conclusion: "There is NO significant difference"
    → OR "Insufficient evidence to conclude a difference"
```

**IMPORTANT**: Never say "accept the null hypothesis" - always say "fail to reject"

---

## Common Exam Scenarios

### Scenario 1: Easier Level Difficulty
**Question**: "Group A (easier level): 28% success, Group B (original): 22% success. Is the difference significant?"

**Solution**:
- Data type: **Proportions** (success rate %)
- Comparison: **Two groups** (A vs B)
- Test: **Chi-squared test**
- Expected result: p < 0.05 → Significant difference

---

### Scenario 2: Session Length Comparison
**Question**: "Group A average session: 25 minutes, Group B: 20 minutes. Is the difference significant?"

**Solution**:
- Data type: **Means** (average minutes)
- Comparison: **Two groups** (A vs B)
- Test: **Independent t-test**
- Expected result: Check p-value

---

### Scenario 3: Revenue per User
**Question**: "Group A ARPU: $5.00, Group B ARPU: $4.50. Is the increase significant?"

**Solution**:
- Data type: **Means** (average revenue)
- Comparison: **Two groups** (A vs B)
- Test: **Independent t-test**
- Expected result: Check p-value

---

## Quick Reference Card

### For Chi-Squared Test:

**Need**:
- Group A: successes, failures
- Group B: successes, failures

**R Code**:
```r
matrix(c(succA, failA, succB, failB), nrow=2, byrow=TRUE)
chisq.test(table)$p.value
```

**Interpret**:
- p < 0.05 → Significant difference in rates
- p ≥ 0.05 → No significant difference in rates

---

### For t-Test:

**Need**:
- Group A: list of values (session lengths, revenues, etc.)
- Group B: list of values

**R Code**:
```r
t.test(groupA, groupB)$p.value
# OR
t.test(metric ~ group, data = data)$p.value
```

**Interpret**:
- p < 0.05 → Significant difference in means
- p ≥ 0.05 → No significant difference in means

---

## Common Mistakes to Avoid

### ❌ WRONG: Using t-test for proportions
```r
# DON'T: Use t-test for success rates
group_a_rate <- 0.28
group_b_rate <- 0.22
t.test(group_a_rate, group_b_rate)  # WRONG!
```

### ✓ CORRECT: Use chi-squared for proportions
```r
# DO: Use chi-squared for success rates
matrix(c(280, 720, 220, 780), nrow=2, byrow=TRUE)
chisq.test(table)
```

---

### ❌ WRONG: Using chi-squared for means
```r
# DON'T: Use chi-squared for session length
chisq.test(session_lengths)  # WRONG!
```

### ✓ CORRECT: Use t-test for means
```r
# DO: Use t-test for session length
t.test(groupA_sessions, groupB_sessions)
```

---

### ❌ WRONG: Misinterpreting p-value
"p = 0.03 means there's a 3% chance Group A is better" ← **WRONG**

### ✓ CORRECT: Proper interpretation
"p = 0.03 means there's a 3% chance the observed difference is due to random chance, so we reject the null hypothesis and conclude there IS a significant difference" ← **CORRECT**

---

## Exam Checklist

When you see a statistical test question:

- [ ] **Step 1**: Identify data type (proportion or mean?)
- [ ] **Step 2**: Choose test (chi-squared or t-test?)
- [ ] **Step 3**: Run test in R (see R_Statistical_Analysis_Library.R)
- [ ] **Step 4**: Extract p-value
- [ ] **Step 5**: Compare to 0.05
- [ ] **Step 6**: State conclusion (significant or not)
- [ ] **Step 7**: Interpret in context (what does this mean for the business?)

---

## Example Exam Answer Format

**Question**: "Is there a significant difference in completion rates between Group A (28%) and Group B (22%)?"

**Answer**:

"I used a **chi-squared test** to compare the completion rates between the two groups, as we are comparing proportions (success rates).

**Data**:
- Group A: 280 successes out of 1000 attempts (28%)
- Group B: 220 successes out of 1000 attempts (22%)

**Test Results**:
- Chi-squared statistic: χ² = 10.23
- p-value = 0.0014

**Interpretation**:
Since p = 0.0014 < 0.05, I **reject the null hypothesis**. There **IS a statistically significant difference** in completion rates between the two groups.

**Conclusion**:
Group A's completion rate is significantly higher than Group B's, with a difference of 6 percentage points. This difference is unlikely to be due to random chance (p < 0.05)."

---

## Final Tips

1. **When in doubt, check the units**:
   - Percentage, rate, proportion → Chi-squared
   - Minutes, dollars, count → t-test

2. **Always state the p-value**: Don't just say "significant" - give the actual p-value

3. **Use correct language**: "Reject null hypothesis" not "accept alternative hypothesis"

4. **Connect to business**: Don't just report statistics - explain what they mean

5. **Double-check your test choice**: Wrong test = wrong answer, even if calculations are correct

---

**Good luck! Refer to R_Statistical_Analysis_Library.R for the actual code to run these tests.**
