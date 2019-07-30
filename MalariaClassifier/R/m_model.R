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
reticulate::use_python(python = file.path(script_path, "..", "conda"), require = TRUE)

library(DataPreparation)
library(MalariaModel)

#-----------------------------------------------------------------------------------------------
#1) DATA PREPARATION

#Split the dataset into training, test and validation sets

DataPreparation::split_and_save(
                     config$dataset_path,
                     config$new_folder_path,
                     config$m,
                     config$n,
                     config$o,
                     config$p,
                     config$r)


#Get training and validation samples

train_data <- DataPreparation::getAllImages(config$new_folder_path, "train")

valid_data <- DataPreparation::getAllImages(config$new_folder_path, "validation")

#Convert the samples into a proper form

train_data$data_tensor <- reshapeArrays(train_data$data_tensor, 2000)
train_data$data_tensor <- normalizePixelIntensities(train_data$data_tensor)
train_data$labels <- convertLabels(1000)


valid_data$data_tensor <- reshapeArrays(valid_data$data_tensor, 1000)
valid_data$data_tensor <- normalizePixelIntensities(valid_data$data_tensor)
valid_data$labels <- convertLabels(500)



#2) MODEL TRAINING

#Define the architecture of the model

model <- ModelArchitecture()

#Compile the model

model <- CompileModel(model)

#Fit the model

model <- trainModel(model)

#Save the model

saveModel(model, config$new_folder_path)


#3) MODEL TESTING

#Get testing samples

test_data <- getAllImages(config$new_folder_path, "test")

#Convert the samples into a proper form

test_data$data_tensor <- normalizePixelIntensities(test_data$data_tensor)
test_data$data_tensor <- reshapeArrays(test_data$data_tensor, 1000)
test_data$labels <- convertLabels(500)

#Evaluate trained model

evaluateModel(model, test_data$data_tensor, test_data$labels)

#Predict classes of the test samples

predictClasses(model, test_data$data_tensor)

#The probabilities of each image belonging to the predicted class

probabilities <- predictProbabilities(model, test_data$data_tensor)
probabilities


#Load the model

model <- loadModel(config$new_folder_path)

