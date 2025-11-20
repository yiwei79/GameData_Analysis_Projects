# Load the button A/B test data
data <- read.csv("Size.csv", 
                 sep = "\t",           # Tab-separated
                 dec = ",",            # European decimal (comma)
                 stringsAsFactors = TRUE)

# First 6 rows
head(data)

# Last 6 rows
tail(data)

# Structure
str(data)

# Summary statistics
summary(data)

# How many in each group?
table(data$Size)

# Mean (average) clicks per group
aggregate(ClicksPerSession ~ Size, data = data, FUN = mean)

# Standard deviation (spread)
aggregate(ClicksPerSession ~ Size, data = data, FUN = sd)

# Professional boxplot
boxplot(ClicksPerSession ~ Size, data = data,
        main = "Button Size A vs B: Clicks Per Session",
        xlab = "Button Size",
        ylab = "Clicks Per Session",
        col = c("lightblue", "lightcoral"),
        border = "darkgray")

# Size by size histograms
par(mfrow = c(1, 2)) # 1 row, 2 columns

hist(data$ClicksPerSession[data$Size == "A"],
     main = "Button Size A",
     xlab = "Clicks Per Session",
     col = "lightblue",
     breaks = 30)

hist(data$ClicksPerSession[data$Size == "B"],
     main = "Button Size B",
     xlab = "Clicks Per Session",
     col = "lightcoral",
     breaks = 30)

par(mfrow = c(1,1)) # Rest to single plot

#The main statistical test
t_test_result <- t.test(ClicksPerSession ~ Size, data = data)

# View results
print(t_test_result)
# Output: 
# p-value < 2.2e-16, group A mean = 0.4988552,
# group B mean = 0.4494415
# --------------------------------------------------------------------

# Check significance
if (t_test_result$p.value < 0.05) {
  cat("SIGNIFICANT! Button A and B are different.\n")
  cat("P-value:", t_test_result$p.value, "\n")
}

# CALCULATE EFFECT SIZE

# Extract values
mean_A <- mean(data$ClicksPerSession[data$Size == "A"])
mean_B <- mean(data$ClicksPerSession[data$Size == "B"])
n_A <- sum(data$Size == "A")
n_B <- sum(data$Size == "B")
sd_A <- sd(data$ClicksPerSession[data$Size == "A"])
sd_B <- sd(data$ClicksPerSession[data$Size == "B"])

#Pooled standard deviation
pooled_sd <- sqrt(((n_A - 1) * sd_A^2 + (n_B - 1) * sd_B^2) / (n_A + n_B - 2))

# Cohen's d (effect size)
cohens_d <- (mean_A - mean_B) / pooled_sd

cat("Cohen's d:", round(cohens_d, 3), "\n")

# Interpret
if (abs(cohens_d) < 0.2) {
  cat("Effect size: NEGLIGIBLE\n")
} else if (abs(cohens_d) < 0.5) {
  cat("Effect size: SMALL\n")
} else if (abs(cohens_d) < 0.8) {
  cat("Effect size: MEDIUM\n")
} else {
  cat("Effect size: LARGE\n")
}

# CALCULATE PRACTICAL DIFFERENCE
# Percentage difference
percent_diff <- ((mean_A - mean_B) / mean_B) * 100

cat("\n==========================================\n")
cat("FINAL RESULTS SUMMARY\n")
cat("==========================================\n")
cat("Button A mean:", round(mean_A, 4), "\n")
cat("Button B mean:", round(mean_B, 4), "\n")
cat("Absolute difference:", round(mean_A - mean_B, 4), "\n")
cat("Percentage difference:", round(percent_diff, 2), "%\n")
cat("P-value:", format(t_test_result$p.value, scientific = FALSE), "\n")
cat("Cohen's d:", round(cohens_d, 3), "\n")

# APPLY DECISION FRAMEWORK
cat("\nDECISION CHECKLIST:\n")

# 1. Statistical significance
cat("1. P-value < 0.05? ")
if (t_test_result$p.value < 0.05) {
  cat("YES ✓\n")
} else {
  cat("NO ✗\n")
}

# 2. Effect size
cat("2. Cohen's d > 0.5? ")
if (abs(cohens_d) > 0.5) {
  cat("YES ✓\n")
} else {
  cat("NO ✗\n")
}

# 3. Practical significance
cat("3. Percentage diff > 5%? ")
if (abs(percent_diff) > 5) {
  cat("YES ✓\n")
} else {
  cat("NO ✗\n")
}

cat("\n==========================================\n")
cat("FINAL RECOMMENDATION:\n")
cat("==========================================\n")

if (t_test_result$p.value < 0.05 && abs(cohens_d) > 0.5 && abs(percent_diff) > 5) {
  if (mean_A > mean_B) {
    cat("★ IMPLEMENT BUTTON SIZE A\n")
    cat("It clearly outperforms Button B.\n")
  } else {
    cat("★ IMPLEMENT BUTTON SIZE B\n")
    cat("It clearly outperforms Button A.\n")
  }
} else if (t_test_result$p.value < 0.05) {
  cat("⚠ STATISTICALLY SIGNIFICANT BUT SMALL EFFECT\n")
  cat("Difference is real but small. Consider other factors.\n")
} else {
  cat("→ NO CLEAR WINNER\n")
  cat("Insufficient evidence of a difference.\n")
}

# Save your plot
png("button_ab_test_boxplot.png", width = 800, height = 600)
boxplot(ClicksPerSession ~ Size, data = data,
        main = "Button Size A vs B",
        col = c("lightblue", "lightcoral"))
dev.off()

cat("Plot saved as: button_ab_test_boxplot.png\n")
cat("==========================================\n")