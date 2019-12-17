#' @export
init <- function() {
    h2o::h2o.init()
    pkg_logdebug("---> Started h2o cluster")
}

#'@export
shutdown <- function() {
    h2o.shutdown(prompt = FALSE)
}
