# Practice Exam Answer Sheet
**Date**: 2026-01-15 (Practice Run)
**Exam**: Data Analysis Final Exam (2025 Example)
**Time Started**: ____________
**Time Ended**: ____________

---

## Question 1: KPI Definitions (1 point) - Target Time: 5 minutes
**Start Time**: ____________
**End Time**: ____________

**Question**: What are the most common KPIs used to measure the economic performance of a game? Provide a short definition of each.

**Your Answer**:

*(Write your answer here - use KPI_Quick_Reference.md for help)*

**ARPU (Average Revenue Per User)**
- Definition:
- Formula:

**ARPPU (Average Revenue Per Paying User)**
- Definition:
- Formula:

**Conversion Rate**
- Definition:
- Formula:

**LTV (Lifetime Value)**
- Definition:
- Formula:

**[Add more if needed]**

---

## Question 2: SQL LEFT JOIN (1 point) - Target Time: 5 minutes
**Start Time**: ____________
**End Time**: ____________

**Question**: How many rows would the following query return?
```sql
SELECT * FROM Players p LEFT JOIN Sessions s ON p.Player_id = s.Player_id
```

**Tables**:
```
Players:              Sessions:
Player_id  Name       Session_id  Player_id
1          Eva        1           1
2          Elena      2           1
3          Elvira     3           2
4          Esteban
```

**Your Answer**: __________ rows

**Explanation**:





---

## Question 3: Data Analysis Design (2 points) - Target Time: 15 minutes
**Start Time**: ____________
**End Time**: ____________

**Question**: You have been hired as a data analyst for Balatro (or another game). The CEO wants one graph that provides insights into game design. Decide what data to collect, analyze, and how to create the graph.

**Your Answer**:

### 1. The Key Graph
*(Describe which graph you would create and why)*




### 2. Data Collection
*(What data will you track during the game?)*




### 3. Data Organization
*(How will you store the data in tables?)*




### 4. Data Analysis
*(What calculations or metrics will you use?)*




### 5. Data Visualization
*(Sketch or describe the graph)*

```
[Draw your graph sketch here or describe it in detail]




```

---

## Question 4: Statistical Test (1 point) - Target Time: 20 minutes
**Start Time**: ____________
**End Time**: ____________

**Question**: Using the file sweet.sql, show if the two groups are significantly different in their session length.

**Your Answer**:

### Statistical Test Used
*(Which test did you choose and why?)*




### Justification
*(Why is this test appropriate?)*




### R Code Used
```r
# Paste your R code here




```

### Results
- Group A mean session length: __________
- Group B mean session length: __________
- Test statistic: __________
- p-value: __________

### Conclusion
*(Interpret the results - are they significantly different?)*




---

## Question 5: A/B Testing Case Study (4 points) - Target Time: 45 minutes
**Start Time**: ____________
**End Time**: ____________

**Question**: Should we keep the original difficulty or lower it for level 20 in Sweety Break Legend?
- Group A: Easier version
- Group B: Original harder version

**Your Answer**:

## Recommendation: [KEEP ORIGINAL / LOWER DIFFICULTY / NEED MORE DATA]

### Statistical Evidence
- **Group A (Easier)**: ____% success rate (___/___ players)
- **Group B (Harder/Original)**: ____% success rate (___/___ players)
- **Difference**: ____ percentage points
- **Statistical test**: χ² = ____, p-value = ____
- **Statistical Significance**: [YES / NO] (p [< / ≥] 0.05)

### Business Reasoning
*(Why does this matter for the business?)*




**Quantified Impact**:
*(Calculate the business impact with numbers)*




**Player Experience Considerations**:
*(How does this affect players?)*




### Recommendation Justification
*(Why should they follow your recommendation?)*

1. **Statistical Evidence**:



2. **Business Impact**:



3. **Player Retention**:



4. **Magnitude**:



### Additional Considerations
**Potential Risks**:
-



**Mitigation Strategies**:
-



**Secondary Metrics to Monitor**:
-



**Final Decision**:



---

## R Code Workspace for Q4 & Q5

```r
# Paste all your R code here as you work through Q4 and Q5







```

---

## Self-Assessment Checklist

### Time Management
- [ ] Q1 completed in 5 minutes or less
- [ ] Q2 completed in 5 minutes or less
- [ ] Q3 completed in 15 minutes or less
- [ ] Q4 completed in 20 minutes or less
- [ ] Q5 completed in 45 minutes or less

### Content Quality
- [ ] Q1: Focused on ECONOMIC KPIs (ARPU, ARPPU, Conversion, LTV)
- [ ] Q2: Correct answer (4 rows) with clear explanation
- [ ] Q3: Covered all 4 sections (Collection, Organization, Analysis, Visualization)
- [ ] Q4: Correct test choice (t-test), successful execution, clear interpretation
- [ ] Q5: Complete 6-step workflow, clear recommendation with evidence

### Materials Usage
- [ ] Used KPI_Quick_Reference.md for Q1
- [ ] Used SQL_Query_Templates.sql for Q2
- [ ] Used EXAM_EXECUTION_PLAYBOOK.md for Q3 framework
- [ ] Used Statistical_Testing_Decision_Tree.md for Q4
- [ ] Used R_Statistical_Analysis_Library.R for Q4 & Q5
- [ ] Used AB_Testing_Complete_Toolkit.md for Q5

### Areas to Improve
*(Note what you struggled with)*




---

## Tomorrow's Exam Day Checklist

**Before Exam** (30 minutes before):
- [ ] Read EXAM_MASTER_GUIDE.md (10 min)
- [ ] Skim AB_Testing_Complete_Toolkit.md 6-step workflow (5 min)
- [ ] Review Statistical_Testing_Decision_Tree.md (5 min)
- [ ] Test R: run `1 + 1`
- [ ] Test SQL: run `SELECT 1;`
- [ ] Open all 6 documents in tabs
- [ ] Take 3 deep breaths, stay calm

**During Exam**:
- [ ] Follow recommended order: Q1 → Q2 → Q5 → Q4 → Q3
- [ ] Allocate 40-45 minutes for Q5
- [ ] Use templates - don't reinvent the wheel
- [ ] Show all work and reasoning clearly

**Target Score**: 7.5-8 points (83-89%)
