# Load required libraries
library(dplyr)
library(arrow)  # For saving and reading Parquet files

# Define thresholds
threshold_t20 <- 200   # Minimum balls faced in T20 matches
threshold_odi <- 500   # Minimum balls faced in ODI matches
combined_threshold <- 700  # Minimum balls faced across both formats

# Step 1: Filter players meeting individual and combined thresholds
filtered_data <- cleaned_data %>%
  filter(
    (match_type == "T20" & total_balls >= threshold_t20) | 
      (match_type == "ODI" & total_balls >= threshold_odi)
  ) %>%
  group_by(striker) %>%
  summarise(
    total_balls_faced = sum(total_balls),  # Total balls faced across formats
    .groups = "drop"
  ) %>%
  filter(total_balls_faced >= combined_threshold) %>%
  inner_join(cleaned_data, by = "striker")  # Rejoin the data to include strike rates

# Step 2: Calculate performance metrics for each player
# - Include average strike rates for T20 and ODI formats
average_strike_rate <- filtered_data %>%
  group_by(striker) %>%
  summarise(
    t20_strike_rate = round(mean(strike_rate[match_type == "T20"], na.rm = TRUE), 2),  # Average T20 strike rate
    odi_strike_rate = round(mean(strike_rate[match_type == "ODI"], na.rm = TRUE), 2),  # Average ODI strike rate
    total_balls_faced = sum(total_balls),  # Total balls faced across formats
    .groups = "drop"
  )

# Step 3: Rank players and assign player type
player_rankings <- average_strike_rate %>%
  arrange(desc((t20_strike_rate + odi_strike_rate) / 2)) %>%  # Rank by combined strike rates
  mutate(
    player_rank = row_number(),
    player_type = ifelse(player_rank <= 100, "Top 100", "Non-Top 100")  # Categorize players
  )

# Step 4: Finalize the data structure
# Merge player type information into the average_strike_rate dataset
final_data <- average_strike_rate %>%
  left_join(player_rankings %>% select(striker, player_type), by = "striker") %>%
  # Remove rows with NA in either T20 or ODI strike rates
  filter(!is.na(t20_strike_rate) & !is.na(odi_strike_rate))

# Save the final dataset
processed_data_dir <- "data/processed_data"
if (!dir.exists(processed_data_dir)) {
  dir.create(processed_data_dir, recursive = TRUE)
}

parquet_file_path <- file.path(processed_data_dir, "final_analysis_data.parquet")
write_parquet(final_data, parquet_file_path)

cat("Final cleaned data with NA values removed saved to '", parquet_file_path, "'.\n", sep = "")
