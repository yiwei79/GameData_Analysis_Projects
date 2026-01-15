# ================================================================
# QUICK START: 2-Hour Exam Practice Session
# ================================================================
# This script matches the ACTUAL exam workflow: SQL → R
# Use this to practice Q4 and Q5 with realistic data
# ================================================================

# Set working directory
setwd("/Users/yiwei/GithubRepos/GameData_Analysis_Projects/Final Exam Prep")

cat("================================================================\n")
cat("SWEET BREAK LEGEND - EXAM PRACTICE DATA\n")
cat("================================================================\n\n")

# ================================================================
# STEP 1: LOAD DATA (matches exam workflow)
# ================================================================
# In the real exam, you'll either:
# - Load sweet.sql into MySQL and query it, OR
# - Load the provided data file directly

cat("Loading data from sweet_data.csv...\n")
sweet_data <- read.csv("sweet_data.csv", header = TRUE)

cat("✓ Data loaded successfully!\n\n")

# ================================================================
# STEP 2: VERIFY DATA
# ================================================================

cat("=== Data Summary ===\n")
cat("Total sessions:", nrow(sweet_data), "\n")
cat("Group A sessions:", sum(sweet_data$test_group == "A"), "\n")
cat("Group B sessions:", sum(sweet_data$test_group == "B"), "\n\n")

cat("First 10 rows:\n")
print(head(sweet_data, 10))

cat("\n=== Data Structure ===\n")
print(str(sweet_data))

# ================================================================
# PREVIEW: Q4 DATA (Session Length)
# ================================================================

cat("\n")
cat("================================================================\n")
cat("Q4 PREVIEW: Session Length Comparison\n")
cat("================================================================\n")

cat("\nGroup A (Easier) - Session Length:\n")
cat("  Mean:", round(mean(sweet_data$session_length_minutes[sweet_data$test_group == "A"]), 2), "minutes\n")
cat("  SD:", round(sd(sweet_data$session_length_minutes[sweet_data$test_group == "A"]), 2), "\n")
cat("  Range:", round(min(sweet_data$session_length_minutes[sweet_data$test_group == "A"]), 2), "-",
    round(max(sweet_data$session_length_minutes[sweet_data$test_group == "A"]), 2), "minutes\n")

cat("\nGroup B (Harder) - Session Length:\n")
cat("  Mean:", round(mean(sweet_data$session_length_minutes[sweet_data$test_group == "B"]), 2), "minutes\n")
cat("  SD:", round(sd(sweet_data$session_length_minutes[sweet_data$test_group == "B"]), 2), "\n")
cat("  Range:", round(min(sweet_data$session_length_minutes[sweet_data$test_group == "B"]), 2), "-",
    round(max(sweet_data$session_length_minutes[sweet_data$test_group == "B"]), 2), "minutes\n")

cat("\n→ Your Q4 task: Test if this difference is statistically significant\n")
cat("→ Hint: Comparing MEANS between two groups → Use t-test\n\n")

# ================================================================
# PREVIEW: Q5 DATA (Level 20 Completion)
# ================================================================

cat("================================================================\n")
cat("Q5 PREVIEW: Level 20 Difficulty A/B Test\n")
cat("================================================================\n")

# Calculate completion rates
group_a_total <- sum(sweet_data$test_group == "A")
group_a_completed <- sum(sweet_data$test_group == "A" & sweet_data$level_20_completed == 1)
group_a_rate <- round(group_a_completed / group_a_total * 100, 1)

group_b_total <- sum(sweet_data$test_group == "B")
group_b_completed <- sum(sweet_data$test_group == "B" & sweet_data$level_20_completed == 1)
group_b_rate <- round(group_b_completed / group_b_total * 100, 1)

cat("\nGroup A (Easier Version):\n")
cat("  Attempts:", group_a_total, "\n")
cat("  Completions:", group_a_completed, "\n")
cat("  Failures:", group_a_total - group_a_completed, "\n")
cat("  Success Rate:", group_a_rate, "%\n")

cat("\nGroup B (Harder/Original Version):\n")
cat("  Attempts:", group_b_total, "\n")
cat("  Completions:", group_b_completed, "\n")
cat("  Failures:", group_b_total - group_b_completed, "\n")
cat("  Success Rate:", group_b_rate, "%\n")

cat("\n→ Your Q5 task: Should we lower the difficulty?\n")
cat("→ Hint: Comparing PROPORTIONS between two groups → Use Chi-squared test\n")
cat("→ Follow 6-step workflow in AB_Testing_Complete_Toolkit.md\n\n")

# ================================================================
# YOUR PRACTICE WORKSPACE
# ================================================================

cat("================================================================\n")
cat("YOUR PRACTICE WORKSPACE - START HERE\n")
cat("================================================================\n\n")

cat("Data is loaded in 'sweet_data' data frame.\n")
cat("Now proceed to complete Q4 and Q5 following the practice guide.\n\n")

cat("Columns available:\n")
cat("  - session_id\n")
cat("  - player_id\n")
cat("  - test_group (A or B)\n")
cat("  - session_length_minutes (for Q4)\n")
cat("  - level_20_completed (1=completed, 0=failed, for Q5)\n")
cat("  - session_date\n\n")

cat("================================================================\n")
cat("READY TO START PRACTICE!\n")
cat("================================================================\n\n")

cat("Next steps:\n")
cat("1. Open PRACTICE_ANSWERS.md to write your answers\n")
cat("2. Start with Q1-Q3 (25 minutes)\n")
cat("3. Then complete Q4 below (20 minutes)\n")
cat("4. Then complete Q5 below (45 minutes)\n\n")

cat("Timer: Set for 2 hours and begin!\n\n")

# ================================================================
# Q4 PRACTICE WORKSPACE (20 minutes)
# ================================================================

cat("\n")
cat("================================================================\n")
cat("Q4 WORKSPACE: Session Length Comparison\n")
cat("================================================================\n")
cat("Start Time: ____________\n")
cat("Target Time: 20 minutes\n\n")

cat("# STEP 1: Extract session lengths by group\n\n")

# Write your code here:




cat("\n# STEP 2: Choose statistical test\n")
cat("# Use Statistical_Testing_Decision_Tree.md\n")
cat("# Comparing: MEANS (session length)\n")
cat("# Groups: Two (A vs B)\n")
cat("# Test: t-test\n\n")

# Write your code here:




cat("\n# STEP 3: Run t-test\n\n")

# Write your code here:




cat("\n# STEP 4: Interpret results\n")
cat("# Extract p-value and write conclusion\n\n")

# Write your code here:




cat("\n# STEP 5: Write answer in PRACTICE_ANSWERS.md\n\n")


# ================================================================
# Q5 PRACTICE WORKSPACE (45 minutes)
# ================================================================

cat("\n")
cat("================================================================\n")
cat("Q5 WORKSPACE: A/B Testing - Level 20 Difficulty\n")
cat("================================================================\n")
cat("Start Time: ____________\n")
cat("Target Time: 45 minutes\n")
cat("Use: AB_Testing_Complete_Toolkit.md (6-step workflow)\n\n")

cat("# STEP 1: Understand the Problem (3 min)\n")
cat("# - What's being tested: Difficulty level\n")
cat("# - Groups: A = easier, B = harder (original)\n")
cat("# - Metric: Completion rate (proportion)\n")
cat("# - Question: Should we lower difficulty?\n\n")


cat("\n# STEP 2: Explore Data (5 min)\n\n")

# Write your code here:




cat("\n# STEP 3: Calculate Group Metrics (10 min)\n")
cat("# Install dplyr if needed: install.packages('dplyr')\n\n")

# Write your code here:
# library(dplyr)




cat("\n# STEP 4: Run Statistical Test (10 min)\n")
cat("# Chi-squared test for comparing proportions\n\n")

# Write your code here:




cat("\n# STEP 5: Interpret Results (5 min)\n")
cat("# Calculate business impact\n\n")

# Write your code here:




cat("\n# STEP 6: Make Recommendation (12 min)\n")
cat("# Write comprehensive answer in PRACTICE_ANSWERS.md\n")
cat("# Use template from AB_Testing_Complete_Toolkit.md\n\n")


# ================================================================
# PRACTICE SESSION COMPLETE
# ================================================================

cat("\n")
cat("================================================================\n")
cat("After completing Q4 and Q5 above:\n")
cat("================================================================\n")
cat("1. Check your timing - did you stay within limits?\n")
cat("2. Review PRACTICE_ANSWERS.md - are answers complete?\n")
cat("3. Self-assess using checklist in PRACTICE_ANSWERS.md\n")
cat("4. Identify gaps and review relevant materials\n")
cat("5. Prepare for tomorrow's exam!\n\n")

cat("Target Score: 7.5-8 points (83-89%)\n")
cat("You've got this! 🎯\n\n")
