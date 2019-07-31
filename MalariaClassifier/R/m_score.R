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
  reticulate::use_python(python = file.path(script_path, "..", "conda", "bin"), require = TRUE)
} else {
  # Windows
  reticulate::use_python(python = file.path(script_path, "..", "conda"), require = TRUE)
}


library(magrittr)
library(DataPreparation)
library(MalariaModel)


session_id <- args$get(name = "session_id", required = TRUE)

model <- MalariaModel::loadModel(config$model_path)

                                        #3) MODEL TESTING

                                        #Get testing samples
                                        #Convert the samples into a proper form

test_data <- DataPreparation::getAllImages(config$new_folder_path, "test") %>%
    DataPreparation::convertSamples()

#Evaluate the trained model

evaluation <- MalariaModel::evaluateModel(model,
                                          test_data$data_tensor,
                                          test_data$labels)

#Save model evaluation into a .csv file

MalariaModel::saveModelEvaluation(evaluation, config$new_folder_path)

#Predict classes of the test samples and the probability of each sample belonging to the predicted class

predictions <- MalariaModel::predictClassesAndProbabilities(model,
                                                            test_data$data_tensor,
                                                            config$new_folder_path)

#Save predictions into a .csv file

MalariaModel::savePredictions(dt = predictions,
                              config$new_folder_path,
                              session = session_id)


