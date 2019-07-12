#' Get access to data
#'
#' @param dataset_path a path to the dataset
#'
#' @return loaded dataset
#'
#' @export
#'
readData<- function(dataset_path) {
  assert(file.exists(dataset_path), "File doesn't exist!")

  dataset <- fread(dataset_path)

  return(dataset)
}

#'
#' Prepare data for modelling - add a column with a mean of daily Sales
#'
#' @param dataset input dataset (data.table)
#'
#' @return modified dataset
#'
#' @export
#'
DataWithMean <- function(dataset){
  required_columns <- c("Date", "DayOfWeek", "Sales", "Promo")
  assert(all(required_columns %in% colnames(dataset)), "Some of columns are missing")

  dataset_out <- dataset %>%
    group_by(Date, DayOfWeek, Promo)%>%
    summarise(MeanSales=mean(Sales))

  return(dataset_out)
}
