# experimental_analysis.R

# Libraries
library(tidyverse)
library(forecast)
library(ggplot2)
library(TSA)
library(tseries)

# Plot Time Series
plot_time_series <- function(df, columns, title) {
  
  ggplot(df, aes(x = datetime, y = daily_avg_benzene)) +
    geom_line(color = "blue") +
    labs(title = "title",
         x = "Date",
         y = "Daily Average Benzene") +
    theme_minimal()
  
}

# Plot ACF
plot_acf <- function(df, column, title) {
  
  ggAcf(df[[column]], main = paste("ACF of", title)) +
    theme_minimal()
  
}

# Plot PACF
plot_pacf <- function(df, column, title) {
  
  ggPacf(df[[column]], main = paste("PACF of", title)) + 
    theme_minimal()
  
}

# Conduct Hypothesis Testing
conduct_hypothesis_testing <- function(df, column) {
  
  adf_test <- adf.test(df[[column]], alternative = "stationary")
  kpss_test <- kpss.test(df[[column]], null = "Level")
  list(adf_test = adf_test, kpss_test = kpss_test)
  
}