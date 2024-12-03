# Load necessary library
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
library(dplyr)

# Define paths to the folders containing the CSV files
odis_folder <- "data/raw_data/odis_male_csv2"
t20s_folder <- "data/raw_data/t20s_male_csv2"

# Function to read and combine all CSV files in a folder, excluding "_info" files
combine_csv_files <- function(folder_path) {
  # List all CSV files in the folder
  csv_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)
  
  # Exclude files with "_info" in their name
  csv_files <- csv_files[!grepl("_info", csv_files)]
  
  # Read each CSV file and combine them into one data frame
  combined_data <- lapply(csv_files, function(file) {
    data <- read.csv(file, row.names = NULL, check.names = FALSE)
    
    # Standardize column types if necessary (e.g., season to character)
    if ("season" %in% colnames(data)) {
      data$season <- as.character(data$season)
    }
    
    return(data)
  }) %>%
    bind_rows()  # Combine all data frames
  
  return(combined_data)
}

# Combine ODI data
cat("Combining ODI CSV files...\n")
odi_data <- combine_csv_files(odis_folder)
cat("ODI data successfully combined!\n")

# Combine T20 data
cat("Combining T20 CSV files...\n")
t20_data <- combine_csv_files(t20s_folder)
cat("T20 data successfully combined!\n")

# Ensure the processed data folder exists
processed_data_dir <- "data/processed_data"
if (!dir.exists(processed_data_dir)) {
  dir.create(processed_data_dir, recursive = TRUE)
}

# Save the combined data frames as new CSV files
write.csv(odi_data, file.path(processed_data_dir, "combined_odi_data.csv"), row.names = FALSE)
write.csv(t20_data, file.path(processed_data_dir, "combined_t20_data.csv"), row.names = FALSE)

cat("Combined datasets saved to 'data/processed_data/' folder.\n")
