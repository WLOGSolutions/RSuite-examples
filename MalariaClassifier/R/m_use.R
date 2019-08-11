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

                                        #4) USING THE MODEL FOR ANALYSIS

                                        #Get images for analysis
                                        #Convert the images into a proper form


samples <- DataPreparation::getImagesForAnalysis(config$images_for_analysis)


#Predict classes of the test samples and the probability of each sample belonging to the predicted class

predictions <- MalariaModel::predictClassesAndProbabilities(model,
                                                            samples)
#Save predictions into a .csv file

MalariaModel::savePredictions(dt = predictions,
                              config$new_folder_path,
                              session = config$session_id,
                              number=config$prediction_id)

#Get the indices and the probabilities of the patients who are likely to be infected

infected <- MalariaModel::getInfectedIndices(config$new_folder_path,
                                                session = config$session_id,
                                                number = config$prediction_id)

#Save predictions of the infected into a .csv file

MalariaModel::saveInfected(dt = infected,
                           config$new_folder_path,
                           session = config$session_id,
                           number=config$prediction_id)

