# Data Analysis Exam - Master Guide

**Purpose**: Read this guide 10 minutes before exam starts to orient yourself
**Use Once**: Before beginning the exam - then switch to EXAM_EXECUTION_PLAYBOOK during exam

---

## Exam Overview

### Basic Information
- **Total Points**: 9 points
- **Total Questions**: 5 questions
- **Estimated Time**: 90-120 minutes
- **Format**: In-person, computer-based
- **Tools Available**: R, SQL/MySQL, digital notes
- **AI Tools**: NOT allowed
- **Your Notes**: All materials in this folder ARE allowed

---

## Question Breakdown

| Question | Points | Topic | Time | Difficulty | Resources Needed |
|----------|--------|-------|------|------------|------------------|
| **Q1** | 1 | KPI Definitions | 5-10 min | Easy | KPI_Quick_Reference.md |
| **Q2** | 1 | SQL Query | 5-10 min | Easy-Medium | SQL_Query_Templates.sql |
| **Q3** | 2 | Data Analysis Design | 15-20 min | Medium | EXAM_EXECUTION_PLAYBOOK.md |
| **Q4** | 1 | Statistical Test | 10-15 min | Medium | Statistical_Testing_Decision_Tree.md<br>R_Statistical_Analysis_Library.R |
| **Q5** | 4 | A/B Testing Case Study | 40-45 min | High | AB_Testing_Complete_Toolkit.md<br>R_Statistical_Analysis_Library.R |

### Point Distribution by Category:
- **Easy Points** (Q1 + Q2): 2 points - should be straightforward
- **Medium Points** (Q3 + Q4): 3 points - require application of knowledge
- **Hard Points** (Q5): 4 points - comprehensive analysis

**Key Insight**: Q5 is worth 44% of your grade - allocate time accordingly!

---

## Strategic Approach

### Time Management Philosophy

**Total Available**: ~90-120 minutes

**Recommended Allocation**:
```
Q1 (KPIs):              5-10 min   → Easy confidence builder
Q2 (SQL):               5-10 min   → Easy technical execution
Q5 (A/B Testing):      40-45 min   → BIGGEST VALUE - do this while fresh!
Q4 (Stats Test):       10-15 min   → Template-based, straightforward
Q3 (Design):           15-20 min   → Open-ended, save for last
Review:                10-15 min   → Final check
```

### Question Order Strategy

**Recommended Order** (not sequential):
1. **Q1 first** → Quick win, builds confidence
2. **Q2 second** → Another quick win
3. **Q5 third** → Tackle biggest question while mentally fresh (NOT last!)
4. **Q4 fourth** → Apply templates, relatively quick
5. **Q3 fifth** → Most open-ended, can manage even when tired
6. **Review** → Final 10 minutes

**Rationale**:
- Get easy points early (momentum)
- Do Q5 while sharp (it's 44% of grade!)
- Save creative Q3 for last (can still get partial credit when tired)

---

## What Each Question Tests

### Q1: KPI Definitions (Knowledge Recall)
**Tests**: Do you know standard game analytics metrics?

**What they want**:
- Clear definitions
- Correct formulas
- Understanding of what each KPI measures

**Success criteria**:
- Name spelled out + abbreviation
- 1-2 sentence definition
- Formula/calculation method
- Optional: Brief example

**Time-saving tip**: Use KPI_Quick_Reference.md - all definitions are there

---

### Q2: SQL Query (Technical Execution)
**Tests**: Can you write or interpret SQL queries?

**What they want**:
- Correct SQL syntax
- Proper use of JOINs
- Understanding of aggregations
- OR: Correct interpretation of what a query does/returns

**Success criteria**:
- Query runs without errors
- Returns correct results
- Uses appropriate functions (COUNT DISTINCT, DATE, etc.)
- Well-formatted and commented

**Time-saving tip**: Use SQL_Query_Templates.sql - adapt existing templates

---

### Q3: Data Analysis Design (Strategic Thinking)
**Tests**: Do you understand end-to-end data analysis workflow?

**What they want**:
- Logical approach to solving analytical problems
- Understanding of data collection, storage, analysis, visualization
- Ability to design appropriate metrics and visualizations
- Business thinking (actionable insights)

**Success criteria**:
- Clear structured approach
- Specific data points to collect
- Appropriate metrics and visualizations
- Connection to business goals
- Demonstrates understanding of full pipeline

**Time-saving tip**: Follow framework in EXAM_EXECUTION_PLAYBOOK (Data → Pipeline → Analysis → Viz)

---

### Q4: Statistical Test (Applied Statistics)
**Tests**: Can you choose and execute the right statistical test?

**What they want**:
- Correct test selection (chi-squared vs t-test)
- Proper execution in R
- Correct p-value interpretation
- Clear conclusion

**Success criteria**:
- Identified correct test with reasoning
- Ran test successfully in R
- Stated p-value explicitly
- Interpreted significance correctly (p < 0.05 or not)
- Connected to practical meaning

**Time-saving tip**: Use Statistical_Testing_Decision_Tree.md → R_Statistical_Analysis_Library.R

---

### Q5: A/B Testing Case Study (Comprehensive Analysis)
**Tests**: Can you do end-to-end A/B test analysis and make business recommendations?

**What they want**:
- Complete analytical workflow
- Statistical rigor (correct test, p-value)
- Business thinking (recommendation with justification)
- Consideration of trade-offs
- Clear communication

**Success criteria**:
- Loaded and explored data correctly
- Calculated group metrics accurately
- Ran appropriate statistical test
- Stated p-value and significance
- Made clear recommendation (implement/don't implement/need more data)
- Justified with both statistics AND business reasoning
- Mentioned considerations/caveats

**Time-saving tip**: Use AB_Testing_Complete_Toolkit.md - follow 6-step workflow exactly

---

## Success Targets

### Minimum Pass: ~4.5 points (50%)
```
Q1: 0.5 pts (partial)
Q2: 0.5 pts (partial)
Q3: 1 pt (half credit)
Q4: 0.5 pts (partial)
Q5: 2 pts (half credit)
Total: 4.5 pts
```

### Target Score: 7-8 points (78-89%)
```
Q1: 1 pt (full credit - easy)
Q2: 1 pt (full credit - easy)
Q3: 1.5 pts (good attempt)
Q4: 1 pt (full credit - templates available)
Q5: 3-3.5 pts (strong analysis, minor gaps OK)
Total: 7.5-8 pts
```

### Stretch Goal: 9 points (100%)
```
All questions fully answered with:
- Correct methodology
- Clear explanations
- Proper justifications
- No calculation errors
```

---

## Common Pitfalls to Avoid

### Q1 Pitfalls
- ❌ Confusing ARPU (all users) with ARPPU (paying users only)
- ❌ Not spelling out abbreviations
- ❌ Overly verbose definitions

### Q2 Pitfalls
- ❌ Using INNER JOIN when LEFT JOIN is needed
- ❌ Forgetting COUNT DISTINCT for user metrics
- ❌ Integer division in percentage calculations (use 100.0 not 100)

### Q3 Pitfalls
- ❌ Being too vague ("collect data about players")
- ❌ Missing steps in the pipeline
- ❌ Not connecting to business goals

### Q4 Pitfalls
- ❌ Using wrong test (t-test for proportions, chi-squared for means)
- ❌ Not stating p-value explicitly
- ❌ Wrong interpretation ("accept null hypothesis" - wrong language)

### Q5 Pitfalls (CRITICAL - worth 4 points!)
- ❌ No clear recommendation (being indecisive)
- ❌ Missing p-value or significance test
- ❌ Just reporting numbers without interpretation
- ❌ No business reasoning (pure statistics only)
- ❌ Choosing wrong statistical test
- ❌ Not showing your work (no code, no intermediate steps)

---

## Your Exam Toolkit

### Keep These Open During Exam:

1. **EXAM_EXECUTION_PLAYBOOK.md** ← PRIMARY GUIDE (use during exam)
   - Step-by-step for each question type
   - Answer templates
   - Time management

2. **R_Statistical_Analysis_Library.R** ← COPY-PASTE CODE
   - All R code you need
   - Chi-squared test templates
   - t-test templates
   - Data manipulation

3. **AB_Testing_Complete_Toolkit.md** ← FOR Q5 (4 points!)
   - 6-step workflow
   - Answer template
   - Example walkthrough

4. **SQL_Query_Templates.sql** ← FOR Q2
   - Common query patterns
   - DAU, MAU, ARPU, retention queries
   - JOIN examples

5. **Statistical_Testing_Decision_Tree.md** ← QUICK REFERENCE
   - Which test to use?
   - p-value interpretation

6. **KPI_Quick_Reference.md** ← FOR Q1
   - All KPI definitions
   - Formulas
   - Examples

---

## Pre-Exam Checklist (Morning Of)

### 30 Minutes Before Exam:

- [ ] Open all 6 documents listed above
- [ ] Test R: Run `1 + 1` to verify it works
- [ ] Test SQL: Run `SELECT 1;` to verify connection
- [ ] Locate exam data files (CSV or database)
- [ ] Have scratch paper ready
- [ ] Bathroom break
- [ ] Water bottle filled
- [ ] Take 3 deep breaths

### Mental Preparation:

Read these reminders:

✓ "I have all the tools I need"
✓ "Q5 is big but manageable - I have the complete workflow"
✓ "Easy questions first, build momentum"
✓ "Show my work, partial credit is valuable"
✓ "7-8 points is my target - I can do this"

---

## During the Exam

### First 5 Minutes (Don't Skip This!)

1. **Read ALL questions** before starting
   - Understand full scope
   - Identify easy vs hard
   - Note any surprises

2. **Quick tech check**:
   - Can I access the data?
   - Do all my reference files open?
   - Is R/SQL working?

3. **Mental commitment to the plan**:
   - "I will follow my order: Q1 → Q2 → Q5 → Q4 → Q3"
   - "I will allocate 40+ minutes to Q5"
   - "I will leave 10 min for review"

### Execution Mode

- **Stay calm**: If stuck, move to next question
- **Show your work**: Even partial answers get partial credit
- **Use your resources**: That's why you prepared them!
- **Watch the clock**: But don't panic - estimates are flexible

### Last 10 Minutes (Review)

- [ ] All questions answered (no blanks)
- [ ] Q5 recommendation is crystal clear
- [ ] All p-values are stated
- [ ] Code has no obvious syntax errors
- [ ] Quick spelling/grammar check
- [ ] Calculations double-checked

---

## Confidence Builders

### What You Know

✓ You have **3 complete deliveries** of experience with this material

✓ You've done:
  - Full KPI analysis (Delivery 1)
  - Real A/B testing with statistical tests (Delivery 2)
  - Complex data pipelines and visualization (Delivery 3)

✓ You have **21 practiced SQL queries** in MYSQL Exercise folder

✓ You have **complete code templates** for every test you'll need

✓ You understand the **full analytics pipeline** from game → database → insights

### What You've Prepared

✓ **7 comprehensive reference documents** covering every question type

✓ **Copy-paste ready code** for all statistical tests

✓ **Clear workflows** for complex questions (especially Q5)

✓ **Decision trees** for choosing the right approach

✓ **Answer templates** for all question types

---

## The 80/20 Rule for This Exam

**20% of content = 80% of points**

### Focus Areas (High ROI):

1. **A/B Testing Workflow** (Q5 - 4 pts):
   - Chi-squared test execution
   - p-value interpretation
   - Business recommendation structure

2. **Statistical Test Selection** (Q4 - 1 pt):
   - Proportions → Chi-squared
   - Means → t-test

3. **SQL Patterns** (Q2 - 1 pt):
   - LEFT JOIN behavior
   - COUNT DISTINCT
   - Date functions

4. **KPI Definitions** (Q1 - 1 pt):
   - DAU, MAU, ARPU, ARPPU
   - Retention (D1, D3, D7)
   - Conversion Rate

**These 4 areas = 7 points (78% of grade)**

Q3 is important too (2 pts) but more flexible/open-ended

---

## Final Mindset

### Remember:

1. **You're prepared**: You have tools for everything
2. **Partial credit exists**: Show your thinking even if unsure
3. **Q5 is your focus**: 44% of grade, give it proper time
4. **Templates are your friend**: Don't reinvent the wheel
5. **Business context matters**: Connect stats to real decisions

### Your Mantra:

**"I will be methodical, use my resources, and trust my preparation."**

---

## After Reading This Guide

### Next Actions:

1. **Skim the Quick References** (5 min):
   - KPI_Quick_Reference.md
   - Statistical_Testing_Decision_Tree.md

2. **Review Q5 workflow** (5 min):
   - AB_Testing_Complete_Toolkit.md (just the 6-step summary)

3. **Take a break** (5 min):
   - Stand up, stretch
   - Clear your mind
   - Get water

4. **When exam starts**:
   - Close THIS guide
   - Open EXAM_EXECUTION_PLAYBOOK.md
   - Follow it step-by-step

---

## You've Got This!

Your preparation has been thorough. You have everything you need. Now it's just execution.

**Target**: 7-8 points
**Strategy**: Q1 → Q2 → Q5 → Q4 → Q3
**Resources**: All reference documents open and ready
**Mindset**: Calm, methodical, confident

**Good luck! See you on the other side with a strong pass!** 🎯
