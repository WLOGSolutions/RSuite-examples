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
reticulate::use_python(python = file.path(script_path, "..", "conda", "bin"), require = TRUE)

library(DataPreparation)
library(MalariaModel)

devtools::load_all(file.path(script_path, "..", "packages", "DataPreparation"))
devtools::load_all(file.path(script_path, "..", "packages", "MalariaModel"))

#-----------------------------------------------------------------------------------------------
#1) DATA PREPARATION

#Split the dataset into training, test and validation sets

DataPreparation::splitAndSave(config$dataset_path,
             config$new_folder_path,
             config$m,
             config$n,
             config$o,
             config$p,
             config$r)


#Get training and validation samples

train_data <- getAllImages(config$new_folder_path, "train")

valid_data <- getAllImages(config$new_folder_path, "validation")

#Convert the samples into a proper form

train_data <- convertSamples(train_data$data_tensor, train_data$labels, length(train_data$labels))

valid_data <- convertSamples(valid_data$data_tensor, valid_data$labels, length(valid_data$labels))


#2) MODEL TRAINING

#Create the model: define its architecture and compile it

model <- createModel()

#Fit the model

model <- trainModel(model)

session_id <- Sys.time()

#Save the model

saveModel(model, config$new_folder_path, session=session_id)


#3) MODEL TESTING

#Get testing samples

test_data <- getAllImages(config$new_folder_path, "test")

#Convert the samples into a proper form

test_data <- convertSamples(test_data$data_tensor, test_data$labels, length(test_data$labels))

#Evaluate the trained model and save the results

evaluateModel(model, test_data$data_tensor, test_data$labels, config$new_folder_path)

#Predict classes of the test samples and the probability of each sample belonging to the predicted class

predictClassesAndProbabilities(model, test_data$data_tensor, config$new_folder_path)



#Load the model

model <- loadModel(config$model_path)
