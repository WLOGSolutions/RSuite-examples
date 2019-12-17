# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
  args <- commandArgs(trailingOnly = FALSE)
  script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
  if (!length(script_path)) {
    return("R")
  }
  if (grepl("darwin", R.version$os)) {
    base <- gsub("~\\+~", " ", base) # on MacOS ~+~ in path denotes whitespace
  }
  return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

ScoringEngine::init()
loginfo("Scoring Engine started")

work_dir <- file.path(script_path, "..", "work")

r <- plumber::plumb(file.path(script_path, "rest_api", "rest_score.R"))
loginfo("REST API loaded")

r$registerHook("exit", function() {
    loginfo("Closing...")
    ScoringEngine::shutdown()
    loginfo("--> Scoring Engine down")
})
r$setErrorHandler(function(req, res, e, ...) {
  res$body <- as.character(e)
})
r$run(port = 8000, host = "0.0.0.0", swagger = TRUE)
