#' Plots the mean of sales on different days of the week
#' @param dataset The dataset
#' @param x the column with day of the week
#' @param y the column with the mean of sales
#' @return a barplot
#'@export
ggbar <- function(dataset, x, y){
  ggplot(dataset, aes(x, y))+geom_bar(stat="identity", color="darkblue", fill="lightblue")+ xlab("Day Of Week") + ylab("Mean of Sales") + theme_minimal()
}
#'Plots a boxplot of mean of sales
#' @param dataset The dataset
#' @param x the column with day of the week
#' @param y the column with the mean of sales
#' @return a boxplot
#'
#' @export
ggbox <- function(dataset, x, y){
  ggplot(data = dataset, aes(factor(x), y, fill = x)) + geom_boxplot(color="darkred") + theme_minimal() + xlab("Day Of Week") + ylab("Mean of Sales") + ggtitle("Distribution of mean of sales by Week Days.")
}

#' Plots a boxplot of mean of sales in given years
#' @param dataset The dataset
#' @param x the column with day of the week
#' @param y the column with the mean of sales
#' @return a boxplot

#' @export
ggyear <- function(dataset, x, y){
  ggplot(data = dataset, aes(substring(x,1,4), y, fill = substring(x,1,4))) + geom_boxplot(color="darkred") + theme_minimal() + xlab("Year") + ylab("Sales") + labs(fill="Year") + ggtitle("Distribution of mean of sales by Year.")
}

#' Plots a boxplot of mean of sales on given months
#' @param dataset The dataset
#' @param x the column with day of the week
#' @param y the column with the mean of sales
#' @return a boxplot
#'
#' @export
ggtrend <- function(dataset, x, y){
  ggplot(dataset, aes(substring(x, 6, 7), y)) + geom_boxplot(fill="lightblue") + theme_minimal() + xlab("Month") + ylab("Mean of Sales")
}

#' Plots a boxplot of mean of sales on given months and years
#' @param dataset The dataset
#' @param x the column with day of the week
#' @param y the column with the mean of sales
#' @return a boxplot
#'
#' @export
month_year <- function(dataset, x, y){
  ggplot(dataset, aes(substring(x,1,7),y))+geom_boxplot(fill="lightblue") + theme_minimal() + xlab("mm-YYYY") + ylab("Mean of Sales")
}

#' Plots a line plot of mean of sales during a given period of time
#' @param dataset The dataset
#' @param x the column with day of the week
#' @param y the column with the mean of sales
#' @return a lineplot
#'
#' @export
ggts <- function(dataset, x, y){
  ggplot(data = dataset) +
    geom_line(aes(as.Date(x), y), color = "#09557f", alpha = 0.6, size = 0.6) + theme_minimal() + xlab("Date") + ylab("Mean of Sales")
}

