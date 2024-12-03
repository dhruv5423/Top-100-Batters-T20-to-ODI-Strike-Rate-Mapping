# Load necessary libraries
library(lme4)
library(dplyr)
library(arrow)

# Load the dataset
data_path <- "data/processed_data/final_analysis_data.parquet"  # Adjusted to the correct path
model_data <- read_parquet(data_path)

# Ensure correct data types for categorical variables
model_data <- model_data %>%
  mutate(
    player_type_binary = ifelse(player_type == "Top 100", 1, 0)  # Convert player_type to binary
  )

# Check if player has multiple observations
player_obs_count <- model_data %>%
  group_by(striker) %>%
  summarise(n = n())

# Simplified model without random effects if players have only one observation
strike_rate_model <- lm(
  formula = odi_strike_rate ~ t20_strike_rate + player_type_binary + t20_strike_rate:player_type_binary,
  data = model_data
)

# Display the model summary
summary(strike_rate_model)

# Save the fitted model as an RDS file
model_output_path <- "models/strike_rate_model_simple.rds"
if (!dir.exists("models")) {
  dir.create("models", recursive = TRUE)
}
saveRDS(strike_rate_model, model_output_path)

cat("Simplified linear model saved to:", model_output_path, "\n")
