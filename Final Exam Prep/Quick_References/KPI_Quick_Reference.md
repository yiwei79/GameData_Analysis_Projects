# KPI Quick Reference Card

**Purpose**: One-page reference for all game analytics KPIs
**Use For**: Question 1 (KPI Definitions)
**Time**: 5 minutes

---

## Complete KPI Table

| KPI NAME | DEFINITION | FORMULA | SQL EXAMPLE | INTERPRETATION EXAMPLE |
|----------|------------|---------|-------------|------------------------|
| **DAU** | Daily Active Users | COUNT(DISTINCT user_id) per day | `SELECT COUNT(DISTINCT user_id) FROM sessions WHERE DATE(start_time) = '2020-01-15'` | 1,250 players active on Jan 15 |
| **MAU** | Monthly Active Users | COUNT(DISTINCT user_id) per month | `SELECT COUNT(DISTINCT user_id) FROM sessions WHERE DATE_FORMAT(start_time, '%Y-%m') = '2020-01'` | 15,000 players active in January |
| **Stickiness** | Engagement ratio (DAU/MAU) | DAU / MAU | `DAU / MAU = 1250 / 15000 = 0.083` | 8.3% of monthly users play daily (higher = better engagement) |
| **ARPU** | Average Revenue Per User (ALL users) | Total Revenue / Total Users | `SUM(revenue) / COUNT(DISTINCT user_id)` from users (ALL) | $10.00 per user on average (paying + non-paying) |
| **ARPPU** | Average Revenue Per PAYING User | Total Revenue / Paying Users Only | `SUM(revenue) / COUNT(DISTINCT user_id)` from transactions only | $20.00 per paying user (ARPPU > ARPU always) |
| **Conversion Rate** | % of users who make a purchase | (Paying Users / Total Users) × 100 | `(250 / 1000) × 100 = 25%` | 25% of users made at least one purchase |
| **D1 Retention** | % of users who return 1 day after signup | (Users active on Day 1 / New Users) × 100 | `(300 / 1000) × 100 = 30%` | 30% of new users return the next day |
| **D3 Retention** | % of users who return within 3 days | (Users active on Day 3 / New Users) × 100 | `(220 / 1000) × 100 = 22%` | 22% of new users return on day 3 |
| **D7 Retention** | % of users who return within 7 days | (Users active on Day 7 / New Users) × 100 | `(180 / 1000) × 100 = 18%` | 18% of new users return after a week |
| **LTV** | Lifetime Value | ARPU × Avg Lifetime / Churn Rate | `$10 × 30 days / 0.1 = $3,000` | Expected total revenue per user over lifetime |
| **Churn Rate** | % of users who stop playing | (Users Left / Total Users) × 100 | `(100 / 1000) × 100 = 10%` | 10% of users stopped playing this month |
| **Session Duration** | Average session length | AVG(end_time - start_time) | `AVG(TIMESTAMPDIFF(MINUTE, start, end)) = 23.5` | Average session is 23.5 minutes |
| **Session Frequency** | Average sessions per user | Total Sessions / Unique Users | `5000 sessions / 1200 users = 4.2` | Users have 4.2 sessions on average |

---

## Category Breakdowns

### Engagement KPIs (Activity)
- **DAU**: Daily Active Users
- **MAU**: Monthly Active Users
- **Stickiness**: DAU/MAU ratio
- **Session Duration**: How long users play
- **Session Frequency**: How often users play

**Good Values**:
- Stickiness > 20% = excellent daily engagement
- Session duration > 10 min = good engagement
- Session frequency > 3 sessions/user = good retention

---

### Retention KPIs (Coming Back)
- **D1 Retention**: Return next day
- **D3 Retention**: Return in 3 days
- **D7 Retention**: Return in 7 days
- **Churn Rate**: Users leaving

**Good Values**:
- D1 > 40% = excellent
- D1 > 30% = good
- D1 < 20% = concerning
- Churn < 5% per month = healthy

---

### Monetization KPIs (Revenue)
- **ARPU**: Revenue per all users
- **ARPPU**: Revenue per paying users
- **Conversion Rate**: % who pay
- **LTV**: Lifetime value

**Good Values**:
- Conversion > 5% = healthy F2P game
- ARPPU should be 2-5x ARPU
- LTV > Customer Acquisition Cost (CAC)

---

## Common Relationships

### ARPU vs ARPPU
```
ARPU = ARPPU × Conversion Rate

Example:
ARPPU = $20 (revenue per paying user)
Conversion = 50% (half of users pay)
ARPU = $20 × 0.50 = $10 (revenue per all users)

ARPU is ALWAYS less than ARPPU (includes non-paying users)
```

### DAU vs MAU (Stickiness)
```
Stickiness = DAU / MAU

High stickiness (20-40%) = users play almost every day (daily game)
Low stickiness (5-10%) = users play occasionally (weekly game)

Example:
DAU = 2,000 daily players
MAU = 10,000 monthly players
Stickiness = 2000/10000 = 0.20 = 20% (good for mobile game)
```

### Retention Decay Pattern
```
Typical Pattern:
D1 Retention: 40%
D3 Retention: 25%
D7 Retention: 18%
D30 Retention: 10%

Retention always decreases over time
Good games have slower decay (retain more users longer)
```

---

## Quick Definitions (For Exam Answers)

### Short Format (1 sentence each):

**DAU**: Number of unique users who play the game in a single day

**MAU**: Number of unique users who play the game in a single month

**Stickiness**: Ratio of DAU to MAU, measuring how often monthly users return daily

**ARPU**: Total revenue divided by total number of users (paying and non-paying)

**ARPPU**: Total revenue divided by only the users who made purchases

**Conversion Rate**: Percentage of total users who make at least one purchase

**D1 Retention**: Percentage of new users who return to play one day after registration

**LTV**: Estimated total revenue a user will generate over their entire lifetime

**Churn Rate**: Percentage of users who stop playing the game in a given period

**Session Duration**: Average length of time users spend in a single play session

---

## Formula Quick Reference

### Percentages:
```
Formula: (Part / Whole) × 100

Conversion Rate = (Paying Users / Total Users) × 100
Retention Rate = (Returning Users / New Users) × 100
Churn Rate = (Users Left / Total Users) × 100
```

### Averages:
```
Formula: SUM(values) / COUNT(items)

ARPU = Total Revenue / Total Users
ARPPU = Total Revenue / Paying Users
Avg Session Duration = SUM(session_lengths) / COUNT(sessions)
Avg Sessions per User = Total Sessions / Unique Users
```

### Ratios:
```
Formula: Value1 / Value2

Stickiness = DAU / MAU
LTV = ARPU × Avg Lifetime / Churn Rate
```

---

## Common Exam Question Formats

### Format 1: Define KPIs
**Question**: "Define the following KPIs: DAU, MAU, ARPU"

**Answer Template**:
- **DAU (Daily Active Users)**: The number of unique users who engage with the game on a given day
- **MAU (Monthly Active Users)**: The number of unique users who engage with the game within a given month
- **ARPU (Average Revenue Per User)**: The average revenue generated per user, calculated by dividing total revenue by total number of users (both paying and non-paying)

---

### Format 2: Calculate KPI
**Question**: "Given 500 paying users spent $10,000 total, and there are 2,000 total users, calculate ARPU and ARPPU"

**Answer**:
- **ARPPU** = $10,000 / 500 paying users = **$20 per paying user**
- **ARPU** = $10,000 / 2,000 total users = **$5 per user**
- **Conversion Rate** = 500 / 2,000 × 100 = **25%**

---

### Format 3: Interpret KPI
**Question**: "Your game has DAU = 2,000 and MAU = 50,000. What does this mean?"

**Answer**:
- **Stickiness** = 2,000 / 50,000 = 4%
- **Interpretation**: Only 4% of monthly players return daily, indicating low daily engagement. This suggests the game is played occasionally rather than daily. Consider implementing daily rewards or login bonuses to improve daily retention.

---

## Red Flags (Bad KPI Values)

| KPI | Red Flag | What It Means | Action Needed |
|-----|----------|---------------|---------------|
| D1 Retention | < 20% | Most users don't return | Fix onboarding, reduce early friction |
| Conversion Rate | < 2% | Almost no one pays | Review pricing, add value |
| Stickiness | < 5% | Users rarely play | Add daily content, events, rewards |
| Churn Rate | > 20% | Losing users fast | Improve retention features |
| Session Duration | < 5 min | Users leave quickly | Improve gameplay, reduce loading times |

---

## Industry Benchmarks

### Mobile Games (Typical):
- **D1 Retention**: 35-45% (good)
- **Conversion**: 2-5% (F2P games)
- **ARPPU**: $15-50
- **Stickiness**: 15-25%

### Casual Games:
- **Session Duration**: 5-15 minutes
- **Sessions per User**: 3-5 per week

### Mid-Core Games:
- **Session Duration**: 15-30 minutes
- **Sessions per User**: 10-15 per week

---

## Memory Tricks

**ARPU vs ARPPU**:
- ARPU = **A**ll users (pays + doesn't pay)
- ARPPU = **P**aying users only (always higher)

**Retention**:
- D1 = Day **1** after signup
- D7 = Day **7** after signup
- Higher number = more days = lower retention (natural decay)

**Stickiness**:
- **Sticky** = comes back often = high DAU/MAU ratio
- Non-sticky = casual play = low DAU/MAU ratio

---

## Final Tips for Q1

1. **Be concise**: 1-2 sentences per KPI definition

2. **Include formula**: Shows you understand how it's calculated

3. **Give example**: Makes definition concrete
   - "DAU is daily active users. For example, if 1,250 unique users played on January 15th, DAU = 1,250 for that day."

4. **Watch for variations**:
   - "Average revenue per user" = ARPU
   - "Daily actives" = DAU
   - "Day 1 retention" = D1 Retention

5. **Know the category**:
   - Engagement: DAU, MAU, stickiness
   - Retention: D1, D3, D7, churn
   - Monetization: ARPU, ARPPU, conversion, LTV

---

**This is worth 1 easy point - don't overthink it! Just know the definitions.**
