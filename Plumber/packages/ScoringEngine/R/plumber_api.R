#TODO: put into a custom package
custom_predict <- function(model, newdata)  {
    loginfo("--> custom_predict")
    newdata_h2o <- h2o::as.h2o(newdata)
    res <- as.data.frame(h2o::h2o.predict(model, newdata_h2o))
    return(as.numeric(res$predict))
}


#'@export
predict_and_explain <- function(new_data, work_dir) {
    model_h2o_automl <- load_model(work_dir)
    score <- custom_predict(model_h2o_automl,
                            new_data)

    explainer_h2o_automl <- DALEX::explain(model = model_h2o_automl,
                                           data = DALEX::apartmentsTest[,2:6],
                                           y = DALEX::apartmentsTest$m2.price,
                                           predict_function = custom_predict,
                                           label = "h2o automl")

    pb_h2o_automl <- DALEX::prediction_breakdown(explainer = explainer_h2o_automl,
                                                 observation = new_data)

    return(list(
        score = score,
        prediction_breakdown = pb_h2o_automl))
}


#'@export
build_models <- function(work_dir) {
    apartments_hf <- as.h2o(DALEX::apartments)
    model_h2o_automl <- h2o.automl(y = "m2.price",
                                   training_frame = apartments_hf,
                                   max_models = 10)
    path <- save_model(model_h2o_automl@leader, work_dir)

    return(path)
}
