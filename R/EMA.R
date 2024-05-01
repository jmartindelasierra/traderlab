
#' Exponential Moving Average (EMA)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param periods An integer with number of periods.
#'
EMA <- function(ohlcv_data, source, periods) {

  ma <- pracma::movavg(stats::na.omit(ohlcv_data[[source]]), n = periods, type = "e")

  if (length(which(is.na(ohlcv_data[[source]]))) > 0) {
    c(rep(NA, max(which(is.na(ohlcv_data[[source]])))), ma)
  } else {
    ma
  }

}
