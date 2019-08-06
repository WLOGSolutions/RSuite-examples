# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
  args <- commandArgs(trailingOnly = FALSE)
  script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
  if (!length(script_path)) {
    return(normalizePath("R"))
  }
  if (grepl("darwin", R.version$os)) {
    script_path <- gsub("~\\+~", " ", script_path) # on MacOS ~+~ in path denotes whitespace
  }
  return(normalizePath(script_path))
})()


loginfo("getwd() = %s", getwd())

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

suppressWarnings({
  suppressPackageStartupMessages({
    library(callr)
    library(rmarkdown)
  })})


loginfo("script_path: %s", script_path)

notebooks_path <- file.path(script_path, "..", "notebooks")

all_notebooks <- list.files(path = notebooks_path,
                            pattern = ".*\\.Rmd$",
                            full.names = TRUE)

loginfo("> Detected %d notebooks", length(all_notebooks))

idx <- 1
for (notebook in all_notebooks) {
  loginfo("> Rendering %s [%d/%d]",
          basename(notebook),
          idx,
          length(all_notebooks))
  callr::r(
    func = function(...) {
      rmarkdown::render(...)
    },
    args = list(
      input = all_notebooks,
      knit_root_dir = notebooks_path
    ),
    spinner = TRUE)
  idx <- idx + 1
}
