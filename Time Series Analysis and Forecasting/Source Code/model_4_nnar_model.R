# nnar_model.R

# Libraries
library(forecast)
library(ggplot2)

# Create NNAR Model
create_nnar_model <- function(ts_data ) {
  
  # Fit the NNAR Model
  nnar_model <- nnetar(ts_data)
  print(nnar_model)
  return(nnar_model)
  
}

# Forecast Using the NNAR Model
forecast_nnar <- function(nnar_model, forecast_horizon = 25) {
  
  # Forecast the Next 'forecast_horizon' Days Using the NNAR Model
  forecast_values <- forecast(nnar_model, h = forecast_horizon)
  return(forecast_values)
  
}

# Plot NNAR
plot_nnar_forecast <- function(forecast_values, train_data, test_data) {
  
  autoplot(train_data, series = "Historical (Train)") +
    autolayer(test_data, series = "Historical (Test)") +
    autolayer(forecast_values, series = "Forecast") +
    labs(title = "NNAR Model Forecast vs Historical Data",
         x = "Date", y = "Benzene Concentration") +
    theme_minimal() +
    theme(legend.title = element_blank()) 
  
}

# Residuals Test
residuals_test <- function(residuals){
  
  ljung_box_test <- Box.test(residuals, lag = 7, type = "Ljung-Box")
  print(ljung_box_test)
  # p-value > than 0.05: Fail to Reject the Null Hypothesis ==> Residuals Do Not Show Significant Autocorrelation (They Are Likely White Noise)
  
  # Shapiro Test
  shapiro_test_result <- shapiro.test(residuals)
  print(shapiro_test_result)
  # p-value > 0.05: Do NOT Reject the Null Hypothesis ==> Data Is Consistent With a Normal Distribution
  
  qqnorm(residuals)
  qqline(residuals, col = "red")
  
}

# Metrics
evaluation_metrics <- function(actual_values, forecast_values){
  
  actual_values <- actual_values
  forecasted_values <- forecast_values
  
  # MRE
  relative_errors <- abs((forecasted_values - actual_values) / actual_values)
  
  mre <- mean(relative_errors, na.rm = TRUE)
  
  print(paste("MRE:",mre))
  
  # MAE
  absolute_errors <- abs(forecasted_values - actual_values)
  
  mae <- mean(absolute_errors)
  
  print(paste("MAE:",mae))
  
  # MSE
  squared_errors <- (forecasted_values - actual_values) ^ 2
  
  mse <- mean(squared_errors)
  
  print(paste("MSE:",mse))
  
  # RMSE
  rmse <- sqrt(mse)
  
  print(paste("RMSE:",rmse))
  
}
