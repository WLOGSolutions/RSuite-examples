
#' Plots acf and pacf
#' @param data a vector
#' @return acf and pacf plots plotted next to each other
#'@export
acf_pacf <- function(data){
  par(mfrow=c(1,2))
  acf(data)
  pacf(data)
}
#' Fitting an ARIMA model
#' @param y a vector of values we want to model
#' @param xreg a matrix of additional regressors - it should be the same length as y
#' @return an ARIMA model
#'
#' @export
ar_fit = function(y, xreg) {
  auto.arima(y, approximation=FALSE,trace=FALSE, xreg=xreg)
}

#' Checks if the process is stationary using Dickey-Fuller test
#' @param data a vector of values
#'
#' @export
check_stat <- function(data){
  adf.test(data, alternative = "stationary")
}

#' Checks if the residuals are time invariant using Ljung-Box test
#' @param res a vector of residuals
#' @export
boxtest <- function(res){
  Box.test(res, type= "Ljung-Box")
}

#' Forecasting
#' @param model a fitted model
#' @param xreg a vector of additional regressors
#' @export
forcast_func <- function(model, xreg){
  forecast(model, xreg=xreg)
}
