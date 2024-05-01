
#' Get not null returns
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
get_returns <- function(ohlcv_data) {

  ohlcv_data$ret[ohlcv_data$ret != 0 & !is.na(ohlcv_data$ret)]

}
