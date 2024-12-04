# Top 100 Batters T20 to ODI Strike Rate Mapping

## Overview
This repository contains all the necessary files, scripts, and data for the project "Top-100 Batters: T20 to ODI Strike Rate Mapping". The paper investigates how strike rates translate across T20 and ODI cricket formats for top-performing players and their peers. The dataset and associated analyses focus on player adaptability across formats using statistical modeling.

**`data/raw_data`**: Contains the raw ball-by-ball data files for T20 and ODI matches, downloaded from [CricSheet](https://cricsheet.org/).
- **`data/processed_data`**: Contains the cleaned and processed datasets, including:
  - `final_analysis_data.parquet`: The main dataset used for statistical analysis.
  - Combined T20 and ODI data in cleaned CSV format.
- **`model`**: Stores the linear regression model used in the paper.
- **`other`**: Includes supplementary files such as relevant literature, LLM chat interaction details, project sketches, and the datashet
- **`paper`**: Contains the `paper.qmd` file and reference bibliography (`references.bib`) for generating the PDF version of the paper.
- **`scripts`**: R scripts used for downloading, cleaning, and analyzing the data:
  - `download_combine.R`: Script for downloading and combining raw data.
  - `clean.R`: Script for cleaning and preprocessing raw data.
  - `model.R`: Script for creating the model, saved as an .rds file in `model`
  - `test.R`: contains tests on the cleaned dataset
  - `simulate.R` contains simulations for the data
 
## LLM Usage

Portions of this project were assisted by large language models (LLMs). Specifically:
- ChatGPT 4o was used to assist in drafting sections of the paper, discussing methodology, and generating code snippets for visualizations and model diagnostics.
- The complete chat history of LLM interactions is documented in `other/llms/usage.txt`.
