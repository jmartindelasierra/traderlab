
#' Lag indicator
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source. Default 'close'.
#' @param periods An integer with number of periods. Default 1.
#'
#' @return This function lags the 'source' by a number of 'periods'.
#'
lag_indicator <- function(ohlcv_data, source = "close", periods = 1) {

  dplyr::lag(ohlcv_data[[source]], periods)

}
