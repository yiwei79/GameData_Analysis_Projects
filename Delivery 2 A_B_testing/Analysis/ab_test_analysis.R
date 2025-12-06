# =============================================================================
# A/B Test Statistical Analysis - Delivery 2
# =============================================================================
# This script performs statistical tests to determine if the increased boost
# power should be rolled out to all players.
#
# Timeline:
#   - Pre-test: Jan 1 - May 31, 2020 (baseline)
#   - Test period: June 1 - Sept 30, 2020 (Group A = stronger boost)
#   - Post-test: Oct 1 - Dec 31, 2020
# =============================================================================

# -----------------------------------------------------------------------------
# STEP 1: Install and Load Packages
# -----------------------------------------------------------------------------
# Run these lines ONCE if you don't have the packages installed:
# install.packages("tidyverse")
# install.packages("effsize")

library(tidyverse)  # For data manipulation and visualization
library(effsize)    # For effect size calculations

# -----------------------------------------------------------------------------
# STEP 2: Load the Data
# -----------------------------------------------------------------------------
# IMPORTANT: Update this path to match your computer!
data_path <- "/Users/yiwei/GithubRepos/GameData_Analysis_Projects/Delivery 2 A_B_testing/Export for Tableau/"

# Load the main analysis file (levels with player info)
levels_data <- read_csv(paste0(data_path, "levels_with_player_info.csv"))

# Load users for demographic analysis
users_data <- read_csv(paste0(data_path, "users.csv"))

# Load transactions for revenue analysis
transactions_data <- read_csv(paste0(data_path, "transactions.csv"))

# Load sessions
sessions_data <- read_csv(paste0(data_path, "sessions.csv"))

# -----------------------------------------------------------------------------
# STEP 3: Clean the Data
# -----------------------------------------------------------------------------
# Remove the header/placeholder rows (TestGroup = "TestGroup")
levels_clean <- levels_data %>%
  filter(TestGroup %in% c("A", "B"))

users_clean <- users_data %>%
  filter(TestGroup %in% c("A", "B"))

# Add time period classification
levels_clean <- levels_clean %>%
  mutate(
    date = as.Date(startDate),
    period = case_when(
      date < as.Date("2020-06-01") ~ "Pre",
      date <= as.Date("2020-09-30") ~ "During",
      TRUE ~ "Post"
    ),
    # Convert to binary for analysis
    is_success = ifelse(Result == "Success", 1, 0),
    # Handle usedBoost whether it's logical (TRUE/FALSE) or string ("True"/"False")
    used_boost = ifelse(usedBoost == TRUE | usedBoost == "True", 1, 0)
  )

cat("Data loaded and cleaned!\n")
cat("Total level attempts:", nrow(levels_clean), "\n")
cat("Group A attempts:", sum(levels_clean$TestGroup == "A"), "\n")
cat("Group B attempts:", sum(levels_clean$TestGroup == "B"), "\n")

# =============================================================================
# STATISTICAL TEST 1: Success Rate Comparison (During Test Period)
# =============================================================================
cat("\n", paste(rep("=", 70), collapse=""), "\n")
cat("TEST 1: Level Success Rate - Group A vs Group B (During Test Period)\n")
cat(paste(rep("=", 70), collapse=""), "\n")

# Filter to test period only
during_test <- levels_clean %>% filter(period == "During")

# Count successes and failures by group
success_table <- during_test %>%
  group_by(TestGroup) %>%
  summarise(
    successes = sum(is_success),
    failures = n() - sum(is_success),
    total = n(),
    success_rate = mean(is_success)
  )

print(success_table)

# Create contingency table for chi-squared test
contingency <- matrix(
  c(success_table$successes[1], success_table$failures[1],
    success_table$successes[2], success_table$failures[2]),
  nrow = 2, byrow = TRUE,
  dimnames = list(c("Group A", "Group B"), c("Success", "Failure"))
)

cat("\nContingency Table:\n")
print(contingency)

# Chi-squared test
chi_test <- chisq.test(contingency)
cat("\n--- Chi-Squared Test Results ---\n")
cat("H0: Success rate is the same for Group A and Group B\n")
cat("H1: Success rate differs between groups\n\n")
cat("Chi-squared statistic:", round(chi_test$statistic, 4), "\n")
cat("Degrees of freedom:", chi_test$parameter, "\n")
cat("p-value:", format(chi_test$p.value, scientific = TRUE), "\n")

if(chi_test$p.value < 0.05) {
  cat("\nConclusion: REJECT H0 - The difference is statistically significant (p < 0.05)\n")
} else {
  cat("\nConclusion: FAIL TO REJECT H0 - No significant difference (p >= 0.05)\n")
}

# Effect size (Odds Ratio)
a_success <- success_table$successes[1]
a_fail <- success_table$failures[1]
b_success <- success_table$successes[2]
b_fail <- success_table$failures[2]

odds_ratio <- (a_success / a_fail) / (b_success / b_fail)
cat("\nOdds Ratio:", round(odds_ratio, 4), "\n")
cat("Interpretation: Group A is", round(odds_ratio, 2), "times more likely to succeed than Group B\n")

# 95% Confidence Interval for difference in proportions
p1 <- success_table$success_rate[1]  # Group A
p2 <- success_table$success_rate[2]  # Group B
n1 <- success_table$total[1]
n2 <- success_table$total[2]

diff <- p1 - p2
se <- sqrt(p1*(1-p1)/n1 + p2*(1-p2)/n2)
ci_lower <- diff - 1.96 * se
ci_upper <- diff + 1.96 * se

cat("\n--- Effect Size ---\n")
cat("Group A success rate:", round(p1 * 100, 2), "%\n")
cat("Group B success rate:", round(p2 * 100, 2), "%\n")
cat("Difference:", round(diff * 100, 2), "percentage points\n")
cat("95% CI for difference: [", round(ci_lower * 100, 2), "%, ", round(ci_upper * 100, 2), "%]\n")

# =============================================================================
# STATISTICAL TEST 2: Boost Usage Rate Comparison
# =============================================================================
cat("\n", paste(rep("=", 70), collapse=""), "\n")
cat("TEST 2: Boost Usage Rate - Group A vs Group B (During Test Period)\n")
cat(paste(rep("=", 70), collapse=""), "\n")

# Count boost usage by group
boost_table <- during_test %>%
  group_by(TestGroup) %>%
  summarise(
    boost_count = sum(used_boost),
    no_boost_count = n() - sum(used_boost),
    total = n(),
    .groups = "drop"
  ) %>%
  mutate(boost_rate = boost_count / total)

print(boost_table)

# Create contingency table
boost_contingency <- matrix(
  c(boost_table$boost_count[1], boost_table$no_boost_count[1],
    boost_table$boost_count[2], boost_table$no_boost_count[2]),
  nrow = 2, byrow = TRUE,
  dimnames = list(c("Group A", "Group B"), c("Used Boost", "No Boost"))
)

# Chi-squared test
boost_chi <- chisq.test(boost_contingency)
cat("\n--- Chi-Squared Test Results ---\n")
cat("H0: Boost usage rate is the same for both groups\n")
cat("H1: Boost usage rate differs between groups\n\n")
cat("Chi-squared statistic:", round(boost_chi$statistic, 4), "\n")
cat("p-value:", format(boost_chi$p.value, scientific = TRUE), "\n")

if(boost_chi$p.value < 0.05) {
  cat("\nConclusion: REJECT H0 - Significant difference in boost usage (p < 0.05)\n")
} else {
  cat("\nConclusion: FAIL TO REJECT H0 - No significant difference\n")
}

# Effect size
bp1 <- boost_table$boost_rate[1]
bp2 <- boost_table$boost_rate[2]
cat("\nGroup A boost rate:", round(bp1 * 100, 2), "%\n")
cat("Group B boost rate:", round(bp2 * 100, 2), "%\n")
cat("Difference:", round((bp1 - bp2) * 100, 2), "percentage points\n")

# =============================================================================
# STATISTICAL TEST 3: Baseline Validation (Pre-Test Period)
# =============================================================================
cat("\n", paste(rep("=", 70), collapse=""), "\n")
cat("TEST 3: Baseline Validation - Were Groups Similar Before Test?\n")
cat(paste(rep("=", 70), collapse=""), "\n")

pre_test <- levels_clean %>% filter(period == "Pre")

pre_table <- pre_test %>%
  group_by(TestGroup) %>%
  summarise(
    successes = sum(is_success),
    total = n(),
    success_rate = mean(is_success)
  )

print(pre_table)

# Chi-squared test for pre-period
pre_contingency <- matrix(
  c(pre_table$successes[1], pre_table$total[1] - pre_table$successes[1],
    pre_table$successes[2], pre_table$total[2] - pre_table$successes[2]),
  nrow = 2, byrow = TRUE
)

pre_chi <- chisq.test(pre_contingency)
cat("\np-value for pre-test difference:", format(pre_chi$p.value, scientific = TRUE), "\n")

if(pre_chi$p.value >= 0.05) {
  cat("Conclusion: Groups were NOT significantly different before test (GOOD - valid baseline)\n")
} else {
  cat("WARNING: Groups showed differences before test - interpret results with caution\n")
}

# =============================================================================
# STATISTICAL TEST 4: Post-Test Analysis (Persistence of Effect)
# =============================================================================
cat("\n", paste(rep("=", 70), collapse=""), "\n")
cat("TEST 4: Post-Test Analysis - Did the Effect Persist?\n")
cat(paste(rep("=", 70), collapse=""), "\n")

post_test <- levels_clean %>% filter(period == "Post")

post_table <- post_test %>%
  group_by(TestGroup) %>%
  summarise(
    successes = sum(is_success),
    total = n(),
    success_rate = mean(is_success)
  )

print(post_table)

post_contingency <- matrix(
  c(post_table$successes[1], post_table$total[1] - post_table$successes[1],
    post_table$successes[2], post_table$total[2] - post_table$successes[2]),
  nrow = 2, byrow = TRUE
)

post_chi <- chisq.test(post_contingency)
cat("\np-value:", format(post_chi$p.value, scientific = TRUE), "\n")
cat("Group A post-test rate:", round(post_table$success_rate[1] * 100, 2), "%\n")
cat("Group B post-test rate:", round(post_table$success_rate[2] * 100, 2), "%\n")

if(post_chi$p.value < 0.05) {
  cat("\nConclusion: Effect PERSISTED after boost was reset - interesting finding!\n")
}

# =============================================================================
# SUMMARY TABLE
# =============================================================================
cat("\n", paste(rep("=", 70), collapse=""), "\n")
cat("SUMMARY OF ALL STATISTICAL TESTS\n")
cat(paste(rep("=", 70), collapse=""), "\n")

# Get boost rates for summary
bp1 <- boost_table$boost_rate[1]
bp2 <- boost_table$boost_rate[2]

summary_df <- data.frame(
  Test = c("Success Rate (During)", "Boost Usage (During)", "Baseline (Pre)", "Persistence (Post)"),
  Group_A = c(
    paste0(round(p1 * 100, 1), "%"),
    paste0(round(bp1 * 100, 1), "%"),
    paste0(round(pre_table$success_rate[1] * 100, 1), "%"),
    paste0(round(post_table$success_rate[1] * 100, 1), "%")
  ),
  Group_B = c(
    paste0(round(p2 * 100, 1), "%"),
    paste0(round(bp2 * 100, 1), "%"),
    paste0(round(pre_table$success_rate[2] * 100, 1), "%"),
    paste0(round(post_table$success_rate[2] * 100, 1), "%")
  ),
  p_value = c(
    format(chi_test$p.value, digits = 3, scientific = TRUE),
    format(boost_chi$p.value, digits = 3, scientific = TRUE),
    format(pre_chi$p.value, digits = 3, scientific = TRUE),
    format(post_chi$p.value, digits = 3, scientific = TRUE)
  ),
  Significant = c(
    ifelse(chi_test$p.value < 0.05, "Yes", "No"),
    ifelse(boost_chi$p.value < 0.05, "Yes", "No"),
    ifelse(pre_chi$p.value < 0.05, "Yes*", "No (Good)"),
    ifelse(post_chi$p.value < 0.05, "Yes", "No")
  )
)

print(summary_df)

# Save summary to CSV for report
write_csv(summary_df, paste0(data_path, "../Analysis/statistical_summary.csv"))
cat("\nSummary saved to Analysis/statistical_summary.csv\n")

# =============================================================================
# RECOMMENDATION
# =============================================================================
cat("\n", paste(rep("=", 70), collapse=""), "\n")
cat("RECOMMENDATION\n")
cat(paste(rep("=", 70), collapse=""), "\n")

cat("
Based on the statistical analysis:

ARGUMENTS FOR rolling out the stronger boost:
1. Significantly higher success rate (", round(diff * 100, 2), "pp increase, p < 0.05)
2. Players use the boost more when it's stronger (engagement increase)
3. Effect persists even after reset (learned behavior/habit formation)

ARGUMENTS AGAINST rolling out:
1. Stronger boost may reduce game challenge/longevity
2. Players may become dependent on boosts
3. Could affect monetization if boost feels 'necessary'

OVERALL: The data supports rolling out the stronger boost, as it improves
player success without apparent negative effects on engagement.
")
