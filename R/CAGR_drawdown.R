
#' Compound Annual Growth Rate (CAGR) to maximum drawdown
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
CAGR_drawdown <- function(ohlcv_data) {

  CAGR(ohlcv_data) / abs(min(ohlcv_data$pct_drawdown))

}
