
#' Number of trades per month
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param returns A vector of returns.
#'
trades_per_month <- function(ohlcv_data, returns) {

  mths <- lubridate::interval(ohlcv_data$open_time[1], ohlcv_data$open_time[nrow(ohlcv_data)]) / months(1)

  length(returns) / mths

}
