#' Define the architecture of the model.
#' Compile the model
#' @return A compiled model.
#' @export

createModel <- function() {
  model_architecture <- keras::keras_model_sequential() %>%

    keras::layer_conv_2d(filters=32, kernel_size = c(3,3), activation = "relu", input_shape = c(150, 150, 3)) %>%
    keras::layer_conv_2d(filters=32, kernel_size = c(3,3), activation = "relu") %>%
    keras::layer_max_pooling_2d(pool_size = c(2,2)) %>%
    keras::layer_conv_2d(filters=64, kernel_size = c(3,3), activation = "relu") %>%
    keras::layer_conv_2d(filters=64, kernel_size = c(3,3), activation = "relu") %>%
    keras::layer_max_pooling_2d(pool_size = c(2,2)) %>%

    keras::layer_flatten() %>%

    keras::layer_dense(units=512, activation = "relu") %>%
    keras::layer_dropout(rate=0.2) %>%
    keras::layer_dense(units=512, activation = "relu") %>%
    keras::layer_dropout(rate=0.2) %>%
    keras::layer_dense(units = 1, activation = "sigmoid")

  model_architecture %>% keras::compile(loss="binary_crossentropy",
                                        optimizer = keras::optimizer_adam(),
                                        metrics = c("acc"))
  return(model_architecture)

}


#'Train the model based on given train and validation samples.
#' @param model A compiled keras model object.
#' @return A history object which is a record of training loss values and metrics values at succesive epochs as well as validation loss values and validation metrics values.
#' @export
trainModel <- function(model) {

             model %>% fit_generator(train_data,
                                     steps_per_epoch = 100,
                                     epochs = 10,
                                     validation_data = valid_data,
                                     validation_steps = 200)
  return(model)
}

#'Get the session's identificator.
#'@return A number.
#'@export
getSessionId <- function(){
  session_id <- round(as.numeric(Sys.time()))
  return(session_id)
}

#'Save the trained model.
#' @param model The trained model.
#' @param save_path A path to a folder where the model is supposed to be saved.
#' @return A folder named "work + session_id" with a hdf5 file named "my_model" inside.
#' @export
saveModel <- function(model, save_path, session) {

  model_name <- sprintf("model %s", as.character(session))
  model_fpath <- file.path(save_path, model_name)
  keras::save_model_hdf5(model, model_fpath)

  pkg_loginfo("Model '%s' saved in Models folder.", model_name)

}

#' Load the model from a chosen directory.
#' @param models_f_path A path to the model.
#' @param session Session_id.
#' @return A keras model object.
#' @export
loadModel <- function(models_f_path, session){

  model_name <- sprintf("model %s", as.character(session))
  model <- keras::load_model_hdf5(file.path(models_f_path, model_name))

  pkg_loginfo("Model '%s' loaded.", model_name)

  return(model)


}

#'Evaluate the trained model based on the test dataset and save the results in a work folder.
#'@param model A trained model.
#'@param test_data A data tensor in a shape of N x 150 x 150 x 3.
#'@param test_labels A vector of labels.
#'@return A data table with accuracy and loss statistics saved in a .csv file in a work folder.
#'
#'@export
evaluateModel <- function(model, test_data){
  eva <- keras::evaluate_generator(model, test_data, steps = ceiling(test_data$n/test_data$batch_size))
  dt <- data.table::data.table(loss = eva$loss, acc = eva$acc)
  return(dt)
}

#'Save model evaluation: acc and loss.
#'@param dt A data table/data frame object.
#'@param f_path A path to the folder where the evaluation statistics are supposed to be saved.
#'@param session_id session id to take trained odel from
#'@return A .csv file called "evaluation_statistics".
#'@export
saveModelEvaluation <- function(dt, f_path, session_id) {

  folder_name <- sprintf("work %s", as.character(session_id))
  work_path <- file.path(f_path, folder_name)


  if (!dir.exists(work_path)) {
    dir.create(work_path)
  }


  data.table::fwrite(dt, file.path(f_path, folder_name, "evaluation_statistics"))

  pkg_loginfo("Evaluation statistics saved in '%s' folder", folder_name)

}

#'@export
#'
resetGenerator <- function(test_data){
  test_data$reset
}

#' Predict classes and probabilities of belonging to the predicted class for the testing samples using a trained model.
#' @param model A fitted keras model object.
#' @param test_data A data tensor in a shape of N x 150 x 150 x 3.
#' @return A data table with two columns: Class and Probability saved in a .csv file in a work folder.
#' @export
predictClassesAndProbabilities <- function(model, test_data){

  probabilities <- keras::predict_generator(model, test_data, steps = test_data$n, verbose = 1)

  classes <- ifelse(probabilities > 0.5, 1, 0)
  index <- test_data$filenames

  dt <- data.table::data.table(Id = index,
                               Class = classes,
                               Probability = probabilities)

  colnames(dt) <- c("Id", "Class", "Probability")

  return(dt)
}

#'Calibrate probability scores using isotonic regression.
#'@param dataset A dataset containing true labels.
#'@param dt A data frame containing probability scores.
#'@return A list of two: calibration and intervals.
#'
#'@export
calibrateProbabilities <- function(dataset, dt){

  classes <- dataset$classes
  levels(classes) <- c(0,1)

  calibration <- CORElearn::calibrate(classes,
                                      dt$Probability,
                                      class1 = 1,
                                      method = "isoReg",
                                      assumeProbabilities = TRUE)

  calibration$interval <- round(calibration$interval, 3)
  calibration$calProb <- round(calibration$calProb, 3)

  return(calibration)
}

#'Save calibration into RDS file.
#'@param calibration A list of previously calculated calibration and intervals.
#'@param f_path A path to the folder where RDS file is supposed to be saved.
#'@param session_id Session_id.
#'@return An RDS file.
#'@export
saveCalibration <- function(calibration, f_path, session_id){

  f_name <- sprintf("calibration %s", as.character(session_id))
  save_path <- file.path(f_path, f_name)

  if(!file.exists(save_path)){

    saveRDS(calibration, save_path)

    pkg_loginfo("File '%s' saved in Models folder.", f_name)

  }else{

    print("File already exists!")

  }

}

#'Apply calculated calibration to the data.
#'@param f_path A path to the folder where calibration file is stored.
#'@param session_id Session_id.
#'@param dt A data frame with calculated probability scores.
#'@return A data frame with patient's id, predicted class and calculated probability of belonging to the class.
#'@export
applyCalibration <- function(f_path, session_id, dt){

  data_frame <- dt
  calibration_name <- sprintf("calibration %s", as.character(session_id))
  calibration <- readRDS(file.path(f_path, calibration_name))

  calibrated_probabilities <- CORElearn::applyCalibration(dt$Probability, calibration)

  for(i in 1:nrow(dt)){
    if(data_frame$Class[i]==1){
      data_frame$Probability[i] <- calibrated_probabilities[i]
    }else{
      data_frame$Probability[i] <- (1 - calibrated_probabilities[i])
    }

  }

 pkg_loginfo("Probabilities calibrated using '%s' file.", calibration_name)
 return(data_frame)

}


#'Save predicted classes and probabilities into a .csv file.
#'@param dt A data table/data frame object.
#'@param f_path A path to the folder where predictions are supposed to be saved.
#'@return A .csv file called "predictions".
#'@export
savePredictions <- function(dt, f_path, session_id, pred_id) {

  file_name <- sprintf("predictions %s", as.character(pred_id))
  folder_name <-  sprintf("work %s", as.character(session_id))
  work_path <- file.path(f_path, folder_name)

  if (!dir.exists(work_path)) {
    dir.create(work_path)
  }

  data.table::fwrite(dt, file.path(f_path,
                                   folder_name,
                                   file_name))

  pkg_loginfo("File '%s' saved in '%s' folder.", file_name, folder_name)


}

#'Checks which samples are infected with probability higher than 50%.
#'@param f_path A path to the folder where a data frame with predictions is stored.
#'@param session_id Session_id.
#'@param pred_id Prediction_id.
#'@param threshold
#'@return A data frame with two columns: the index of the patient with class 1 and the probability of them belonging to the class
#'@export
getInfectedIndices <- function(f_path, session_id, pred_id, threshold){

  dt <- data.table::fread(file.path(f_path, sprintf("work %s", session_id),
                        sprintf("predictions %s", pred_id)))

  dt_infected <- dt[dt$Class == 1 & dt$Probability > threshold]
  dt_infected <- dt_infected[ , c(1, 3)]

  return(dt_infected)
}

#'Save the alleged infected in a .csv file
#'@param dt A data frame.
#'@param f_path A path to the folder where the predictions are supposed to be saved
#'@param session_id Session_id.
#'@param pred_id Prediction_id.
#'@export
saveInfected <- function(dt, f_path, session_id, pred_id){

  file_name <- sprintf("infected %s", pred_id)
  folder_name <- sprintf("work %s", session_id)

  work_path <- file.path(f_path, folder_name)

  if (!dir.exists(work_path)) {
    dir.create(work_path)
  }

  data.table::fwrite(dt, file.path(f_path, folder_name, file_name))

  pkg_loginfo("File '%s' saved in '%s' folder.", file_name, folder_name)
}
