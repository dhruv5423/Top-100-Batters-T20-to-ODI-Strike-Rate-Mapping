# Load required libraries
library(testthat)
library(dplyr)
library(arrow)

# Load the cleaned dataset (read-only)
processed_data_dir <- "data/processed_data"
parquet_file_path <- file.path(processed_data_dir, "final_analysis_data.parquet")
test_data <- read_parquet(parquet_file_path)

# Copy the data into a new object for testing (no changes will affect the original file)
testing_data <- test_data

# Define test thresholds
threshold_t20 <- 200   # Minimum balls faced in T20 matches
threshold_odi <- 500   # Minimum balls faced in ODI matches
combined_threshold <- 700  # Minimum balls faced across both formats

# Start test suite
test_that("Final dataset structure is correct", {
  # Check if required columns exist
  expected_columns <- c("striker", "t20_strike_rate", "odi_strike_rate", "total_balls_faced", "player_type")
  expect_true(all(expected_columns %in% colnames(testing_data)), "All required columns must be present")
  
  # Check column types using `expect_type` for numeric and character columns
  expect_type(testing_data$t20_strike_rate, "double")
  expect_type(testing_data$odi_strike_rate, "double")
  expect_true(is.numeric(testing_data$total_balls_faced), "Total balls faced must be numeric (integer or double)")
  expect_type(testing_data$player_type, "character")
})

test_that("Final dataset meets data thresholds", {
  # Validate T20 and ODI thresholds
  expect_true(all(testing_data$t20_strike_rate >= 0, na.rm = TRUE), "T20 strike rates must be non-negative")
  expect_true(all(testing_data$odi_strike_rate >= 0, na.rm = TRUE), "ODI strike rates must be non-negative")
  expect_true(all(testing_data$total_balls_faced >= combined_threshold, na.rm = TRUE), "Players must meet combined threshold for balls faced")
})

test_that("Player categorization is accurate", {
  # Check for valid player_type values
  expect_true(all(testing_data$player_type %in% c("Top 100", "Non-Top 100")), "Player type must be 'Top 100' or 'Non-Top 100'")
  
  # Validate top 100 rankings
  top_100_players <- testing_data %>%
    filter(player_type == "Top 100") %>%
    arrange(desc((t20_strike_rate + odi_strike_rate) / 2)) %>%
    mutate(player_rank = row_number())
  
  expect_true(all(top_100_players$player_rank <= 100), "Top 100 players must have valid ranks")
})

test_that("Data integrity is maintained", {
  # Check for NA values
  expect_false(any(is.na(testing_data$t20_strike_rate)), "T20 strike rate must not contain NA values")
  expect_false(any(is.na(testing_data$odi_strike_rate)), "ODI strike rate must not contain NA values")
  
  # Verify no duplicate rows
  expect_true(nrow(testing_data) == nrow(distinct(testing_data)), "No duplicate rows should exist")
  
  # Ensure numerical columns are rounded to 2 decimal places
  expect_true(all(testing_data$t20_strike_rate == round(testing_data$t20_strike_rate, 2)), "T20 strike rate must be rounded to 2 decimal places")
  expect_true(all(testing_data$odi_strike_rate == round(testing_data$odi_strike_rate, 2)), "ODI strike rate must be rounded to 2 decimal places")
})

test_that("Statistical checks", {
  # Ensure averages make sense
  average_t20 <- mean(testing_data$t20_strike_rate, na.rm = TRUE)
  average_odi <- mean(testing_data$odi_strike_rate, na.rm = TRUE)
  expect_true(average_t20 > 0, "Average T20 strike rate must be positive")
  expect_true(average_odi > 0, "Average ODI strike rate must be positive")
  
  # Validate relationship between T20 and ODI strike rates for top players
  correlation <- cor(testing_data$t20_strike_rate, testing_data$odi_strike_rate, use = "complete.obs")
  expect_true(correlation > 0.5, "There should be a moderate to strong positive correlation between T20 and ODI strike rates")
})
