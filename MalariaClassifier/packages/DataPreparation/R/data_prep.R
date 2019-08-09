#' Split the original dataset into three folders: train, validation and test. Each folder will consist of two subfolders: Parasitized and Uninfected.
#' Save the folders in a chosen directory.
#'
#' @param data_path a path to the folder where the original dataset is stored
#' @param new_path a path to the directory where the new folder will be created
#' @return A folder with training, validation and testing samples.
#'
#' @export
splitAndSave <- function(data_path, new_path, m, n, o, p, r) {

    original_dataset_dir <- data_path

                                        #Creating new folder

    base_dir <- new_path

    if (!dir.exists(base_dir)) {
        dir.create(base_dir)
    }

                                        #Creating subfolders

    train_dir <- file.path(base_dir, "train")
    if (!dir.exists(train_dir)) {
        dir.create(train_dir)
    }

    validation_dir <- file.path(base_dir, "validation")
    if (!dir.exists(validation_dir)) {
        dir.create(validation_dir)
    }

    test_dir <- file.path(base_dir, "test")
    if (!dir.exists(test_dir)) {
        dir.create(test_dir)
    }

    train_infected_dir <- file.path(train_dir, "Parasitized")
    if (!dir.exists(train_infected_dir)) {
        dir.create(train_infected_dir)
    }

    train_uninfected_dir <- file.path(train_dir, "Uninfected")
    if (!dir.exists(train_uninfected_dir)) {
        dir.create(train_uninfected_dir)
    }

    validation_infected_dir <- file.path(validation_dir, "Parasitized")
    if (!dir.exists(validation_infected_dir)) {
        dir.create(validation_infected_dir)
    }

    validation_uninfected_dir <- file.path(validation_dir, "Uninfected")
    if (!dir.exists(validation_uninfected_dir)) {
        dir.create(validation_uninfected_dir)
    }

    test_infected_dir <- file.path(test_dir, "Parasitized")
    if (!dir.exists(test_infected_dir)) {
        dir.create(test_infected_dir)
    }

    test_uninfected_dir <- file.path(test_dir, "Uninfected")
    if (!dir.exists(test_uninfected_dir)) {
        dir.create(test_uninfected_dir)
    }

                                        #Get the names of the files
    para_names <- list.files(file.path(data_path, "Parasitized"), "*.png")
    uninf_names <- list.files(file.path(data_path, "Uninfected"), "*.png")

                                        #Fill the created folders with images
    fnames1 <- para_names[1:m]
    file.copy(file.path(original_dataset_dir, "Parasitized", fnames1),
              file.path(train_infected_dir))

    fnames2 <- para_names[n : o]
    file.copy(file.path(original_dataset_dir, "Parasitized", fnames2),
              file.path(validation_infected_dir))

    fnames3 <- para_names[p:r]
    file.copy(file.path(original_dataset_dir, "Parasitized", fnames3),
              file.path(test_infected_dir))

    fnames4 <- uninf_names[1:m]
    file.copy(file.path(original_dataset_dir, "Uninfected", fnames4),
              file.path(train_uninfected_dir))

    fnames5 <- uninf_names[n:o]
    file.copy(file.path(original_dataset_dir, "Uninfected", fnames5),
              file.path(validation_uninfected_dir))

    fnames6 <- uninf_names[p:r]
    file.copy(file.path(original_dataset_dir, "Uninfected", fnames6),
              file.path(test_uninfected_dir))
}

#'Load the images and convert them into arrays
#'@param image_fpath A path to a folder where the images are stored
#'@return Images with a shape of an array
#'@export

imageLoad <- function(image_fpath) {
  image <- keras::image_load(image_fpath, target_size = c(150, 150))
  image_array <- image_to_array(image)
  return(image_array)
}

#'Convert the images into a proper form.
#'@param new_data_path A path to the folder with the samples.
#'@param folder_name The name of the folder with the samples.
#'@return A list of images encoded as tensors and labels: 1 - Parasitized, 0 - Uninfected
#'@export
getAllImages <- function(new_data_path, folder_name) {
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
    number_data[j, , , ] <- imageLoad(image_fpath)
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
    number_data2[j, , , ] <- imageLoad(image_fpath)
    if (j %% 100 == 0)
      pkg_loginfo("Processed %d out of %d images (label %d)...", j, m, 0)
    j <- j + 1
  }

  data <- abind(data, number_data, along = 1)
  labels <- c(labels, number_labels)

  data2 <- abind(data2, number_data2, along=1)
  labels2 <- c(labels2, number_labels2)

  return(list(
      data_tensor = c(data, data2),
      labels = c(labels, labels2)))
}

#'Convert samples into a proper shape: normalize pixel intensities, reshape tensors into a form of (n, 150, 150, 3), convert the lables.
#'@param dataset Data to be converted.
#'@return A list of data tensors and data lables.

#'@export
convertSamples <- function(dataset) {
    n <- length(dataset$labels)
                                        #reshape arrays
    tensors <- array_reshape(dataset$data_tensor,
                             c(n, 150, 150, 3))
                                        #normalize pixel intensities
    tensors <- tensors / 255
                                        #convert lables
    labels <- c(rep(1, 0.5 * n), rep(0, 0.5 * n))

    return(list(
        data_tensor = tensors,
        labels = dataset$labels))

}
#'Get the samples to be analised using the model.
#'@param data_path A path to the data.
#'@return A list of images encoded as tensors.
#'@export
getImagesForAnalysis <- function(data_path){

  data <- array(dim = c(0, 150, 150, 3))
  names <- list.files(data_path, "*.png")
  n <- length(names)
  number_data <- array(dim = c(n, 150, 150, 3))
  pkg_loginfo("Number of images: %d", n)

  j <- 1
  for (name in names) {
    image_fpath <- file.path(data_path, name)
    number_data[j, , , ] <- imageLoad(image_fpath)
    if (j %% 100 == 0)
      pkg_loginfo("Processed %d out of %d images ...", j, n)
    j <- j + 1
  }

  data <- abind(data, number_data, along = 1)
  return(list(data_tensor=c(data), length=n))

}

#'Convert images into a proper shape: reshape arrays and normalize pixel intensities.
#'@param dataset Data to be converted.
#'@return A list of data tensors.
#'@export
convertImagesForAnalysis <- function(dataset){
  n <- dataset$length
                                      #reshape arrays
  tensors <- array_reshape(dataset$data_tensor,
                           c(n, 150, 150, 3))
                                      #normalize pixel intensities
  tensors <- tensors / 255

  return(list(
    data_tensor=tensors))
}
