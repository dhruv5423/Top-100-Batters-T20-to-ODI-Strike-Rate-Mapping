# Load required library
if (!requireNamespace("cricketdata", quietly = TRUE)) {
  install.packages("cricketdata")  # Install cricketdata
}
library(cricketdata)

# Define a directory to save the raw data
raw_data_dir <- "data/raw_data"
if (!dir.exists(raw_data_dir)) {
  dir.create(raw_data_dir, recursive = TRUE)
}

# Function to save raw datasets
save_raw_data <- function(data, filename) {
  file_path <- file.path(raw_data_dir, filename)
  write.csv(data, file_path, row.names = FALSE)
  cat("Saved", filename, "to", file_path, "\n")
}

# Fetch player-level data
cat("Downloading player-level data...\n")
player_stats <- fetch_cricsheet(type = "player", gender = "male")

# Save player-level data to raw_data folder
save_raw_data(player_stats, "player_stats.csv")

# Fetch ball-by-ball data for T20 matches
cat("Downloading T20 ball-by-ball data...\n")
t20_bbb <- fetch_cricsheet(type = "bbb", gender = "male")

# Save T20 ball-by-ball data
save_raw_data(t20_bbb, "t20_ball_by_ball.csv")

# Fetch ball-by-ball data for ODI matches
cat("Downloading ODI ball-by-ball data...\n")
odi_bbb <- fetch_cricsheet(type = "bbb", gender = "male")

# Save ODI ball-by-ball data
save_raw_data(odi_bbb, "odi_ball_by_ball.csv")

cat("All datasets downloaded and saved to", raw_data_dir, "\n")

