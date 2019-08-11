#' Define the architecture of the model.
#' Compile the model
#' @return A compiled model.
#' @export

createModel <- function (){
  model_architecture <- keras_model_sequential() %>%
    layer_conv_2d(filters=32, kernel_size = c(3,3), activation = "relu", input_shape = c(150, 150, 3)) %>%
    layer_max_pooling_2d(pool_size = c(2,2)) %>%
    layer_conv_2d(filters=64, kernel_size = c(3,3), activation = "relu") %>%
    layer_max_pooling_2d(pool_size = c(2,2)) %>%
    layer_conv_2d(filters=128, kernel_size = c(3,3), activation = "relu") %>%
    layer_max_pooling_2d(pool_size = c(2,2)) %>%
    layer_conv_2d(filters=128, kernel_size = c(3,3), activation = "relu") %>%
    layer_max_pooling_2d(pool_size = c(2,2)) %>%
    layer_flatten() %>%
    layer_dropout(rate=0.5) %>%
    layer_dense(units=512, activation = "relu") %>%
    layer_dense(units = 1, activation = "sigmoid")

  model_architecture %>% compile(loss="binary_crossentropy",
                                 optimizer=optimizer_rmsprop(lr=1e-5),
                                 metrics=c("acc"))
  return(model_architecture)

}


#'Train the model based on given train and validation samples.
#' @param model A compiled keras model object.
#' @return A history object which is a record of training loss values and metrics values at succesive epochs as well as validation loss values and validation metrics values.
#' @export
trainModel <- function(model) {

             model %>% fit_generator(train_data,
                                     steps_per_epoch = 2,
                                     epochs = 2,
                                     validation_data = valid_data,
                                     validation_steps = 5)
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

}

#' Load the model from a chosen directory.
#' @param f_path A path to the model.
#' @return A keras model object.
#' @export
loadModel <- function(models_f_path, session){
  keras::load_model_hdf5(file.path(models_f_path, sprintf("model %s", as.character(session))))
}

#'Evaluate the trained model based on the test dataset and save the results in a work folder.
#'@param model A trained model.
#'@param test_data A data tensor in a shape of N x 150 x 150 x 3.
#'@param test_labels A vector of labels.
#'@return A data table with accuracy and loss statistics saved in a .csv file in a work folder.
#'
#'@export
evaluateModel <- function(model, test_data){
  eva <- keras::evaluate_generator(model, test_data, steps = 5)
  dt <- data.table::data.table(loss=eva$loss, acc=eva$acc)
  return(dt)
}

#'Save model evaluation: acc and loss.
#'@param dt A data table/data frame object.
#'@param f_path A path to the folder where the evaluation statistics are supposed to be saved.
#'@return A .csv file called "evaluation_statistics".
#'@export
saveModelEvaluation <- function(dt, f_path, session){

  work_path <- file.path(f_path, sprintf("work %s", as.character(session)))

  if(!dir.exists(work_path)){
    dir.create(work_path)
  }

  data.table::fwrite(dt, file.path(f_path, sprintf("work %s", as.character(session)), "evaluation_statistics"))
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

  dt <- data.table::data.table(Id= index, Class=classes, Probability=probabilities)
  colnames(dt) <- c("Id", "Class", "Probability")

  return(dt)
}

#'Save predicted classes and probabilities into a .csv file.
#'@param dt A data table/data frame object.
#'@param f_path A path to the folder where predictions are supposed to be saved.
#'@return A .csv file called "predictions".
#'@export
savePredictions <- function(dt, f_path, session, number){

  work_path <- file.path(f_path, sprintf("work %s", as.character(session)))

  if(!dir.exists(work_path)){
    dir.create(work_path)
  }

  data.table::fwrite(dt, file.path(f_path, sprintf("work %s", as.character(session)), sprintf("predictions %s", as.character(number))))
}

#'Checks which samples are infected with probability higher than 50%.
#'@param f_path A path to the folder where a data frame with predictions is stored.
#'@param session Session_id.
#'@param number Prediction_id.
#'@return A data frame with two columns: the index of the patient with class 1 and the probability of them belonging to the class
#'@export
getInfectedIndices <- function(f_path, session, number){

  dt <- fread(file.path(f_path, sprintf("work %s", as.character(session)), sprintf("predictions %s", as.character(number))))

  dt_infected <- dt[dt$Class==1 & dt$Probability>0.5]
  dt_infected <- dt_infected[ , c(1, 3)]

  return(dt_infected)
}

#'Save the alleged infected in a .csv file
#'@param dt A data frame.
#'@param f_path A path to the folder where the predictions are supposed to be saved
#'@param session Session_id.
#'@param number Prediction_id.
#'@export
saveInfected <- function(dt, f_path, session, number){

  work_path <- file.path(f_path, sprintf("work %s", as.character(session)))

  if(!dir.exists(work_path)){
    dir.create(work_path)
  }

  data.table::fwrite(dt, file.path(f_path, sprintf("work %s", as.character(session)), sprintf("infected %s", as.character(number))))
}
