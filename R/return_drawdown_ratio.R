
#' Return to maximum drawdown ratio
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
return_drawdown_ratio <- function(ohlcv_data) {

  (utils::tail(ohlcv_data$balance, 1) - ohlcv_data$balance[1]) / abs(min(ohlcv_data$drawdown))

}
