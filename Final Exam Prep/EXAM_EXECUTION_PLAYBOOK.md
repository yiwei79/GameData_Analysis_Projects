# Exam Execution Playbook

**Purpose**: Step-by-step guide to execute each question during the exam
**Use**: Keep this document open during the exam, refer to relevant section for each question

---

## Quick Navigation

- [Question 1: KPI Definitions (1pt, 5-10 min)](#question-1-kpi-definitions)
- [Question 2: SQL Query (1pt, 5-10 min)](#question-2-sql-query)
- [Question 3: Data Analysis Design (2pts, 15-20 min)](#question-3-data-analysis-design)
- [Question 4: Statistical Test (1pt, 10-15 min)](#question-4-statistical-test)
- [Question 5: A/B Testing Case Study (4pts, 40-45 min)](#question-5-ab-testing-case-study)

---

## Question 1: KPI Definitions

**Points**: 1 point
**Time**: 5-10 minutes
**Difficulty**: Easy

### Strategy

**Goal**: Define KPIs clearly and concisely - this is a "free point" if you know the definitions

### Execution Steps

1. **Read the question carefully**: Note which specific KPIs are being asked
   - Common KPIs: DAU, MAU, ARPU, ARPPU, Retention (D1/D3/D7), Conversion Rate

2. **Open KPI_Quick_Reference.md**: Find the requested KPIs in the table

3. **Write your answer**: For each KPI, include:
   - **Name** (spelled out + abbreviation)
   - **Short definition** (1-2 sentences)
   - **Formula** (how it's calculated)
   - **Optional**: Brief example

### Answer Template

```
**[KPI Name] ([Abbreviation])**:
[Definition in 1-2 sentences]

Formula: [How it's calculated]

Example: [Optional - concrete example with numbers]
```

### Example Answer

**Question**: "Define DAU and ARPU"

**Answer**:

**DAU (Daily Active Users)**:
The number of unique users who engage with the game on a given day. This metric measures daily engagement and is calculated by counting distinct user IDs per day.

Formula: COUNT(DISTINCT user_id) per day

Example: If 1,250 unique players logged in on January 15th, DAU = 1,250 for that day.

**ARPU (Average Revenue Per User)**:
The average revenue generated per user, including both paying and non-paying users. It's calculated by dividing total revenue by the total number of users.

Formula: Total Revenue / Total Users

Example: If total revenue is $10,000 from 1,000 users, ARPU = $10.00 per user.

### Common Mistakes to Avoid

- ❌ Confusing ARPU (all users) with ARPPU (paying users only)
- ❌ Forgetting to spell out abbreviations
- ❌ Being too verbose - keep it concise
- ❌ Not including the formula

### Time Check

- 5 min: Write 2-3 KPI definitions
- 10 min: Write 4-5 KPI definitions

---

## Question 2: SQL Query

**Points**: 1 point
**Time**: 5-10 minutes
**Difficulty**: Easy-Medium

### Strategy

**Goal**: Execute the SQL query correctly or interpret what a given query does

### Execution Steps

#### If you need to WRITE a query:

1. **Read requirements carefully**: What data is being requested?
   - User count by country?
   - Average session duration?
   - Revenue per item?

2. **Open SQL_Query_Templates.sql**: Find the matching template

3. **Adapt the template**:
   - Change table names
   - Change column names
   - Adjust filters (WHERE conditions)

4. **Test your query** (if database access available):
   ```sql
   -- Test with LIMIT first
   SELECT * FROM table LIMIT 10;
   ```

5. **Write clear SQL**:
   - Use proper formatting (line breaks, indentation)
   - Add comments if complex
   - Use meaningful aliases

#### If you need to INTERPRET a query:

1. **Read the query line by line**:
   - What tables are involved?
   - What is the JOIN type (INNER, LEFT, RIGHT)?
   - What's in the WHERE clause?
   - What aggregations are used?

2. **Common exam question**: "How many rows will this query return?"
   - **INNER JOIN**: Only matching rows
   - **LEFT JOIN**: All rows from left table
   - **COUNT(DISTINCT)** vs **COUNT(*)**: Unique vs all

3. **Write your answer clearly**: Explain what the query does step-by-step

### Example: Writing a Query

**Question**: "Write a query to find the average session duration per country"

**Answer**:

```sql
-- Average session duration per country
SELECT
    u.country,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time)), 2) AS avg_duration_minutes
FROM users u
JOIN sessions s ON u.user_id = s.user_id
WHERE s.end_time IS NOT NULL
GROUP BY u.country
ORDER BY avg_duration_minutes DESC;
```

**Explanation**: This query joins users and sessions tables, calculates the duration in minutes for each session, and averages them by country.

### Example: Interpreting a Query

**Question**: "How many rows will the following LEFT JOIN query return if there are 100 users and 80 of them have sessions?"

```sql
SELECT u.user_id, COUNT(s.session_id) AS session_count
FROM users u
LEFT JOIN sessions s ON u.user_id = s.user_id
GROUP BY u.user_id;
```

**Answer**:

This query will return **100 rows** (one per user) because:
1. LEFT JOIN keeps ALL users from the left table (users)
2. Users with sessions will have session_count > 0
3. Users without sessions (20 users) will have session_count = 0
4. GROUP BY user_id creates one row per user

---

## Question 3: Data Analysis Design

**Points**: 2 points
**Time**: 15-20 minutes
**Difficulty**: Medium (open-ended)

### Strategy

**Goal**: Show you understand end-to-end data analysis workflow and can articulate a clear plan

### Execution Steps

1. **Read the scenario carefully**: What game? What question are they trying to answer?

2. **Identify the analytical goal**:
   - Understanding player behavior?
   - Optimizing game design?
   - Revenue analysis?

3. **Structure your answer** using this framework:

   **A. Data Collection & Sources**:
   - What data do you need to collect?
   - Where will it come from? (gameplay events, user profiles, transactions)

   **B. Data Pipeline & Storage**:
   - How will data be transmitted? (event tracking, API calls)
   - How will it be stored? (database schema)
   - What tables/structure?

   **C. Analysis & Metrics**:
   - What metrics/KPIs will you calculate?
   - What queries will you run?
   - What statistical tests might be needed?

   **D. Visualization & Insights**:
   - What graphs/charts will you create?
   - What insights are you looking for?
   - How will results be communicated?

4. **Sketch a diagram** (if helpful):
   - Data flow: Game → Backend → Database → Analysis Tool
   - Example dashboard layout
   - Sample charts

5. **Use proper terminology**:
   - Data pipeline, ETL, normalization
   - Event tracking, telemetry
   - Segmentation, cohort analysis
   - A/B testing, statistical significance

### Answer Template

```
**Analytical Objective**:
[State what you're trying to learn/optimize]

**1. Data Collection**:
- [Event/data point 1 to collect]
- [Event/data point 2 to collect]
- [Event/data point 3 to collect]

**2. Data Pipeline**:
- Game events → [Backend API] → [Database]
- Schema: [Brief description of key tables]

**3. Metrics & Analysis**:
- [Metric 1]: [How to calculate]
- [Metric 2]: [How to calculate]
- Segmentation by: [demographics, behavior, etc.]

**4. Visualization**:
- [Chart type 1]: [What it shows]
- [Chart type 2]: [What it shows]

**5. Expected Insights**:
- [Insight 1 we hope to discover]
- [Actionable recommendation based on data]
```

### Example Answer

**Question**: "Design an analysis to understand which cards in a deck-building game are most powerful"

**Answer**:

**Analytical Objective**:
Identify which cards contribute most to player wins to inform game balance decisions.

**1. Data Collection**:
- Card usage: which cards are played in each match
- Win/loss outcomes: match results for each player
- Deck composition: full deck list for each match
- Player progression: rank/level to control for skill

**2. Data Pipeline**:
- Track events: "card_played", "match_ended"
- Store in MySQL with tables: `matches`, `decks`, `card_usage`, `cards`
- Normalized schema linking cards → decks → matches → outcomes

**3. Metrics & Analysis**:
- **Win Rate by Card**: % wins for decks containing card X
- **Usage Frequency**: How often each card appears
- **Win Rate Correlation**: Statistical test for card X presence vs wins
- Segment by player skill (beginner vs expert)

**4. Visualization**:
- **Heatmap**: Card win rates (color-coded)
- **Bar Chart**: Most/least used cards
- **Scatter Plot**: Usage frequency vs win rate (identify outliers)

**5. Expected Insights**:
- High win rate + high usage = likely overpowered (nerf candidate)
- High win rate + low usage = hidden gem (balanced)
- Low win rate + high usage = perceived strong but weak (noob trap)

**Actionable Recommendations**:
- Balance patches based on statistical outliers
- Monitor post-patch to verify changes

### Time Management

- 5 min: Understand question and brainstorm
- 10 min: Write structured answer
- 5 min: Add diagram or sketch (optional)

---

## Question 4: Statistical Test

**Points**: 1 point
**Time**: 10-15 minutes
**Difficulty**: Medium

### Strategy

**Goal**: Choose the correct statistical test, run it in R, interpret p-value

### Execution Steps

1. **Read the question**: What are you comparing?
   - Two groups? (A vs B)
   - Success rates / proportions? (chi-squared)
   - Means / averages? (t-test)

2. **Use Statistical_Testing_Decision_Tree.md**: Decide which test to use

3. **Open R_Statistical_Analysis_Library.R**: Find the template code

4. **Run the test**:
   - Load data if needed
   - Adapt template with your data
   - Extract p-value

5. **Interpret the result**:
   - Compare p-value to 0.05
   - State conclusion clearly

6. **Write your answer**: Include statistics + interpretation

### Answer Template

```
**Test Used**: [Chi-squared / t-test / proportion test]

**Reason**: [Why this test is appropriate]

**Data Summary**:
- Group A: [metric + sample size]
- Group B: [metric + sample size]

**Test Results**:
- Test statistic: [value]
- p-value: [value]

**Interpretation**:
Since p = [value] [< or ≥] 0.05, we [reject / fail to reject] the null hypothesis.

**Conclusion**:
There [IS / IS NOT] a statistically significant difference between the groups.

[Optional: Business implication - what does this mean?]
```

### Example Answer

**Question**: "Group A (n=1000) has 28% success rate, Group B (n=1000) has 22% success rate. Is the difference significant?"

**Answer**:

**Test Used**: Chi-squared test

**Reason**: We are comparing proportions (success rates) between two independent groups.

**R Code**:
```r
contingency_table <- matrix(c(280, 720, 220, 780), nrow=2, byrow=TRUE)
chi_result <- chisq.test(contingency_table)
print(chi_result)
```

**Test Results**:
- Chi-squared statistic: χ² = 10.23
- p-value = 0.0014

**Interpretation**:
Since p = 0.0014 < 0.05, we reject the null hypothesis.

**Conclusion**:
There IS a statistically significant difference in success rates between Group A (28%) and Group B (22%). The difference of 6 percentage points is unlikely to be due to random chance.

### Common Mistakes to Avoid

- ❌ Using wrong test (t-test for proportions, chi-squared for means)
- ❌ Not stating the p-value explicitly
- ❌ Wrong interpretation (saying "accept null hypothesis")
- ❌ Forgetting to check assumptions (sample size, independence)

---

## Question 5: A/B Testing Case Study

**Points**: 4 points (44% of exam!)
**Time**: 40-45 minutes
**Difficulty**: High (comprehensive)

### Strategy

**Goal**: Complete end-to-end A/B test analysis with business recommendation

**CRITICAL**: Use the **AB_Testing_Complete_Toolkit.md** - it has the complete 6-step workflow!

### Execution Steps (6 Steps)

**STEP 1**: Understand the Problem (2 min)
- [ ] What's being tested?
- [ ] What are the groups (A vs B)?
- [ ] What's the primary metric?
- [ ] What's the business goal?

**STEP 2**: Load & Explore Data (5 min)
- Load CSV or connect to database
- Check structure, group sizes
- Verify no missing values

**STEP 3**: Calculate Group Metrics (10 min)
- Use dplyr to summarize by group
- Calculate success rates or means
- Note the numbers for your answer

**STEP 4**: Run Statistical Test (10 min)
- Use Statistical_Testing_Decision_Tree.md to choose test
- Run chi-squared or t-test in R
- Extract p-value

**STEP 5**: Interpret Results (5 min)
- Is p < 0.05? (significant or not)
- Calculate effect size (difference)
- Estimate business impact

**STEP 6**: Make Recommendation (8 min)
- Clear decision: Implement / Don't Implement / Need More Data
- Support with evidence
- Connect to business goals
- Mention any caveats

### Answer Template (USE THIS!)

```
**RECOMMENDATION**: [Implement / Do Not Implement / Need More Data]

---

**STATISTICAL EVIDENCE**:
- Group A [metric]: X% (n = N)
- Group B [metric]: Y% (n = N)
- Absolute difference: Z percentage points
- Relative improvement: [(X-Y)/Y × 100]%
- Statistical test: [Chi-squared / t-test]
- Test statistic: [value]
- p-value: [value]
- Result: [Statistically significant / Not significant] at α = 0.05

---

**BUSINESS REASONING**:
The [feature description] in Group A resulted in [direction] change in [metric].

Impact Analysis:
- [Quantify the business impact if rolled out]
- [Effect on player experience]
- [Alignment with business goals]

---

**RECOMMENDATION JUSTIFICATION**:
I recommend [action] because:
1. [Statistical evidence summary]
2. [Business benefit/risk assessment]
3. [Player experience consideration]

---

**ADDITIONAL CONSIDERATIONS**:
- [Caveat 1: sample size, test duration, etc.]
- [Secondary metrics to monitor]
- [Risks or trade-offs to consider]
- [Implementation suggestions: gradual rollout, monitoring plan]
```

### Example (Abbreviated)

**Recommendation**: **IMPLEMENT** the easier Level 20 difficulty for all players

**Statistical Evidence**:
- Group A (easier): 28% success (n=1000)
- Group B (original): 22% success (n=1000)
- Difference: 6 percentage points
- Improvement: 27.3% relative increase
- Chi-squared: χ² = 10.23, p = 0.0014
- **Result: Statistically significant (p < 0.05)**

**Business Reasoning**:
The easier difficulty increased success rate by 6 percentage points, leading to better player experience and likely improved retention at this critical level. If rolled out to 500,000 annual players, this represents 30,000 additional completions.

**Recommendation Justification**:
I recommend implementation because (1) the improvement is statistically significant (p=0.0014), (2) the effect size is meaningful (27% relative increase), and (3) improving Level 20 completion aligns with retention goals while maintaining appropriate challenge progression.

**Considerations**:
- Monitor Level 21-25 completion to ensure no negative downstream effects
- Track long-term retention to verify easier level doesn't reduce engagement
- Consider gradual rollout to 50% of users first as safety measure

### Time Allocation Breakdown

- 2 min: Understand problem
- 5 min: Load and explore data
- 10 min: Calculate metrics
- 10 min: Run statistical test
- 5 min: Interpret results
- 8-10 min: Write recommendation
- 3 min: Review and polish

### Critical Success Factors

✓ **Clear recommendation**: Don't be ambiguous - make a decision

✓ **Show the p-value**: Must explicitly state and interpret

✓ **Quantify the effect**: Not just "A is better" but "A is 6 percentage points higher"

✓ **Business context**: Connect statistics to real business impact

✓ **Consider trade-offs**: Show you're thinking holistically

### Common Mistakes to Avoid

- ❌ **No clear recommendation**: Being wishy-washy ("could go either way")
- ❌ **Missing p-value**: Not stating the statistical significance
- ❌ **Just reporting numbers**: Not interpreting what they mean
- ❌ **Ignoring business context**: Pure statistics without business reasoning
- ❌ **Wrong test choice**: Using t-test for proportions (use chi-squared!)

---

## General Exam Tips

### Before Starting

1. **Read ALL questions first** (5 min):
   - Understand the full scope
   - Identify easy vs hard questions
   - Plan your time allocation

2. **Set up your workspace**:
   - Open this EXAM_EXECUTION_PLAYBOOK
   - Open R_Statistical_Analysis_Library.R in RStudio
   - Open SQL_Query_Templates.sql in text editor
   - Have all Quick_References ready

3. **Do a quick tech check**:
   - R works: `1 + 1`
   - SQL works: `SELECT 1;`
   - Can access exam data files

### During the Exam

1. **Follow the recommended order**:
   - Q1 → Q2 → Q5 → Q4 → Q3 (do Q5 third while fresh!)

2. **Time management**:
   - Set mental timers for each question
   - If stuck, move on (mark to return)
   - Leave 10 min at end for review

3. **Show your work**:
   - Write clear explanations
   - Include code snippets
   - State assumptions explicitly

4. **Partial credit strategy**:
   - Even if unsure, write something
   - Show your reasoning
   - Explain your approach

### Final Review (Last 10 Minutes)

- [ ] All questions answered (no blanks)
- [ ] All code snippets are correct (no syntax errors)
- [ ] All p-values stated explicitly
- [ ] All recommendations are clear
- [ ] Spelling and grammar checked
- [ ] Calculations double-checked

---

## Emergency Troubleshooting

### "I'm stuck on Q5 and running out of time!"

**Mini-version** (15 min):
1. Load data (2 min)
2. Calculate group metrics manually (3 min)
3. Run chi-squared test, get p-value (5 min)
4. Write brief recommendation with p-value (5 min)

**Minimum required**:
- State the metrics for both groups
- State the p-value
- Make a clear recommendation
- One sentence of reasoning

### "R code isn't working!"

1. Check error message carefully
2. Verify data loaded: `head(data)`
3. Check column names: `colnames(data)`
4. Use simpler approach: manual calculation + basic test
5. If all else fails: Calculate by hand, show your work

### "I don't know which statistical test to use!"

**Quick decision**:
- Comparing percentages/rates? → **Chi-squared**
- Comparing averages/means? → **t-test**
- When in doubt for A/B testing → **Chi-squared** (most common)

---

## Final Pep Talk

You've got this! Remember:

✓ **Q1-Q2**: Easy points - don't overthink (2 pts)

✓ **Q5**: Biggest value - give it proper time (4 pts)

✓ **Q4**: Template-based - use the code library (1 pt)

✓ **Q3**: Open-ended - just be logical and structured (2 pts)

**Total target: 7-8 points = strong pass!**

Stay calm, follow the playbook, and trust your preparation.

**Good luck!**
