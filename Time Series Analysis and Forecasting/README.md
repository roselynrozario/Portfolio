<h1 align="center"> Air Quality Trends </h1>

**Team 1**  
**Final Project**  
**Time Series Analysis and Forecasting**


### Objective
The project will identify peak gas concentration times to predict future air quality trends, aiming to curb the negative impacts of poor air quality on human life.

### Dataset
The dataset examines gas concentrations in an Italian city, measured via a gas multi-sensor device from March 2004 to February 2005.

> [Dataset Link](https://archive.ics.uci.edu/dataset/360/air+quality)

#### Dataset Characteristics
- **Type**: Multivariate, Time-Series
- **Feature Type**: Real
- **Instances**: 9358
- **Features**: 15

### Project Structure
```plaintext
Time Series Analysis and Forecasting
├── Notebooks
│   ├── 01_data_exploration.Rmd                             # Initial Exploratory Data Analysis and Visualization
│   ├── 01b_exploratory_analysis.Rmd                        # Exploratory Data Analysis, Statistical Analysis, Moving Average, Rolling Statistics and Decomposition  
│   ├── 02_experimental_analysis.Rmd                        # Experimental Results and Analysis (Plots, ACF, PACF)
│   ├── 03_data_preprocessing.Rmd                           # Data Cleaning and Pre-Processing
│   ├── 04_01_sesonal_naive_model.Rmd                       # Seasonal Naive Model
│   ├── 04_02_exponential_smoothing.Rmd                     # ETS Model
│   ├── 04_03_arfima_model.Rmd                              # ARFIMA Model
│   ├── 04_04_nnar_model.Rmd                                # NNAR Model
│   ├── 05_models_comparison.Rmd                            # Comparing Models
├── Reports
│   ├── 01_Data_Exploration.pdf                             # Data Exploration Output
│   ├── 01b_Exploratory_Analysis.pdf                        # Exploratory Analysis Output
│   ├── 02_Experimental_Analysis.pdf                        # Experimental Analysis Output
│   ├── 03_Data_PreProcessing.pdf                           # Data Pre-Processing Output
│   ├── 04_01_Seasonal_Naive.pdf                            # Seasonal Naive Model Output
│   ├── 04_02_Exponential_Smoothing.pdf                     # ETS Model Output
│   ├── 04_03_ARFIMA.pdf                                    # ARFIMA Model Output
│   ├── 04_04_NNAR.pdf                                      # NNAR Model Output
│   ├── 05_Models_Comparison.pdf                            # Models Comparison Output
├── Source Code
│   ├── data_exploration.R                                  # Exploratory Data Analysis Scripts
│   ├── data_preprocessing.R                                # Pre-Processing Scripts
│   ├── experimental_analysis.R                             # Experimental Analysis Scripts
│   ├── model_1_seasonal_naive.R                            # Seasonal Naive Model
│   ├── model_2_ets.R                                       # ETS Model
│   ├── model_3_arfima.R                                    # ARFIMA Model
│   ├── model_4_nnar_model.R                                # NNAR Model
└── README.md                                               # Project Overview and Instructions
```
