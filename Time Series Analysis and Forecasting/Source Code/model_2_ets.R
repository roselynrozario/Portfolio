# ets_model.R

# Libraries
library(forecast)
library(ggplot2)

# Forecast Using the ETS Model
forecast_ets <- function(model, forecast_horizon = 25) {
  
  # Forecast the Next 'forecast_horizon' Days Using the ETS Model
  forecast_values <- forecast(model, h = forecast_horizon)
  return(forecast_values)
  
}

# Plot ETS
plot_ets_forecast <- function(forecast_values, train_data, test_data) {
  
  autoplot(train_data, series = "Historical (Train)") +
    autolayer(test_data, series = "Historical (Test)") +
    autolayer(forecast_values, series = "Forecast") +
    labs(title = "ETS Model Forecast vs Historical Data",
         x = "Date", y = "Benzene Concentration") +
    theme_minimal() +
    theme(legend.title = element_blank()) 
  
}

# Best ETS Loop
auto_ets <- function(ts_data){
  
  best_ets_model <- ets(ts_data)
  summary(best_ets_model)
  
}

# ETS Loop
loop_ets <- function(ts_data){
  
  errors <- c("A", "M")
  trends <- c("N", "A", "M")
  seasonals <- c("N", "A", "M")
  
  expand.grid(errors = c("A", "M"), trends = c("N", "A", "M"), seasonals = c("N", "A", "M"))
  
  orders <- expand.grid(errors = c("A", "M"), trends = c("N", "A", "M"), seasonals = c("N", "A", "M"))
  
  models <- list()
  mse_values <- numeric()
  
  for (i in 1:nrow(orders)) {
    model_config <- paste0(orders[i, ]$errors,orders[i, ]$trends,orders[i, ]$seasonals)
    
    if (model_config != "AMN" && model_config != "AMN" && model_config != "AMA" && model_config != "MMA" && model_config != "ANM" && model_config != "AAM" && model_config != "AMM"){
      
      ets_model <- ets(ts_data, model = model_config)  
      
      models[[i]] <- ets_model
      mse_values[i] <- ets_model$aicc
      
    }
  }
  
  best_model_index <- which.min(mse_values)
  best_model <- models[[best_model_index]]
  
  print(best_model)
  
  return(best_model)
  
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
