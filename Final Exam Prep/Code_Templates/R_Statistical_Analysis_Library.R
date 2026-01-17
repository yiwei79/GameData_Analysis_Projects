# ================================================================
# R Statistical Analysis Library for Data Analysis Exam
# ================================================================
# Purpose: Copy-paste ready R code for Q4 and Q5
# Use: Adapt code by changing variable names and data sources
# ================================================================

# ================================================================
# SETUP: Load Required Libraries
# ================================================================

# Install packages if needed (run once before exam):
# install.packages("RMySQL")
# install.packages("dplyr")
# install.packages("ggplot2")

# Load libraries
library(RMySQL)      # For MySQL database connection
library(dplyr)       # For data manipulation (filter, group_by, summarize)
library(ggplot2)     # For visualization

# ================================================================
# QUICK REFERENCE: Which Test to Use?
# ================================================================
#
# | What You're Comparing           | Test to Use           | Template # |
# |---------------------------------|-----------------------|------------|
# | Success rates / proportions     | Chi-squared test      | Template 4 |
# | (e.g., completion rate A vs B)  | OR Proportion test    | Template 5 |
# |                                 |                       |            |
# | Means / averages                | Independent t-test    | Template 6 |
# | (e.g., session length A vs B)   |                       |            |
# |                                 |                       |            |
# | Before/after in same group      | Paired t-test         | (add new)  |
# |                                 |                       |            |
# | More than 2 groups              | ANOVA                 | (add new)  |
# |                                 |                       |            |
#
# KEY DECISION TREE:
# 1. Comparing proportions/percentages (success rate, %, 0/1 data)?
#    → Use CHI-SQUARED TEST (Template 4)
#
# 2. Comparing means/averages (session length, revenue, continuous data)?
#    → Use t-TEST (Template 6)
#
# 3. p-value < 0.05? → SIGNIFICANT (reject null hypothesis)
#    p-value >= 0.05? → NOT SIGNIFICANT (fail to reject null)
#
# ================================================================

# ================================================================
# COLUMN NAMES: Practice Data vs Generic Templates
# ================================================================
#
# YOUR PRACTICE DATA (sweet_data.csv) has these columns:
# - test_group              (Group A or B)
# - level_20_completed      (1 = completed, 0 = failed)
# - session_length_minutes  (continuous values)
#
# GENERIC TEMPLATES (METHOD 1) use placeholder names:
# - group     → Replace with: test_group
# - success   → Replace with: level_20_completed
# - metric    → Replace with: session_length_minutes
#
# METHOD 2 TEMPLATES use ACTUAL column names from sweet_data.csv
# → You can copy-paste METHOD 2 code directly!
#
# ================================================================

# ================================================================
# TEMPLATE 1: Load Data from MySQL Database
# ================================================================

# Connect to MySQL database
con <- dbConnect(MySQL(),
                 user = "your_username",       # Change to your username
                 password = "your_password",   # Change to your password
                 dbname = "your_database",     # Change to your database name
                 host = "localhost")           # Usually localhost

# Run query and load data into R
query <- "SELECT * FROM your_table"  # Change query as needed
data <- dbGetQuery(con, query)

# Always disconnect when done
dbDisconnect(con)

# ================================================================
# TEMPLATE 2: Load Data from CSV File
# ================================================================

# If exam provides a CSV file (like sweet.sql)
data <- read.csv("sweet.sql", header = TRUE)

# For CSV in different directory
data <- read.csv("/path/to/your/file.csv", header = TRUE)

# ================================================================
# TEMPLATE 3: Quick Data Exploration
# ================================================================

# View first 6 rows
head(data)

# View structure (column names, data types)
str(data)

# Summary statistics for all columns
summary(data)

# Check dimensions (rows, columns)
dim(data)
cat("Rows:", nrow(data), "Columns:", ncol(data), "\n")

# Check for missing values
sum(is.na(data))
colSums(is.na(data))  # Missing values per column

# Check unique values in a column
table(data$group)  # Replace 'group' with actual column name
unique(data$column_name)

# ================================================================
# TEMPLATE 4: Chi-Squared Test (For Proportions/Categories)
# ================================================================
# USE WHEN: Comparing success rates, completion rates, conversion rates
# EXAMPLE: Group A success rate vs Group B success rate
# ================================================================

# ----- METHOD 1: When you have success/failure counts -----

# Example data:
group_a_success <- 280
group_a_failure <- 720
group_b_success <- 220
group_b_failure <- 780

# Create contingency table
# Format:
#           Success  Failure
# Group A      280      720
# Group B      220      780

contingency_table <- matrix(
    c(group_a_success, group_a_failure,
      group_b_success, group_b_failure),
    nrow = 2,
    byrow = TRUE
)

# Label rows and columns (helpful for reading results)
rownames(contingency_table) <- c("Group_A", "Group_B")
colnames(contingency_table) <- c("Success", "Failure")

# ALWAYS print table to verify before testing
print("Contingency Table:")
print(contingency_table)

# Run chi-squared test
chi_result <- chisq.test(contingency_table)

# Print full results
print(chi_result)

# Extract and display key values
p_value <- chi_result$p.value
chi_statistic <- chi_result$statistic

cat("\n--- Chi-Squared Test Results ---\n")
cat("Chi-squared statistic:", round(chi_statistic, 4), "\n")
cat("p-value:", p_value, "\n")

# Interpret result
if (p_value < 0.05) {
    cat("\nRESULT: SIGNIFICANT (p < 0.05)\n")
    cat("Interpretation: Reject null hypothesis\n")
    cat("Conclusion: There IS a statistically significant difference between groups\n")
} else {
    cat("\nRESULT: NOT SIGNIFICANT (p >= 0.05)\n")
    cat("Interpretation: Fail to reject null hypothesis\n")
    cat("Conclusion: No statistically significant difference between groups\n")
}

# Calculate and display success rates
group_a_rate <- group_a_success / (group_a_success + group_a_failure)
group_b_rate <- group_b_success / (group_b_success + group_b_failure)

cat("\n--- Success Rates ---\n")
cat("Group A success rate:", round(group_a_rate * 100, 2), "%\n")
cat("Group B success rate:", round(group_b_rate * 100, 2), "%\n")
cat("Absolute difference:", round((group_a_rate - group_b_rate) * 100, 2), "percentage points\n")
cat("Relative improvement:", round((group_a_rate - group_b_rate) / group_b_rate * 100, 2), "%\n")


# ----- METHOD 2: When you have dataframe with group and outcome columns -----

# Example: data has 'test_group' column (A or B) and 'level_20_completed' column (0 or 1)

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
# TEMPLATE 5: Proportion Test (Alternative to Chi-Squared)
# ================================================================
# USE WHEN: Directly comparing two proportions
# GIVES: Confidence interval for difference between proportions
# ================================================================

# Example data
group_a_success <- 280
group_a_total <- 1000
group_b_success <- 220
group_b_total <- 1000

# Run proportion test
prop_result <- prop.test(
    x = c(group_a_success, group_b_success),  # Number of successes in each group
    n = c(group_a_total, group_b_total)       # Total trials in each group
)

# Print results
print(prop_result)

# Extract key values
p_value <- prop_result$p.value
conf_int <- prop_result$conf.int

cat("\n--- Proportion Test Results ---\n")
cat("p-value:", p_value, "\n")
cat("95% Confidence Interval for difference:", round(conf_int[1], 4), "to", round(conf_int[2], 4), "\n")

# Interpret
if (p_value < 0.05) {
    cat("RESULT: Significant difference between proportions\n")
} else {
    cat("RESULT: No significant difference between proportions\n")
}


# ================================================================
# TEMPLATE 6: Independent t-Test (For Comparing Means)
# ================================================================
# USE WHEN: Comparing average session length, average revenue, etc.
# EXAMPLE: Average session length in Group A vs Group B
# ================================================================

# ----- METHOD 1: Two separate vectors -----

# Example data (replace with your actual data)
group_a_sessions <- c(20, 25, 30, 22, 28, 35, 18, 24, 26, 29)
group_b_sessions <- c(15, 18, 20, 17, 16, 22, 19, 21, 17, 20)

# Run independent samples t-test
t_result <- t.test(group_a_sessions, group_b_sessions)

# Print full results
print(t_result)

# Extract key values
p_value <- t_result$p.value
mean_a <- t_result$estimate[1]
mean_b <- t_result$estimate[2]
conf_int <- t_result$conf.int

# Display results
cat("\n--- t-Test Results ---\n")
cat("Group A mean:", round(mean_a, 2), "\n")
cat("Group B mean:", round(mean_b, 2), "\n")
cat("Difference:", round(mean_a - mean_b, 2), "\n")
cat("p-value:", p_value, "\n")
cat("95% CI for difference:", round(conf_int[1], 2), "to", round(conf_int[2], 2), "\n")

# Interpret
if (p_value < 0.05) {
    cat("\nRESULT: SIGNIFICANT (p < 0.05)\n")
    cat("Conclusion: The difference in means is statistically significant\n")
} else {
    cat("\nRESULT: NOT SIGNIFICANT (p >= 0.05)\n")
    cat("Conclusion: The difference in means is not statistically significant\n")
}


# ----- METHOD 2: From dataframe with group column -----

# If data has 'test_group' column and 'session_length_minutes' column
# Example: data$test_group = c("A", "A", "B", "B", ...)
#          data$session_length_minutes = c(20, 25, 15, 18, ...)

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
# TEMPLATE 7: Summary Statistics by Group (dplyr)
# ================================================================
# USE: Calculate metrics for each group before statistical testing
# ================================================================

library(dplyr)

# For PROPORTIONS (success rates, etc.)
group_summary <- data %>%
    group_by(group) %>%
    summarize(
        n = n(),                                # Total count
        successes = sum(success == 1),          # Replace 'success' with your column
        failures = sum(success == 0),
        success_rate = mean(success) * 100      # Percentage
    )

print(group_summary)


# For MEANS (session length, revenue, etc.)
group_means <- data %>%
    group_by(group) %>%
    summarize(
        n = n(),
        mean_value = mean(metric, na.rm = TRUE),   # Replace 'metric' with your column
        sd_value = sd(metric, na.rm = TRUE),
        median_value = median(metric, na.rm = TRUE),
        min_value = min(metric, na.rm = TRUE),
        max_value = max(metric, na.rm = TRUE)
    )

print(group_means)


# ================================================================
# TEMPLATE 8: Confidence Interval Calculation (Manual)
# ================================================================
# USE: Calculate 95% confidence interval for a single mean
# ================================================================

# Example data
data_vector <- c(20, 25, 30, 22, 28, 35, 18, 24, 26, 29)

# Calculate statistics
mean_val <- mean(data_vector)
sd_val <- sd(data_vector)
n <- length(data_vector)
se <- sd_val / sqrt(n)                      # Standard error

# Calculate 95% CI using t-distribution
t_critical <- qt(0.975, df = n - 1)         # t-value for 95% CI
margin <- t_critical * se                   # Margin of error
ci_lower <- mean_val - margin
ci_upper <- mean_val + margin

# Display results
cat("\n--- Confidence Interval ---\n")
cat("Mean:", round(mean_val, 2), "\n")
cat("Standard Deviation:", round(sd_val, 2), "\n")
cat("Standard Error:", round(se, 2), "\n")
cat("95% CI: [", round(ci_lower, 2), ",", round(ci_upper, 2), "]\n")


# ================================================================
# TEMPLATE 9: Data Filtering and Manipulation
# ================================================================

library(dplyr)

# Filter rows
group_a_data <- data %>% filter(group == "A")
group_b_data <- data %>% filter(group == "B")

# Filter by multiple conditions
filtered_data <- data %>%
    filter(group == "A" & success == 1)

# Select specific columns
selected_data <- data %>%
    select(group, success, session_length)

# Create new columns
data <- data %>%
    mutate(
        success_binary = ifelse(success == 1, "Success", "Failure"),
        session_minutes = session_length / 60
    )

# Arrange (sort) data
sorted_data <- data %>%
    arrange(desc(success_rate))


# ================================================================
# TEMPLATE 10: Quick Visualization (Bar Chart)
# ================================================================

library(ggplot2)

# Example: Comparing success rates between groups
comparison_data <- data.frame(
    Group = c("A", "B"),
    Success_Rate = c(28.0, 22.0)  # Replace with your actual values
)

# Create bar chart
ggplot(comparison_data, aes(x = Group, y = Success_Rate, fill = Group)) +
    geom_bar(stat = "identity") +
    labs(
        title = "Success Rate Comparison",
        x = "Group",
        y = "Success Rate (%)"
    ) +
    theme_minimal() +
    geom_text(aes(label = paste0(round(Success_Rate, 1), "%")),
              vjust = -0.5, size = 5) +
    ylim(0, max(comparison_data$Success_Rate) * 1.1)

# Save plot (optional)
ggsave("comparison_plot.png", width = 8, height = 6)


# ================================================================
# TEMPLATE 11: Comprehensive A/B Test Analysis Script
# ================================================================
# USE: Complete workflow for Question 5
# ================================================================

# Step 1: Load data
data <- read.csv("sweet.sql", header = TRUE)

# Step 2: Explore data
cat("=== Data Exploration ===\n")
cat("Dimensions:", nrow(data), "rows,", ncol(data), "columns\n")
cat("Group sizes:\n")
print(table(data$group))

# Step 3: Calculate group metrics
group_summary <- data %>%
    group_by(group) %>%
    summarize(
        n = n(),
        successes = sum(success == 1),
        failures = sum(success == 0),
        success_rate = mean(success) * 100
    )

cat("\n=== Group Summary ===\n")
print(group_summary)

# Step 4: Create contingency table
group_a <- group_summary %>% filter(group == "A")
group_b <- group_summary %>% filter(group == "B")

contingency_table <- matrix(
    c(group_a$successes, group_a$failures,
      group_b$successes, group_b$failures),
    nrow = 2,
    byrow = TRUE
)
rownames(contingency_table) <- c("Group_A", "Group_B")
colnames(contingency_table) <- c("Success", "Failure")

cat("\n=== Contingency Table ===\n")
print(contingency_table)

# Step 5: Run chi-squared test
chi_result <- chisq.test(contingency_table)

cat("\n=== Chi-Squared Test Results ===\n")
print(chi_result)

# Step 6: Interpret results
p_value <- chi_result$p.value
difference <- group_a$success_rate - group_b$success_rate

cat("\n=== INTERPRETATION ===\n")
cat("Group A success rate:", round(group_a$success_rate, 2), "%\n")
cat("Group B success rate:", round(group_b$success_rate, 2), "%\n")
cat("Absolute difference:", round(difference, 2), "percentage points\n")
cat("Relative improvement:", round(difference / group_b$success_rate * 100, 2), "%\n")
cat("p-value:", p_value, "\n")

if (p_value < 0.05) {
    cat("\n✓ SIGNIFICANT: The difference is statistically significant (p < 0.05)\n")
    cat("Decision: Reject null hypothesis - there IS a real difference between groups\n")
} else {
    cat("\n✗ NOT SIGNIFICANT: The difference is not statistically significant (p >= 0.05)\n")
    cat("Decision: Fail to reject null hypothesis - no strong evidence of difference\n")
}


# ================================================================
# COMMON R ERRORS AND FIXES
# ================================================================

# Error: "object 'data' not found"
# Fix: Make sure you loaded the data first (read.csv or dbGetQuery)

# Error: "could not find function 'filter'"
# Fix: Load dplyr library: library(dplyr)

# Error: "could not find function 'ggplot'"
# Fix: Load ggplot2 library: library(ggplot2)

# Error: "non-numeric argument to binary operator"
# Fix: Check that your column is numeric: class(data$column_name)
#      Convert if needed: data$column_name <- as.numeric(data$column_name)

# Error: "missing values in object"
# Fix: Use na.rm = TRUE in functions:
#      mean(data$column, na.rm = TRUE)
#      sd(data$column, na.rm = TRUE)

# Error: "subscript out of bounds"
# Fix: Check dataframe dimensions: dim(data)
#      Check column names: colnames(data)

# Error: "object of type 'closure' is not subsettable"
# Fix: You're trying to subset a function instead of data
#      Make sure variable name doesn't conflict with function name


# ================================================================
# EXAM EFFICIENCY TIPS
# ================================================================

# 1. ALWAYS check data structure first
str(data)
head(data)

# 2. Print intermediate results to verify
print(contingency_table)
print(group_summary)

# 3. Use clear variable names
p_value <- chi_result$p.value  # Better than: p <- chi$p

# 4. Comment your code for partial credit
# Calculate success rate for Group A
group_a_rate <- group_a$successes / (group_a$successes + group_a$failures)

# 5. Save key results to show in answer
p_value <- 0.0014
effect_size <- 6.0
cat("p-value:", p_value, "Effect size:", effect_size, "percentage points\n")

# 6. Use cat() for formatted output (better for grading)
cat("Group A success rate:", round(group_a_rate * 100, 2), "%\n")
# Better than: print(group_a_rate)

# 7. Keep a "results summary" comment block for your answer
# === RESULTS SUMMARY FOR ANSWER ===
# Group A: 28% success (280/1000)
# Group B: 22% success (220/1000)
# Difference: 6 percentage points
# Chi-squared: χ² = 10.23, p = 0.0014
# Conclusion: SIGNIFICANT - implement change
# ==========================================


# ================================================================
# FINAL CHECKLIST BEFORE SUBMITTING
# ================================================================

# [ ] Data loaded successfully
# [ ] Group sizes checked and reasonable
# [ ] Correct statistical test chosen
# [ ] Contingency table or summary printed and verified
# [ ] p-value clearly stated
# [ ] Effect size calculated
# [ ] Result interpreted correctly (significant or not)
# [ ] Business recommendation stated clearly


# ================================================================
# END OF LIBRARY
# ================================================================

cat("\nR Statistical Analysis Library loaded successfully!\n")
cat("Use Ctrl+F to search for templates by number or keyword.\n")
cat("Example: Search for 'TEMPLATE 4' or 'chi-squared'\n")
