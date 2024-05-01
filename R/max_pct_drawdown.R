
#' Maximum drawdown in percentage
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
max_pct_drawdown <- function(ohlcv_data) {

  min(ohlcv_data$pct_drawdown, na.rm = TRUE)

}
