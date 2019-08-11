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

#'Convert the images into a proper form.
#'@param new_data_path A path to the folder with the samples.
#'@param folder_name The name of the folder with the samples.
#'@return Keras image generator.
#'@export
getAllImages <- function(new_data_path, folder_name) {

  generator <- keras::image_data_generator(rescale=1/255)

  data_generator <- keras:: flow_images_from_directory(file.path(new_data_path, folder_name),
                                                       generator,
                                                       target_size = c(150, 150),
                                                       classes = c("Uninfected", "Parasitized"),
                                                       batch_size = 5,
                                                       class_mode = "binary")
  return(data_generator)
}

#'Convert the images for analysis into a proper form.
#'@param image_path A path to the folder with the samples..
#'@return Keras image generator.
#'@export
getImagesForAnalysis <- function(image_path){

  generator <- keras::image_data_generator(rescale=1/255)

  data_generator <- keras:: flow_images_from_directory(image_path,
                                                       generator,
                                                       target_size = c(150, 150),
                                                       batch_size = 1,
                                                       class_mode = NULL,
                                                       shuffle = FALSE)
  return(data_generator)
}
