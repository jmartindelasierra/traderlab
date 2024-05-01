
#' Relative Strength Indicator (RSI)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param periods An integer with number of periods.
#'
#' @details The RSI is calculated as RSI = 100 - 100 / (1 + RS), where RS is (average wins / average losses).
#'
RSI <- function(ohlcv_data, source, periods) {

  TTR::RSI(ohlcv_data[[source]], n = periods)

}
