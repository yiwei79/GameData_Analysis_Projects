### Step 1: Open RStudio
1. Launch RStudio
2. **File → Open File**
3. Navigate to: `Analysis/exploratory_analysis.R`
4. **Session → Set Working Directory → To Source File Location**

### Step 2: Run Setup Code

Copy these lines into the R console (or run line-by-line with **Ctrl+Enter**):

```r
# Load packages
library(RMySQL)
library(ggplot2)
library(dplyr)

# Load configuration
source("config.R")
source("utils.R")

# Connect to database
con <- safe_connect(
  host = DB_CONFIG$host,
  dbname = DB_CONFIG$dbname,
  user = DB_CONFIG$user,
  password = DB_CONFIG$password
)

# Test connection
print("✅ Connected to database!")
```

### Step 3: Run Your First Query

```r
# Count users
total_users <- execute_query(con, "SELECT COUNT(*) as count FROM users")
print(paste("Total Users:", total_users$count))
# Output: Total Users: 1007
```

### Step 4: Create Your First Visualization

```r
# Get top countries
countries <- execute_query(con, "
  SELECT country, COUNT(*) as users
  FROM users
  GROUP BY country
  ORDER BY users DESC
  LIMIT 10
")

# Create chart
ggplot(countries, aes(x = reorder(country, users), y = users)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Countries by User Count",
    x = "Country",
    y = "Users"
  ) +
  theme_minimal()

# Save it
ggsave("my_first_chart.png", width = 10, height = 6, dpi = 300)
print("✅ Chart saved as my_first_chart.png!")
```

---

## Key Analyses

### Analysis 1: Calculate ARPU

```r
arpu <- execute_query(con, "
  SELECT 
    COUNT(DISTINCT u.user_id) as total_users,
    SUM(COALESCE(p.amount, 0)) as total_revenue,
    SUM(COALESCE(p.amount, 0)) / COUNT(DISTINCT u.user_id) as arpu
  FROM users u
  LEFT JOIN purchases p ON u.user_id = p.user_id
")

print(arpu)
# You should see: ARPU = $10.86
```

---

### Analysis 2: Revenue by Item

```r
items <- execute_query(con, "
  SELECT 
    i.item_name,
    i.price,
    COUNT(p.purchase_id) as purchases,
    SUM(p.amount) as revenue
  FROM purchases p
  JOIN items i ON p.item_id = i.item_id
  GROUP BY i.item_id, i.item_name, i.price
  ORDER BY revenue DESC
")

# View the data
View(items)

# Create chart
ggplot(items, aes(x = reorder(item_name, revenue), y = revenue, fill = item_name)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  geom_text(aes(label = paste0("$", round(revenue, 0))), hjust = -0.1) +
  labs(
    title = "Revenue by Item",
    subtitle = "Diamond Pack ($49.99) dominates with 62% of revenue",
    x = "",
    y = "Revenue ($)"
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  ylim(0, max(items$revenue) * 1.15)
```

---

### Analysis 3: D7 Retention

```r
retention <- execute_query(con, "
  SELECT 
    COUNT(DISTINCT user_id) as total_users,
    COUNT(DISTINCT CASE 
      WHEN user_id IN (
        SELECT DISTINCT s.user_id
        FROM sessions s
        JOIN users u ON s.user_id = u.user_id
        WHERE DATEDIFF(s.start_time, u.registration_date) BETWEEN 1 AND 7
      ) THEN user_id 
    END) as returned_d7,
    ROUND(COUNT(DISTINCT CASE 
      WHEN user_id IN (
        SELECT DISTINCT s.user_id
        FROM sessions s
        JOIN users u ON s.user_id = u.user_id
        WHERE DATEDIFF(s.start_time, u.registration_date) BETWEEN 1 AND 7
      ) THEN user_id 
    END) * 100.0 / COUNT(DISTINCT user_id), 2) as d7_pct
  FROM users
")

print(retention)
# Output: 661 of 1007 returned = 65.6% D7 retention!
```

---

### Analysis 4: Geographic ARPU

```r
geo <- execute_query(con, "
  SELECT 
    u.country,
    COUNT(DISTINCT u.user_id) as users,
    COUNT(DISTINCT CASE WHEN p.user_id IS NOT NULL THEN u.user_id END) as paying_users,
    COALESCE(SUM(p.amount), 0) as revenue,
    COALESCE(SUM(p.amount) / COUNT(DISTINCT u.user_id), 0) as arpu
  FROM users u
  LEFT JOIN purchases p ON u.user_id = p.user_id
  GROUP BY u.country
  HAVING users >= 5
  ORDER BY arpu DESC
  LIMIT 10
")

View(geo)
# Notice Suriname at $39.19 ARPU!

# Visualize
ggplot(geo, aes(x = reorder(country, arpu), y = arpu, fill = arpu)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient(low = "lightblue", high = "darkgreen") +
  coord_flip() +
  geom_text(aes(label = paste0("$", round(arpu, 2))), hjust = -0.1) +
  labs(
    title = "ARPU by Country (Top 10)",
    subtitle = "Suriname leads at $39.19 - 3.6x the average!",
    x = "Country",
    y = "ARPU ($)"
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  xlim(0, max(geo$arpu) * 1.2)
```

---

### Analysis 5: Daily Active Users Trend

```r
dau <- execute_query(con, "
  SELECT 
    DATE(start_time) as date,
    COUNT(DISTINCT user_id) as dau
  FROM sessions
  WHERE start_time IS NOT NULL
  GROUP BY DATE(start_time)
  ORDER BY date
")

# Calculate statistics
mean_dau <- mean(dau$dau)
ci <- calculate_ci(dau$dau)  # Uses utils.R function

# Plot
ggplot(dau, aes(x = as.Date(date), y = dau)) +
  geom_line(color = "steelblue", size = 1) +
  geom_smooth(method = "loess", se = TRUE, alpha = 0.2) +
  geom_hline(yintercept = mean_dau, linetype = "dashed", color = "red") +
  labs(
    title = "Daily Active Users (DAU) - Full Year 2022",
    subtitle = paste0("Mean: ", round(mean_dau, 1), " users [95% CI: ", 
                      round(ci$lower, 1), " - ", round(ci$upper, 1), "]"),
    x = "Date",
    y = "Active Users"
  ) +
  theme_minimal()
```

---

## 🎨 Customization Examples

### Change Colors

```r
# Use viridis color palette
library(viridis)

ggplot(geo, aes(x = reorder(country, arpu), y = arpu, fill = arpu)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis(option = "D") +  # Try A, B, C, D
  coord_flip() +
  theme_minimal()
```

### Add Data Labels

```r
ggplot(items, aes(x = reorder(item_name, revenue), y = revenue)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_text(aes(label = paste0("$", round(revenue, 0))), 
            hjust = -0.1, fontface = "bold") +
  coord_flip()
```

### Change Themes

```r
# Try different themes
theme_minimal()   # Clean
theme_classic()   # Traditional
theme_dark()      # Dark background
theme_bw()        # Black and white
```

---

## 📈 Statistical Analysis Examples

### Confidence Intervals

```r
# Manual calculation
data_vector <- dau$dau
mean_val <- mean(data_vector)
sd_val <- sd(data_vector)
n <- length(data_vector)
se <- sd_val / sqrt(n)
margin <- 1.96 * se  # 95% CI

ci_lower <- mean_val - margin
ci_upper <- mean_val + margin

print(paste("Mean:", round(mean_val, 2)))
print(paste("95% CI: [", round(ci_lower, 2), ",", round(ci_upper, 2), "]"))
```

### T-Test (Compare Two Groups)

```r
# Compare 18-25 vs 36-45 age groups
age_18_25 <- execute_query(con, "
  SELECT COALESCE(SUM(p.amount), 0) as revenue
  FROM users u
  LEFT JOIN purchases p ON u.user_id = p.user_id
  WHERE u.age BETWEEN 18 AND 25
  GROUP BY u.user_id
")

age_36_45 <- execute_query(con, "
  SELECT COALESCE(SUM(p.amount), 0) as revenue
  FROM users u
  LEFT JOIN purchases p ON u.user_id = p.user_id
  WHERE u.age BETWEEN 36 AND 45
  GROUP BY u.user_id
")

# Run t-test
result <- t.test(age_18_25$revenue, age_36_45$revenue)
print(result)

# Interpret
if (result$p.value < 0.05) {
  print("✅ SIGNIFICANT: Age groups spend differently!")
} else {
  print("❌ Not significant")
}
```

---

## 💾 Export

### Save Plots

```r
# Save current plot
ggsave("my_chart.png", width = 12, height = 8, dpi = 300)

# Save with specific dimensions
ggsave("wide_chart.png", width = 16, height = 6, dpi = 300)
ggsave("square_chart.png", width = 10, height = 10, dpi = 300)
```

### Export Data to CSV

```r
write.csv(geo, "my_geographic_analysis.csv", row.names = FALSE)
write.csv(items, "my_revenue_breakdown.csv", row.names = FALSE)
```

### Save Multiple Plots

```r
# Create a PDF with multiple charts
pdf("my_analysis_report.pdf", width = 11, height = 8.5)

# Chart 1
ggplot(countries, aes(x = reorder(country, users), y = users)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top Countries") +
  theme_minimal()

# Chart 2
ggplot(items, aes(x = reorder(item_name, revenue), y = revenue)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  coord_flip() +
  labs(title = "Revenue by Item") +
  theme_minimal()

dev.off()  # Close PDF
print("✅ PDF saved!")
```

---


## ❓ Common Issues

**Database won't connect?**
- Check `config.R` has correct credentials
- Verify you're connected to internet
- Try `print(DB_CONFIG)` to verify settings

**Plot looks wrong?**
- Check data with `View(your_data)`
- Try `print(your_data)` to see structure
- Ensure column names match in `aes()`

**Query returns nothing?**
- Test in SQL Workbench first
- Check table/column names
- Use `print()` to debug

---

