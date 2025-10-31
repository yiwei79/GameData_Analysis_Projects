# My First R Analysis
# Date: [2025-10-30]
# Purpose: Learning R with button click data

# load the data
data <- read_delim("SizeAndCentrality.csv",
                   delim = ";",
                   locale = locale(decimal_mark = ","))

#My first plot: Button size cs clicks
plot(data$size, data$`clicks per user`,
     main = "My First R Plot!",
     xlab = "Button Size",
     ylab = "Click per User",
     col = "blue",
     pch = 19)

#calculate average clicks
average_clicks <- mean(data$`clicks per user`)
print(paste("Average clicks per user:", round(average_clicks, 2)))

#Find the correlation
correlation <- cor(data$size, data$`clicks per user`)
print(paste("Correlation between size and clicks:", round(correlation, 3)))
      
#Beautiful scatter plot with ggplot2
ggplot(data, aes(x = size, y = `clicks per user`)) +
  geom_point(color = "steelblue", size = 3, alpha = 0.6) +
  geom_smooth(method = "lm", color = "red", se = TRUE) +
  labs(title = "Button Size vs User Clicks",
       subtitle = "Analyzing the relationship between size and engagement",
       x = "Button Size",
       y = "Clicks per User") +
  theme_minimal()
#Save this plot
ggsave("my_first_beautiful_plot.png", width = 8, height = 6)

#Linear regression: How does size affect clicks?
model <- lm(`clicks per user` ~ size, data = data)
summary(model)

#Plot with regression line
plot(data$size, data$`clicks per user`,
     main = "Button Size Predicts Clicks",
     xlab = "Button Size",
     ylab = "Clicks per User")
abline(model, col = "red", lwd = 2)

#Save Key findings
findings <- data.frame(
  Metric = c("Average Clicks", "Size-Click Correlation", "R-squared"),
  Value = c(mean(data$`clicks per user`),
            cor(data$size, data$`clicks per user`),
            summary(model)$r.squared)
)

write.csv(findings, "my_analysis_results.csv", row.names = FALSE)
print("Analysis complete! Results saved.")



      