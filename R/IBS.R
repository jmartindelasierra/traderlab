
#' Internal Bar Strength (IBS)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
IBS <- function(ohlcv_data) {

  ibs <- 100 * (ohlcv_data$close - ohlcv_data$low) / (ohlcv_data$high - ohlcv_data$low)

  ibs[is.nan(ibs)] <- 0

  ibs
}
