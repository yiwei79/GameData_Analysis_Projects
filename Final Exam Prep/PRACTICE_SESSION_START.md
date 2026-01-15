# 🎯 2-Hour Exam Practice Session - START HERE

**Date**: January 15, 2026
**Exam Tomorrow**: January 16, 2026
**Total Time**: 120 minutes

---

## 🚀 Quick Start Instructions

### Step 1: Open All Your Materials (2 minutes)

**Open these files in separate windows/tabs:**

1. **PRACTICE_ANSWERS.md** ← Where you'll write your answers
2. **EXAM_EXECUTION_PLAYBOOK.md** ← Your main guide (keep visible)
3. **AB_Testing_Complete_Toolkit.md** ← For Q5 (4 points!)
4. **KPI_Quick_Reference.md** ← For Q1
5. **Statistical_Testing_Decision_Tree.md** ← For test selection
6. **SQL_Query_Templates.sql** ← For Q2
7. **R_Statistical_Analysis_Library.R** ← R code templates

**Also open:**
- **QUICK_START_PRACTICE.R** in RStudio/R console
- Text editor for writing answers
- Timer (set for 120 minutes)

---

### Step 2: Load Your Practice Data in R (1 minute)

**This matches the ACTUAL exam workflow: SQL → R**

In RStudio or R console, run:

```r
# Navigate to the correct directory
setwd("/Users/yiwei/GithubRepos/GameData_Analysis_Projects/Final Exam Prep")

# Load the practice data (SQL-based workflow)
source("QUICK_START_PRACTICE.R")

# This will:
# - Load sweet_data from sweet_data.csv (200 game sessions)
# - Show data summary and structure
# - Preview Q4 data (session lengths by group)
# - Preview Q5 data (level 20 completion by group)
# - Set up practice workspace for Q4 and Q5

# Data is ready in 'sweet_data' variable!
```

**Expected output**:
```
================================================================
SWEET BREAK LEGEND - EXAM PRACTICE DATA
================================================================

✓ Data loaded successfully!

Total sessions: 200
Group A sessions: 100
Group B sessions: 100

Q4 PREVIEW: Session Length Comparison
Q5 PREVIEW: Level 20 Difficulty A/B Test

READY TO START PRACTICE!
================================================================
```

---

### Step 3: Start Your Timer - BEGIN! (2 hours)

**Your Training Schedule**:

| Phase | Time | Duration | Activity |
|-------|------|----------|----------|
| **Phase 1** | 0:00-0:10 | 10 min | ✓ Setup (you just completed this!) |
| **Phase 2** | 0:10-0:35 | 25 min | Practice Q1, Q2, Q3 |
| **Phase 3** | 0:35-0:55 | 20 min | Practice Q4 (Statistical Test) |
| **Phase 4** | 0:55-1:40 | 45 min | Practice Q5 (A/B Testing) ⭐ MOST IMPORTANT |
| **Phase 5** | 1:40-2:00 | 20 min | Review & Tomorrow's Prep |

**⏱️ START YOUR 2-HOUR TIMER NOW!**

---

## 📝 Practice Workflow

### Phase 2: Q1, Q2, Q3 (25 minutes)

#### Q1: KPI Definitions (5 minutes)
- **Start Time**: ________
- **Question**: Economic KPIs for games
- **Use**: KPI_Quick_Reference.md
- **Focus**: ARPU, ARPPU, Conversion Rate, LTV
- **Write in**: PRACTICE_ANSWERS.md under Q1

#### Q2: SQL LEFT JOIN (5 minutes)
- **Start Time**: ________
- **Question**: How many rows returned?
- **Answer**: 4 rows
- **Why**: LEFT JOIN keeps all players (1,2,3,4)
- **Write in**: PRACTICE_ANSWERS.md under Q2

#### Q3: Data Analysis Design (15 minutes)
- **Start Time**: ________
- **Use**: EXAM_EXECUTION_PLAYBOOK.md Q3 framework
- **Structure**: Collection → Organization → Analysis → Visualization
- **Write in**: PRACTICE_ANSWERS.md under Q3

---

### Phase 3: Q4 Statistical Test (20 minutes)

#### Q4: Session Length Comparison (20 minutes)
- **Start Time**: ________
- **Question**: Are Group A and B session lengths significantly different?
- **Data**: Use `sweet_data` (loaded from SQL/CSV workflow)

**Workflow**:
1. **Identify what's being compared** (2 min)
   - Session length (continuous variable = mean)
   - Two groups (A vs B)

2. **Use Decision Tree** (2 min)
   - Open Statistical_Testing_Decision_Tree.md
   - Comparing MEANS → Two groups → **t-test**

3. **Run t-test in R** (10 min)
   ```r
   # Extract session lengths by group
   group_a <- sweet_data$session_length_minutes[sweet_data$test_group == "A"]
   group_b <- sweet_data$session_length_minutes[sweet_data$test_group == "B"]

   # Run t-test
   t_result <- t.test(group_a, group_b)
   print(t_result)

   # Interpret
   p_value <- t_result$p.value
   if (p_value < 0.05) {
       cat("SIGNIFICANT: Groups differ (p =", p_value, ")\n")
   }
   ```

4. **Write answer** (6 min)
   - Template in EXAM_EXECUTION_PLAYBOOK.md
   - Include: test used, justification, results, conclusion
   - Write in PRACTICE_ANSWERS.md

---

### Phase 4: Q5 A/B Testing (45 minutes) ⭐ MOST CRITICAL

#### Q5: Level 20 Difficulty Decision (45 minutes)
- **Start Time**: ________
- **Question**: Lower difficulty or keep original?
- **Data**: Use `sweet_data` (loaded from SQL/CSV workflow)
- **Use**: AB_Testing_Complete_Toolkit.md (complete 6-step workflow)

**6-Step Workflow**:

**STEP 1: Understand Problem** (3 min)
- Group A = easier version
- Group B = harder version (original)
- Metric: Success rate (proportion)

**STEP 2: Explore Data** (5 min)
```r
head(sweet_data)
table(sweet_data$test_group)
summary(sweet_data$level_20_completed)
```

**STEP 3: Calculate Metrics** (10 min)
```r
library(dplyr)

group_summary <- sweet_data %>%
    group_by(test_group) %>%
    summarize(
        total = n(),
        successes = sum(level_20_completed == 1),
        failures = sum(level_20_completed == 0),
        success_rate = mean(level_20_completed) * 100
    )

print(group_summary)
```

**STEP 4: Run Statistical Test** (10 min)
```r
# Chi-squared test (comparing proportions)
# Prepare contingency table from group_summary
group_a <- group_summary %>% filter(test_group == "A")
group_b <- group_summary %>% filter(test_group == "B")

contingency_table <- matrix(
    c(group_a$successes, group_a$failures,
      group_b$successes, group_b$failures),
    nrow = 2, byrow = TRUE
)
rownames(contingency_table) <- c("Group_A_Easier", "Group_B_Harder")
colnames(contingency_table) <- c("Success", "Failure")

# Run test
chi_result <- chisq.test(contingency_table)
print(chi_result)

# Interpret
p_value <- chi_result$p.value
if (p_value < 0.05) {
    cat("SIGNIFICANT: Difficulty affects completion (p =", p_value, ")\n")
}
```

**STEP 5: Interpret Results** (5 min)
- Extract p-value
- Calculate business impact (how many more players complete?)
- Consider player experience

**STEP 6: Make Recommendation** (12 min)
- Write comprehensive answer in PRACTICE_ANSWERS.md
- Use template from AB_Testing_Complete_Toolkit.md
- Include: Recommendation, Evidence, Reasoning, Considerations

---

### Phase 5: Review (20 minutes)

#### Self-Assessment Checklist

**Time Management**:
- [ ] Q1 in ≤ 5 min?
- [ ] Q2 in ≤ 5 min?
- [ ] Q3 in ≤ 15 min?
- [ ] Q4 in ≤ 20 min?
- [ ] Q5 in ≤ 45 min?

**Quality Check**:
- [ ] Q1: Focused on economic KPIs?
- [ ] Q2: Got 4 rows with explanation?
- [ ] Q3: All 4 sections covered?
- [ ] Q4: Used t-test correctly?
- [ ] Q5: Complete 6-step workflow with recommendation?

**Identify Gaps**:
- What took longer than expected?
- Which concepts need review?
- Which materials need more familiarity?

**Tomorrow's Preparation**:
- Read EXAM_MASTER_GUIDE.md
- Review weak areas
- Organize materials for easy access
- Get good rest!

---

## 🎯 Expected Outcomes

**After This Practice Session, You Will:**

✅ Know exactly where to find each answer in your materials
✅ Have completed the full statistical testing workflow (t-test)
✅ Have mastered the 6-step A/B testing workflow
✅ Understand time management across 5 questions
✅ Have written complete answers for all question types
✅ Feel confident about tomorrow's exam

**Your Target Tomorrow**: 7.5-8 points (83-89%)

---

## ⚡ Quick Reference During Practice

**If you get stuck on...**

- **Q1 (KPIs)**: Open KPI_Quick_Reference.md → Economic section
- **Q2 (SQL)**: Think: LEFT JOIN keeps ALL left table rows
- **Q3 (Design)**: Use 4-part framework in EXAM_EXECUTION_PLAYBOOK.md
- **Q4 (Stats Test)**: Use Statistical_Testing_Decision_Tree.md → Comparing means → t-test
- **Q5 (A/B Testing)**: Follow AB_Testing_Complete_Toolkit.md 6 steps exactly

**Remember**:
- Q5 is worth 44% of your grade - allocate time accordingly!
- Use templates - don't reinvent the wheel
- Show your reasoning clearly

---

## 🚀 BEGIN YOUR PRACTICE NOW!

1. ✅ Materials opened
2. ✅ R data loaded
3. ⏱️ Timer started (120 minutes)
4. 📝 PRACTICE_ANSWERS.md ready

**→ Go to Question 1 and start practicing!**

**You've got this! Good luck with your practice session!** 🎯
