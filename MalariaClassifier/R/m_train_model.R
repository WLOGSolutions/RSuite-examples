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

if (grepl("darwin|linux-gnu", R.version$os)) {
  #Linux or MacOS
    reticulate::use_python(python = file.path(script_path, "..", "conda", "bin"),
                           require = TRUE)
} else {
  # Windows
    reticulate::use_python(python = file.path(script_path, "..", "conda"),
                           require = TRUE)
}

suppressPackageStartupMessages({
  library(magrittr)
  library(DataPreparation)
  library(MalariaModel)
})

#-----------------------------------------------------------------------------------------------
#1) DATA PREPARATION

#Split the dataset into training, test and validation sets

DataPreparation::splitAndSave(
                     config$dataset_path,
                     config$new_folder_path,
                     config$id_train,
                     config$id_valid,
                     config$id_test)


#Get training and validation samples

train_data <- DataPreparation::getAllImages(config$new_folder_path, "train")

valid_data <- DataPreparation::getAllImages(config$new_folder_path, "validation")

#2) MODEL TRAINING

#Create the model: define its architecture and compile it

model <- MalariaModel::createModel() %>%
    MalariaModel::trainModel()

session_id <- MalariaModel::getSessionId()

#Save the model

MalariaModel::saveModel(model, config$models_folder_path,
                        session = session_id)
