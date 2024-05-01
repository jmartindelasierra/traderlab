
#' Average Directional Movement Index (ADX)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param periods An integer with number of periods.
#'
#' @return This function returns 'dip', 'din', 'dx' and 'adx' series.
#'
ADX <- function(ohlcv_data, periods) {

  adx <- TTR::ADX(ohlcv_data[, c("high", "low", "close")], n = periods)

  as.data.frame(adx) |>
    stats::setNames(c("dip", "din", "dx", "adx"))

}
