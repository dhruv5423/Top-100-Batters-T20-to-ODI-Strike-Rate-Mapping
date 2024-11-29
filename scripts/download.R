# Load required libraries
library(jsonlite)
library(data.table)

# Define directories
json_dir <- "data/Raw_JSON_Files"  # Directory with the .json files
output_dir <- "data/Sampled_JSON"  # Directory to save sampled .json files

# Ensure output directory exists
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Function to sample a large .json file
sample_large_json <- function(input_file, output_file, sample_size = 1e6, chunk_size = 5000) {
  # Open the .json file for streaming
  con <- file(input_file, "r")
  
  # Initialize an empty data.table to store the sample
  sampled_data <- NULL
  
  # Initialize a counter for chunks
  chunk_count <- 0
  
  # Read the JSON file in chunks and randomly sample
  while (TRUE) {
    # Read a chunk of data
    chunk <- tryCatch({
      stream_in(con, pagesize = chunk_size, verbose = FALSE)
    }, error = function(e) {
      return(NULL)  # End of file or error
    })
    
    # If no more data, break the loop
    if (is.null(chunk) || nrow(chunk) == 0) {
      break
    }
    
    # Convert chunk to data.table
    chunk <- as.data.table(chunk)
    
    # Append to sampled_data with random sampling
    if (is.null(sampled_data)) {
      sampled_data <- chunk[sample(.N, min(.N, sample_size))]
    } else {
      sampled_data <- rbind(sampled_data, chunk[sample(.N, min(.N, sample_size - nrow(sampled_data)))])
    }
    
    # Increment chunk counter and print progress
    chunk_count <- chunk_count + 1
    cat("Processed chunk", chunk_count, "- Total sampled rows so far:", nrow(sampled_data), "\n")
    
    # Stop if we’ve reached the sample size
    if (nrow(sampled_data) >= sample_size) {
      cat("Reached sample size of", sample_size, "rows. Stopping early.\n")
      break
    }
  }
  
  # Close the connection
  close(con)
  
  # Save the sampled data as a .json file
  write_json(as.list(sampled_data), output_file, pretty = TRUE)
  
  # Return the number of sampled rows
  return(nrow(sampled_data))
}

# Define input and output files
datasets <- list(
  list(
    input_file = file.path(json_dir, "goodreads_interactions_fantasy_paranormal.json"),
    output_file = file.path(output_dir, "fantasy_sample.json")
  ),
  list(
    input_file = file.path(json_dir, "goodreads_interactions_history_biography.json"),
    output_file = file.path(output_dir, "history_sample.json")
  ),
  list(
    input_file = file.path(json_dir, "goodreads_interactions_romance.json"),
    output_file = file.path(output_dir, "romance_sample.json")
  )
)

# Process each dataset
for (dataset in datasets) {
  cat("Processing", dataset$input_file, "...\n")
  sampled_rows <- sample_large_json(
    input_file = dataset$input_file,
    output_file = dataset$output_file,
    sample_size = 1e6,   # Sample 1 million entries
    chunk_size = 5000    # Process data in chunks of 5,000 rows
  )
  cat("Sampled", sampled_rows, "rows and saved to:", dataset$output_file, "\n")
}

