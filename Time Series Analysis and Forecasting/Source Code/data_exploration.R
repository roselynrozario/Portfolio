# data_exploration.R

# Libraries
library(tidyverse)
library(lubridate)
library(ggplot2)
library(GGally)
library(readxl)
library(zoo)
library(reshape2)

# Load Data
load_data <- function(file_path) {
  
  data <- read_excel(file_path)
  
  # Print the First Few Rows to Check the Date and Time Format
  print(head(data))
  
  # Convert Date and Time Columns to datetime
  data <- data %>%
    mutate(
      Date = as.Date(Date, format = "%d/%m/%Y"),
      Time = format(as.POSIXct(Time, format = "%H.%M.%S"), "%H:%M:%S"),
      datetime = ymd_hms(paste(Date, Time))
    )
  
  # Handle Missing Values Represented by Specific Codes in Numeric Columns
  data <- data %>%
    mutate(across(where(is.numeric), ~na_if(., -200)))
  
  # Check the datetime Column
  print(head(data$datetime))
  
  return(data)
  
}

# Aggregate to Daily Data
aggregate_to_daily <- function(df) {
  
  df_daily <- df %>%
    group_by(date = as.Date(datetime)) %>%
    summarise(daily_avg_benzene = mean(`C6H6(GT)`, na.rm = TRUE))
  
  # Create a datetime Column for Compatibility
  df_daily <- df_daily %>%
    mutate(datetime = as.POSIXct(date))
  
  return(df_daily)
  
}

# Summarize Data
summarize_data <- function(df) {
  
  print(glimpse(df))
  print(summary(df))
  
}

# Count Missing Values
count_missing_values <- function(df) {
  
  missing_values <- df %>%
    summarise(across(everything(), ~ sum(is.na(.))))
  
  return(missing_values)
  
}

# Impute Missing Values Using Interpolation
impute_missing_values <- function(df) {
  
  df <- df %>%
    mutate(across(where(is.numeric), ~na.approx(., na.rm = FALSE)))
  return(df)
  
}


# Plot Correlations
plot_correlations <- function(df, columns) {
  
  df_corr <- df %>%
    select(all_of(columns))
  
  ggpairs(df_corr) + 
    labs(title = "Correlation Matrix")
  
}

# Plot Time Series
plot_time_series <- function(df, columns, title) {
  
  df_long <- df %>%
    select(datetime, all_of(columns)) %>%
    pivot_longer(cols = -datetime, names_to = "variable", values_to = "value")
  
  ggplot(df_long, aes(x = datetime, y = value, color = variable)) +
    geom_line() +
    labs(title = title, x = "Datetime", y = "Value") +
    theme_minimal()
  
}

# Data Distribution
data_distribution <- function(df, columns, title){
  
  df_long <- df %>%
    select(datetime, all_of(columns)) %>%
    pivot_longer(cols = -datetime, names_to = "variable", values_to = "value")
  
  ggplot(df_long, aes(x = value)) +
    geom_histogram(bins = 100) +
    facet_wrap(~variable, scales = "free") +
    theme_minimal() +
    labs(title = title, x = "Value", y = "Frequency")
  
}

# Perform and Plot Time Series Decomposition
plot_decomposition <- function(df, column, freq) {
  
  ts_data <- ts(df[[column]], frequency = freq)
  decomposed <- stl(ts_data, s.window = "periodic")
  
  # Plot the Decomposition
  plot(decomposed, main = paste("STL Decomposition of", column, "with frequency", freq))
  
}

# Decomposition - ALT
plot_decomposition_ggplot <- function(df, column, freq) {

  ts_data <- ts(df[[column]], frequency = freq)
  
  # Perform STL Decomposition
  decomposed <- stl(ts_data, s.window = "periodic")
  

  decomposed_df <- data.frame(
    Time = time(ts_data),
    Observed = as.numeric(ts_data),  # Original Data
    Seasonal = as.numeric(decomposed$time.series[, "seasonal"]),
    Trend = as.numeric(decomposed$time.series[, "trend"]),
    Remainder = as.numeric(decomposed$time.series[, "remainder"])
  )
  
  # Melt the Data
  decomposed_melted <- melt(decomposed_df, id.vars = "Time")
  
  # Plot
  ggplot(decomposed_melted, aes(x = Time, y = value, color = variable)) +
    geom_line() +
    facet_wrap(~ variable, scales = "free_y", ncol = 1) +
    labs(title = paste("STL Decomposition of Daily Average Benzene"),
         x = "Time", y = "Value") +
    theme_minimal()
  
}
