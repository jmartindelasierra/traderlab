
#' Money Flow Index (MFI)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param periods An integer with number of periods.
#'
MFI <- function(ohlcv_data, periods) {

  TTR::MFI(ohlcv_data[, c("high", "low", "close")], ohlcv_data$volume, n = periods)

}
