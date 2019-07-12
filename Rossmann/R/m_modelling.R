# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
  args <- commandArgs(trailingOnly = FALSE)
  script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
  if (!length(script_path)) {
    return("R")
  }
  if (grepl("darwin", R.version$os)) {
    script_path <- gsub("~\\+~", " ", script_path) # on MacOS ~+~ in path denotes whitespace
  }
  return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

#----------------------------------------------------------------------------------------------
library(DataPreparation)
library(DataVisual)
library(ARIMAmodelling)

#Loading the data and modyfing it to a required format
train <-readData(file.path(config$data_path, config$f_name_train))
train <- DataWithMean(train)

#1.) Exploration of the data

acf_pacf(train$MeanSales)

acf_pacf(diff(train$MeanSales))

check_stat(train$MeanSales)

#2.) Fitting an ARIMA model

fit_Sales <- ar_fit(train$MeanSales, xreg=matrix(c(train$DayOfWeek, train$Promo), ncol=2, byrow=FALSE))

summary(fit_Sales)

#3.) Evaluating the model - checking the residuals

boxtest(fit_Sales$residuals)

acf_pacf(fit_Sales$residuals)

#4.) Forecasting

#Preparing the data
test <- readData("/Users/urszulabialonczyk/Documents/Wlog/Rossmann/rossmann-store-sales/test.csv")
test <- DataWithMean(test)

#Forecast
forcast_func(fit_Sales,  xreg=matrix(c(test2$DayOfWeek, test2$Promo), ncol=2, byrow=FALSE))
