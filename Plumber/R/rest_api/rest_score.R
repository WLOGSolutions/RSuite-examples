#TODO: should be just simple wrappers for functions implemented in a custom package

#* Basic info on the service.
#* @get /
#* @html
function() {
  return(paste0("<html>",
                "<h1>It's a Plumber project service</h1>",
                "<p>Go to <a href=\"/__swagger__/\">Swagger UI</a> for API reference",
                "</html>"))
}

#* Scoring information on the row.
#* @param row_id:int Id of row to scor (e.g. 2)
#* @get /score
#* @post /score
function(row_id = 2) {
    loginfo("calculating score for row id:%s", row_id)
    row_id <- as.integer(row_id)
    new_apartment <- DALEX::apartmentsTest[row_id,]

    pred <- ScoringEngine::predict_and_explain(new_data = new_apartment, work_dir)

    loginfo("Prediction explained")

    return(pred)
}

#* Calculates score for variables
#* @param district The district (e.g. Srodmiescie)
#* @param no.rooms:int Number of rooms (e.g. 2)
#* @param construction.year:int Then the building was constructed (e.g. 2005)
#* @param floor:int Which flow flat is on (e.g. 2)
#* @param surface:double Surface of the flat in square meters (e.g. 69)
#* @get /score_vars
#* @post /score_vars
function(district = "Srodmiescie", no.rooms = 2, construction.year = 2000, floor = 2, surface = 69.0) {
    loginfo("calculating score for vars")

    new_apartment <- data.frame(
        district = district,
        no.rooms = as.numeric(no.rooms),
        construction.year = as.numeric(construction.year),
        floor = as.numeric(floor),
        surface = as.numeric(surface))

    pred <- ScoringEngine::predict_and_explain(new_data = new_apartment, work_dir)    
    loginfo("Prediction explained")

    return(pred)
}

#* Builds models.
#* @post /build_models
build_models <- function() {
    path <- ScoringEngine::build_models(work_dir)

    return(list(
        success = TRUE,
        path = path))
}
