# data_preprocessing.R

# Libraries
library(tidyverse)
library(lubridate)
library(caret)
library(tseries)

source("../src/experimental_analysis.R")

# Plot Time Series
plot_time_series <- function(df, columns, title) {
  
  ggplot(df, aes(x = datetime, y = daily_avg_benzene)) +
    geom_line(color = "blue") +
    labs(title = "title",
         x = "Date",
         y = "Daily Average Benzene") +
    theme_minimal()
  
}

# Feature Engineering
feature_engineering <- function(df) {
  
  # Add an Interaction Term Between Temperature and Relative Humidity if Needed
  df <- df %>%
    mutate(temp_humidity_interaction = T * RH)
  return(df)
  
}

# Split Data into Training and Testing Sets
split_data <- function(df, split_datetime) {
  
  train_data <- df %>% filter(datetime < split_datetime)
  test_data <- df %>% filter(datetime >= split_datetime)
  return(list(train = train_data, test = test_data))
  
}

# Select Columns to Save
select_columns <- function(df, columns) {
  
  df <- df %>% select(all_of(columns))
  return(df)
  
}

# Save Clean Dataset
save_clean_dataset <- function(df, file_path) {
  
  write_csv(df, file_path)
  
}
