
#' Risk-adjusted return
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
risk_adjusted_return <- function(ohlcv_data) {

  pct_return(ohlcv_data) / exposure(ohlcv_data)

}
