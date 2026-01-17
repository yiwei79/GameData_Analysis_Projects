# ================================================================
# Test Script: Verify Improved R Templates
# ================================================================
# Tests Chi-squared METHOD 2 and t-test METHOD 2 with actual data
# ================================================================

cat("================================================================\n")
cat("TESTING IMPROVED R STATISTICAL LIBRARY TEMPLATES\n")
cat("================================================================\n\n")

# Load required library
library(dplyr)

# Load data
setwd("/Users/yiwei/GithubRepos/GameData_Analysis_Projects/Final Exam Prep")
data <- read.csv("data.csv", header = TRUE)

cat("Data loaded successfully!\n")
cat("Rows:", nrow(data), "Columns:", ncol(data), "\n")
cat("Columns:", paste(colnames(data), collapse = ", "), "\n\n")

# ================================================================
# TEST 1: Chi-Squared METHOD 2 (Q5 - Level 20 Completion)
# ================================================================

cat("================================================================\n")
cat("TEST 1: CHI-SQUARED METHOD 2 (Level 20 Completion)\n")
cat("================================================================\n")

# Create contingency table from dataframe
contingency_table <- table(data$test_group, data$level_20_completed)

# Label dimensions (makes output clearer)
names(dimnames(contingency_table)) <- c("Group", "Outcome")

# ALWAYS print table to verify before testing
cat("\n=== Contingency Table ===\n")
print(contingency_table)

# Run chi-squared test
chi_result <- chisq.test(contingency_table)

# Print full results
print(chi_result)

# Extract and display key values
p_value <- chi_result$p.value
chi_statistic <- chi_result$statistic
df <- chi_result$parameter  # degrees of freedom

cat("\n--- Chi-Squared Test Results ---\n")
cat("Chi-squared statistic (χ²):", round(chi_statistic, 4), "\n")
cat("Degrees of freedom:", df, "\n")
cat("p-value:", format(p_value, scientific = TRUE), "\n")

# Calculate success rates from contingency table
# Assuming column 2 = success (1), column 1 = failure (0)
group_a_success <- contingency_table[1, 2]
group_a_total <- sum(contingency_table[1, ])
group_b_success <- contingency_table[2, 2]
group_b_total <- sum(contingency_table[2, ])

group_a_rate <- group_a_success / group_a_total
group_b_rate <- group_b_success / group_b_total

cat("\n--- Success Rates ---\n")
cat("Group A:", group_a_success, "/", group_a_total,
    "=", round(group_a_rate * 100, 2), "%\n")
cat("Group B:", group_b_success, "/", group_b_total,
    "=", round(group_b_rate * 100, 2), "%\n")
cat("Absolute difference:", round((group_a_rate - group_b_rate) * 100, 2), "percentage points\n")
cat("Relative improvement:", round((group_a_rate - group_b_rate) / group_b_rate * 100, 2), "%\n")

# Calculate effect size (Cramér's V)
n <- sum(contingency_table)
cramer_v <- sqrt(chi_statistic / n)
cat("\n--- Effect Size ---\n")
cat("Cramér's V:", round(cramer_v, 4), "\n")
cat("Interpretation: ", ifelse(cramer_v < 0.1, "Small",
                           ifelse(cramer_v < 0.3, "Medium", "Large")), " effect\n")

# Interpret result
if (p_value < 0.05) {
    cat("\n✓ RESULT: SIGNIFICANT (p < 0.05)\n")
    cat("Interpretation: Reject null hypothesis\n")
    cat("Conclusion: There IS a statistically significant difference between groups\n")
} else {
    cat("\n✗ RESULT: NOT SIGNIFICANT (p >= 0.05)\n")
    cat("Interpretation: Fail to reject null hypothesis\n")
    cat("Conclusion: No statistically significant difference between groups\n")
}

# === COPY THIS FOR YOUR EXAM ANSWER ===
cat("\n=== FOR YOUR EXAM ANSWER ===\n")
cat("Statistical Test: Chi-squared test\n")
cat("χ² =", round(chi_statistic, 2), ", df =", df, ", p-value =", format(p_value, scientific = FALSE, digits = 4), "\n")
cat("Group A rate:", round(group_a_rate * 100, 1), "% vs Group B rate:", round(group_b_rate * 100, 1), "%\n")
cat("Difference:", round((group_a_rate - group_b_rate) * 100, 1), "percentage points\n")
cat("Conclusion:", ifelse(p_value < 0.05, "Significant difference", "No significant difference"), "\n")

# ================================================================
# TEST 2: t-Test METHOD 2 (Q4 - Session Length)
# ================================================================

cat("\n\n================================================================\n")
cat("TEST 2: t-TEST METHOD 2 (Session Length Comparison)\n")
cat("================================================================\n")

t_result <- t.test(session_length_minutes ~ test_group, data = data)

# Print full results
print(t_result)

# Extract key values
p_value <- t_result$p.value
mean_a <- t_result$estimate[1]
mean_b <- t_result$estimate[2]
t_statistic <- t_result$statistic
df <- t_result$parameter
conf_int <- t_result$conf.int

# Display results clearly
cat("\n--- t-Test Results ---\n")
cat("t-statistic:", round(t_statistic, 3), "\n")
cat("Degrees of freedom:", round(df, 1), "\n")
cat("p-value:", format(p_value, scientific = TRUE), "\n")
cat("\n--- Group Means ---\n")
cat("Group A mean:", round(mean_a, 2), "\n")
cat("Group B mean:", round(mean_b, 2), "\n")
cat("Difference:", round(mean_a - mean_b, 2), "\n")
cat("95% CI for difference: [", round(conf_int[1], 2), ",", round(conf_int[2], 2), "]\n")

# Calculate effect size (Cohen's d)
group_a <- data$session_length_minutes[data$test_group == "A"]
group_b <- data$session_length_minutes[data$test_group == "B"]
pooled_sd <- sqrt((sd(group_a)^2 + sd(group_b)^2) / 2)
cohens_d <- (mean_a - mean_b) / pooled_sd

cat("\n--- Effect Size ---\n")
cat("Cohen's d:", round(cohens_d, 3), "\n")
cat("Interpretation: ", ifelse(abs(cohens_d) < 0.2, "Small",
                           ifelse(abs(cohens_d) < 0.8, "Medium", "Large")), " effect\n")

# Interpret
if (p_value < 0.05) {
    cat("\n✓ RESULT: SIGNIFICANT (p < 0.05)\n")
    cat("Conclusion: The difference in means is statistically significant\n")
} else {
    cat("\n✗ RESULT: NOT SIGNIFICANT (p >= 0.05)\n")
    cat("Conclusion: The difference in means is not statistically significant\n")
}

# === COPY THIS FOR YOUR EXAM ANSWER ===
cat("\n=== FOR YOUR EXAM ANSWER ===\n")
cat("Statistical Test: Independent t-test\n")
cat("t =", round(t_statistic, 2), ", df =", round(df, 1), ", p-value =", format(p_value, scientific = FALSE, digits = 4), "\n")
cat("Group A mean:", round(mean_a, 2), "vs Group B mean:", round(mean_b, 2), "\n")
cat("Difference:", round(mean_a - mean_b, 2), "(95% CI: [", round(conf_int[1], 2), ",", round(conf_int[2], 2), "])\n")
cat("Conclusion:", ifelse(p_value < 0.05, "Significant difference", "No significant difference"), "\n")

# ================================================================
# TEST COMPLETE
# ================================================================

cat("\n\n================================================================\n")
cat("✓ ALL TESTS COMPLETED SUCCESSFULLY!\n")
cat("================================================================\n\n")

cat("Summary:\n")
cat("- Chi-squared METHOD 2: Displays comprehensive output with effect size ✓\n")
cat("- t-test METHOD 2: Displays comprehensive output with Cohen's d ✓\n")
cat("- Both templates use actual column names (test_group, level_20_completed, session_length_minutes) ✓\n")
cat("- 'FOR YOUR EXAM ANSWER' sections provide copy-paste ready text ✓\n\n")

cat("Your improved R library is ready for tomorrow's exam!\n")
