
#' Absolute Range (AR)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
#' @return This function returns the difference between the high and the low.
#'
AR <- function(ohlcv_data) {

  ohlcv_data$high - ohlcv_data$low

}
