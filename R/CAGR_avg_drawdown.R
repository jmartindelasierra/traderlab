
#' Compound Annual Growth Rate (CAGR) to average drawdown
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
CAGR_avg_drawdown <- function(ohlcv_data) {

  CAGR(ohlcv_data) / abs(mean(ohlcv_data$pct_drawdown))

}
