#' Define the architecture of the model.
#' @return The architecture of the model.
#' @export

ModelArchitecture <- function (){
  model_architecture <- keras_model_sequential() %>%
    layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = "relu", input_shape = c(150, 150, 3)) %>%
    layer_max_pooling_2d(pool_size = c(2,2)) %>%
    layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = "relu") %>%
    layer_max_pooling_2d(pool_size = c(2,2)) %>%
    layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = "relu") %>%
    layer_max_pooling_2d(pool_size = c(2,2)) %>%
    layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = "relu") %>%
    layer_max_pooling_2d(pool_size = c(2, 2)) %>%
    layer_flatten() %>%
    layer_dropout(rate = 0.5) %>%
    layer_dense(units = 512, activation = "relu") %>%
    layer_dense(units = 1, activation = "sigmoid")

  return(model_architecture)

}

#'Compile the model.
#' @param model Keras model composed of a linear stack of layers.
#' @return A compiled keras model object
#'
#' @export
CompileModel <- function(model){
  model %>% compile(loss="binary_crossentropy", optimizer=optimizer_rmsprop(lr=1e-5), metrics=c("acc"))
  return(model)
}

#'Train the model based on given train and validation samples.
#' @param model A compiled keras model object.
#' @return A history object which is a record of training loss values and metrics values at succesive epochs as well as validation loss values and validation metrics values.
#' @export
trainModel <- function(model, epochs = 30, batch_size = 100) {

  model %>% fit(train_data$data_tensor,
                train_data$labels,
                epochs = epochs,
                batch_size = batch_size,
                view_metrics=TRUE,
                validation_data = list(valid_data$data_tensor, valid_data$labels))

  return(model)
}

#'Save the trained model on a hard drive.
#' @param model The trained model.
#' @param save_path A path to a folder where the model is supposed to be saved.
#' @return A hdf5 file named "my_model".
#' @export
saveModel <- function(model, save_path) {
  dir.create(save_path, showWarnings = FALSE)

  model_name <- "my_model"
  model_fpath <- file.path(save_path, model_name)
  keras::save_model_hdf5(model, model_fpath)

}
#' Load the model named "my_model" from a chosen folder.
#' @param f_path A path to a folder where "my_model" is stored.
#' @return A keras model object.
#' @export
loadModel <- function(f_path){
  keras::load_model_hdf5(file.path(f_path, "my_model"))
}

#'Evaluate the trained model based on the test dataset
#'@param model A trained model.
#'@param test_data A data tensor in a shape of N x 150 x 150 x 3
#'@param test_labels One-hot encoded matrix of labels.
#'
#'@export
evaluateModel <- function(model, test_data, test_labels){
  keras::evaluate(model, test_data, test_labels)
}

#' Predict classes of the testing samples using a trained model.
#' @param model A fitted keras model object.
#' @param test_data A data tensor in a shape of N x 150 x 150 x 3.
#' @return One-hot encoded labels : 1 - Parasitized, 0 - Uninfected.
#' @export
predictClasses <- function(model, test_data){
  keras::predict_classes(model, test_data)
}

#' Return probabilities of the predictions.
#' @param model A fitted keras model object.
#' @param test_data A data tensor in a shape of N x 150 x 150 x 3.
#' @return The probabilities of a particular image belonging to the predicted class.
#' @export
predictProbabilities <- function(model, test_data){
  probabilities <- keras::predict_proba(model, test_data)
  return(probabilities)
}
