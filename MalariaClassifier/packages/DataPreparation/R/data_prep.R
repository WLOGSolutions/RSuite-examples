#' Split the original dataset into three folders: train, validation and test. Each folder will consist of two subfolders: Parasitized and Uninfected.
#' Save the folders in a chosen directory.
#'
#' @param data_path a path to the folder where the original dataset is stored
#' @param new_path a path to the directory where the new folder will be created
#' @return A folder with training, validation and testing samples.
#'
#' @export
split_and_save <- function(data_path, new_path, m, n, o, p, r){

  assert(!file.exists(new_path), "This folder already exists!")

  original_dataset_dir <- data_path

  #Creating subfolders
  base_dir <- new_path
  dir.create(base_dir)

  train_dir <- file.path(base_dir, "train")
  dir.create(train_dir)

  validation_dir <- file.path(base_dir, "validation")
  dir.create(validation_dir)

  test_dir <- file.path(base_dir, "test")
  dir.create(test_dir)

  train_infected_dir <- file.path(train_dir, "Parasitized")
  dir.create(train_infected_dir)

  train_uninfected_dir <- file.path(train_dir, "Uninfected")
  dir.create(train_uninfected_dir)

  validation_infected_dir <- file.path(validation_dir, "Parasitized")
  dir.create(validation_infected_dir)

  validation_uninfected_dir <- file.path(validation_dir, "Uninfected")
  dir.create(validation_uninfected_dir)

  test_infected_dir <- file.path(test_dir, "Parasitized")
  dir.create(test_infected_dir)

  test_uninfected_dir <- file.path(test_dir, "Uninfected")
  dir.create(test_uninfected_dir)

  #Get the names of the files
  para_names <- list.files(file.path(data_path, "Parasitized"), "*.png")
  uninf_names <- list.files(file.path(data_path, "Uninfected"), "*.png")

  #Fill the created folders with images
  fnames1 <- para_names[1:m]
  file.copy(file.path(original_dataset_dir, "Parasitized", fnames1), file.path(train_infected_dir))

  fnames2 <- para_names[n : o]
  file.copy(file.path(original_dataset_dir, "Parasitized", fnames2), file.path(validation_infected_dir))

  fnames3 <- para_names[p:r]
  file.copy(file.path(original_dataset_dir, "Parasitized",fnames3), file.path(test_infected_dir))

  fnames4 <- uninf_names[1:m]
  file.copy(file.path(original_dataset_dir, "Uninfected", fnames4), file.path(train_uninfected_dir))

  fnames5 <- uninf_names[n:o]
  file.copy(file.path(original_dataset_dir, "Uninfected", fnames5), file.path(validation_uninfected_dir))

  fnames6 <- uninf_names[p:r]
  file.copy(file.path(original_dataset_dir, "Uninfected", fnames6), file.path(test_uninfected_dir))
}

#'Load the images and convert them into arrays
#'@param image_fpath A path to a folder where the images are stored
#'@return Images with a shape of an array
#'@export

ImageLoad <- function(image_fpath){
  image <- keras::image_load(image_fpath, target_size = c(150, 150))
  image_array <- image_to_array(image)
  return(image_array)
}

#'Convert the images into a proper form.
#'@param new_data_path A path to the folder with the samples.
#'@param folder_name The name of the folder with the samples.
#'@return A list of images encoded as tensors and labels: 1 - Parasitized, 0 - Uninfected
#'@export
getAllImages <- function(new_data_path, folder_name){
  data <- array(dim = c(0, 150, 150, 3))
  labels <- character(0)
  para_names <- list.files(file.path(new_data_path, folder_name, "Parasitized"), "*.png")
    n <- length(para_names)
    number_data <- array(dim = c(n, 150, 150, 3))
    number_labels <- rep(as.character(1), n)
    pkg_loginfo("Number of images with label %d: %d", 1, n)

    # a loop over all files in a subfolder "Parasitized"

    j <- 1
    for (para_name in para_names) {
      image_fpath <- file.path(new_data_path, folder_name, "Parasitized", para_name)
      number_data[j, , , ] <- ImageLoad(image_fpath)
      if (j %% 100 == 0)
        pkg_loginfo("Processed %d out of %d images (label %d)...", j, n, 1)
      j <- j + 1
    }

    data2 <- array(dim = c(0, 150, 150, 3))
    labels2 <- character(0)
    uninf_names <- list.files(file.path(new_data_path, folder_name, "Uninfected"), "*.png")
    m <- length(uninf_names)
    number_data2 <- array(dim = c(m, 150, 150, 3))
    number_labels2 <- rep(as.character(0), m)
    pkg_loginfo("Number of images with label %d: %d", 0, m)

    # a loop over all files in a subfolder "Uninfected"

    j <- 1
    for (uninf_name in uninf_names) {
      image_fpath <- file.path(new_data_path, folder_name, "Uninfected", uninf_name)
      number_data2[j, , , ] <- ImageLoad(image_fpath)
      if (j %% 100 == 0)
        pkg_loginfo("Processed %d out of %d images (label %d)...", j, m, 0)
      j <- j + 1
    }

    data <- abind(data, number_data, along = 1)
    labels <- c(labels, number_labels)

    data2 <- abind(data2, number_data2, along=1)
    labels2 <- c(labels2, number_labels2)

  return(list(data_tensor = c(data, data2), labels = c(labels, labels2)))
}

#'Normalize the values of pixels.
#'@param data_tensor Pixel intensities data tensor.
#'@return Normalized pixel intensities.
#'
#'@export
normalizePixelIntensities <- function(data_tensor) {
  data_tensor <- data_tensor / 255
  return(data_tensor)
}

#' Reshape arrays into a form of (n, 150, 150, 3).
#' @param data Data in a form of an array to be reshaped.
#' @param n Number of samples in the given data.
#' @return A reshaped array in a form of  (n, 150, 150, 3).
#' @export
#'
reshapeArrays <- function(data, n){
  data_tensor <- array_reshape(data, c(n, 150, 150, 3))
  return(data_tensor)
}

#' Convert the labels into a vector with values 0 and 1.
#' @param n Number of samples which are supposed to have labels.
#' @return Vector of values 0 and 1.
#'@export
convertLabels <- function(n) {
  labels <- c(rep(1, n), rep(0, n))
  return(labels)
}
