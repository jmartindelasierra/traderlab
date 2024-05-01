
#' Volume-Weighted Average Price (VWAP)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param price_source A string with input price source.
#' @param volume_source A string with input volume source.
#' @param periods An integer with number of periods.
#'
VWAP <- function(ohlcv_data, price_source, volume_source, periods) {

  TTR::VWAP(ohlcv_data[[price_source]], ohlcv_data[[volume_source]], n = periods)

}
