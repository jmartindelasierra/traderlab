
#' True Range (TR)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
#' @return This function returns the true range.
#'
TR <- function(ohlcv_data) {

  pmax(ohlcv_data$high - ohlcv_data$low, ohlcv_data$high - dplyr::lag(ohlcv_data$close, 1), dplyr::lag(ohlcv_data$close, 1) - ohlcv_data$low, na.rm = TRUE)

}
