#'@export
load_model <- function(work_dir) {
    existing_models <- NULL
    
    if (dir.exists(work_dir)) {
        existing_models <- list.files(path = work_dir,
                                      pattern = "*",
                                      full.names = TRUE)
    }
    if (length(existing_models) == 0) {
        stop("No model built. Please use /build_models POST request to build a model.")
    }
    model_h2o_automl <- h2o::h2o.loadModel(path = existing_models)
    return(model_h2o_automl)

}

#'@export
save_model <- function(model_object, work_dir) {
    if (!dir.exists(work_dir)) {
        dir.create(work_dir,
                   showWarnings = FALSE,
                   recursive = TRUE)
    } else {
        existing_models <- list.files(path = work_dir,
                                      pattern = "*",
                                      full.names = TRUE)
        
        if (length(existing_models) > 0) {
            unlink(existing_models, force = TRUE)
        }
    }
    path <- h2o::h2o.saveModel(object = model_object,
                               path = work_dir)
    return(path)
}
