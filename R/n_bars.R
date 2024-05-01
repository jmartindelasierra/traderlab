
#' Number of bars in OHLCV data
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
n_bars <- function(ohlcv_data) {

  nrow(ohlcv_data)

}
