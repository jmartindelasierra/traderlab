
#' Hull Moving Average (HMA)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param periods An integer with number of periods.
#'
HMA <- function(ohlcv_data, source, periods) {

  ma <- TTR::HMA(stats::na.omit(ohlcv_data[[source]]), n = periods)

  if (length(which(is.na(ohlcv_data[[source]]))) > 0) {
    c(rep(NA, max(which(is.na(ohlcv_data[[source]])))), ma)
  } else {
    ma
  }

}
