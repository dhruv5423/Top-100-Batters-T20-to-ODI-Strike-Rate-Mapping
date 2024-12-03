# Load required library
library(dplyr)

# Ensure the directories exist
simulated_data_dir <- "data/simulated_data"
if (!dir.exists(simulated_data_dir)) {
  dir.create(simulated_data_dir, recursive = TRUE)
}

# Function to simulate one innings of a cricket match
simulate_innings <- function(overs, batting_team, bowling_team, players, better_players = NULL) {
  # Create a template for ball-by-ball data
  balls_per_over <- 6
  total_balls <- overs * balls_per_over
  
  # Initialize variables
  match_id <- 1
  innings <- 1
  striker <- players[1]
  non_striker <- players[2]
  bowler <- players[11]
  batting_order <- players[3:length(players)]
  current_batting_order <- 3  # Next player to come in
  
  # Simulate each ball
  innings_data <- data.frame(
    match_id = integer(total_balls),
    innings = integer(total_balls),
    ball = numeric(total_balls),
    batting_team = character(total_balls),
    bowling_team = character(total_balls),
    striker = character(total_balls),
    non_striker = character(total_balls),
    bowler = character(total_balls),
    runs_off_bat = integer(total_balls),
    extras = integer(total_balls),
    wides = integer(total_balls),
    noballs = integer(total_balls),
    byes = integer(total_balls),
    legbyes = integer(total_balls),
    penalty = integer(total_balls),
    wicket_type = character(total_balls),
    player_dismissed = character(total_balls),
    stringsAsFactors = FALSE
  )
  
  # Probabilities for "regular players"
  regular_run_distribution <- c(0, 1, 2, 3, 4, 6)
  regular_run_probs <- c(0.4, 0.3, 0.1, 0.05, 0.1, 0.05)
  regular_dismissal_prob <- 0.03
  regular_extra_prob <- 0.1
  
  # Probabilities for "better players"
  better_run_distribution <- c(0, 1, 2, 3, 4, 6)
  better_run_probs <- c(0.3, 0.3, 0.15, 0.05, 0.15, 0.05)  # Higher chance of boundaries
  better_dismissal_prob <- 0.015  # Lower dismissal chance
  better_extra_prob <- 0.05  # Lower chance of extras
  
  for (i in 1:total_balls) {
    # Calculate ball number
    over <- floor((i - 1) / balls_per_over) + 1
    ball_in_over <- (i - 1) %% balls_per_over + 1
    ball_number <- over + ball_in_over / 10
    
    # Determine if the current striker is a "better player"
    if (striker %in% better_players) {
      run_distribution <- better_run_distribution
      run_probs <- better_run_probs
      dismissal_prob <- better_dismissal_prob
      extra_prob <- better_extra_prob
    } else {
      run_distribution <- regular_run_distribution
      run_probs <- regular_run_probs
      dismissal_prob <- regular_dismissal_prob
      extra_prob <- regular_extra_prob
    }
    
    # Populate ball data
    innings_data$match_id[i] <- match_id
    innings_data$innings[i] <- innings
    innings_data$ball[i] <- ball_number
    innings_data$batting_team[i] <- batting_team
    innings_data$bowling_team[i] <- bowling_team
    innings_data$striker[i] <- striker
    innings_data$non_striker[i] <- non_striker
    innings_data$bowler[i] <- bowler
    
    # Simulate runs
    if (runif(1) < extra_prob) {
      innings_data$extras[i] <- sample(c(1, 2), 1)  # Wides or no-balls
      innings_data$wides[i] <- sample(c(0, 1), 1)
      innings_data$noballs[i] <- sample(c(0, 1), 1)
    } else {
      innings_data$runs_off_bat[i] <- sample(run_distribution, 1, prob = run_probs)
    }
    
    # Simulate dismissals
    if (runif(1) < dismissal_prob) {
      innings_data$wicket_type[i] <- sample(c("caught", "bowled", "lbw", "run out"), 1)
      innings_data$player_dismissed[i] <- striker
      striker <- batting_order[current_batting_order]  # New batsman comes in
      current_batting_order <- current_batting_order + 1
    }
    
    # Rotate strike
    if (innings_data$runs_off_bat[i] %% 2 == 1) {
      temp <- striker
      striker <- non_striker
      non_striker <- temp
    }
  }
  
  return(innings_data)
}

# Function to simulate one match
simulate_match <- function(overs, teams, better_players) {
  team1 <- teams[1]
  team2 <- teams[2]
  
  # Simulate first innings
  innings1 <- simulate_innings(overs, team1, team2, paste0("Player ", 1:11), better_players)
  
  # Simulate second innings
  innings2 <- simulate_innings(overs, team2, team1, paste0("Player ", 12:22), better_players)
  
  # Combine both innings
  match_data <- bind_rows(innings1, innings2)
  
  return(match_data)
}

# Define better players
better_players <- c("Player 2", "Player 5", "Player 7", "Player 14", "Player 19")

# Simulate an ODI match (50 overs)
odi_match <- simulate_match(50, c("Team A", "Team B"), better_players)

# Simulate a T20 match (20 overs)
t20_match <- simulate_match(20, c("Team C", "Team D"), better_players)

# Save datasets to the simulated_data folder
write.csv(odi_match, file.path(simulated_data_dir, "odi_match_simulated_better.csv"), row.names = FALSE)
write.csv(t20_match, file.path(simulated_data_dir, "t20_match_simulated_better.csv"), row.names = FALSE)

# Simulate player stats
simulate_player_stats <- function(match_data) {
  player_stats <- match_data %>%
    group_by(striker) %>%
    summarize(
      runs = sum(runs_off_bat, na.rm = TRUE),
      balls_faced = n(),
      strike_rate = ifelse(balls_faced > 0, runs / balls_faced * 100, 0)
    )
  return(player_stats)
}

# Generate player statistics
odi_player_stats <- simulate_player_stats(odi_match)
t20_player_stats <- simulate_player_stats(t20_match)

# Save player stats to the simulated_data folder
write.csv(odi_player_stats, file.path(simulated_data_dir, "odi_player_stats_simulated_better.csv"), row.names = FALSE)
write.csv(t20_player_stats, file.path(simulated_data_dir, "t20_player_stats_simulated_better.csv"), row.names = FALSE)

cat("Simulation complete with better players. All datasets saved in", simulated_data_dir, "\n")

