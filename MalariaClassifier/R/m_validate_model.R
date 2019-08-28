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


suppressPackageStartupMessages({
  library(magrittr)
  library(DataPreparation)
  library(MalariaModel)
})

#-----------------------------------------------------------------------------------------------

model <- MalariaModel::loadModel(config$models_folder_path, config$session_id)

                                        #3) MODEL TESTING

                                        #Get testing samples
                                        #Convert the samples into a proper form

test_data <- DataPreparation::getLabelledImages(config$new_folder_path,
                                                "test",
                                                batch_size = 1)

#Reset test generator

MalariaModel::resetGenerator(test_data)

#Evaluate the trained model

evaluation <- MalariaModel::evaluateModel(model,
                                          test_data)

#Save model evaluation into a .csv file

MalariaModel::saveModelEvaluation(dt = evaluation,
                                  config$new_folder_path,
                                  session_id = config$session_id)



#Predict classes of the test samples and the probability scores

predictions <- MalariaModel::predictClassesAndProbabilities(model,
                                                            test_data)

#Calibrate probabilities

calibration <- MalariaModel::calibrateProbabilities(test_data,
                                                    predictions)

#Save calibration into an RDS file

MalariaModel::saveCalibration(calibration,
                              config$models_folder_path,
                              config$session_id)

#Apply calibration to the probabilities

calibrated_predictions <- applyCalibration(config$models_folder_path,
                                           config$session_id,
                                           predictions)

#Save predictions into a .csv file

MalariaModel::savePredictions(dt = calibrated_predictions,
                              config$new_folder_path,
                              session_id = config$session_id,
                              pred_id = config$prediction_id)


