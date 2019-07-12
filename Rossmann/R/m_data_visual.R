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

################################################################################################
library(DataPreparation)
library(DataVisual)

#Loading the data
train <- readData(file.path(config$data_path, config$f_name_train))
train <- DataWithMean(train)

#Basic plots in order to detect any trends/choose best method of analysis

#1. Plots detecting any differences in sales in different days of the week

ggbar(train, train$DayOfWeek, train$MeanSales)

ggbox(train, train$DayOfWeek, train$MeanSales)

#2. Plots detecting differences in salesin given years

ggyear(train, train$Date, train$MeanSales)

month_year(train, train$Date, train$MeanSales)

#3. Plot detecting tifferences in sales in different months

ggtrend(train, train$Date, train$MeanSales)

#4. Plot showing trends in the mean of sales over the years
ggts(train, train$Date, train$MeanSales)


