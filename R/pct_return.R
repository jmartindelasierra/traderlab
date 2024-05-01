
#' Percentage return from origin
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
pct_return <- function(ohlcv_data) {

  (utils::tail(ohlcv_data$balance, 1) - ohlcv_data$balance[1]) / ohlcv_data$balance[1]

}
