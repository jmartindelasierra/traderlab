
#' Moving Average Convergence Divergence (MACD)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param fast_periods An integer with number of periods for fast moving average.
#' @param slow_periods An integer with number of periods for slow moving average.
#' @param signal_periods An integer with number of periods for signal moving average.
#'
#' @return This function returns 'macd' and 'signal' series.
#'
MACD <- function(ohlcv_data, fast_periods, slow_periods, signal_periods) {

  macd <- TTR::MACD(ohlcv_data[["close"]], nFast = fast_periods, nSlow = slow_periods, nSig = signal_periods, maType = "EMA")

  as.data.frame(macd)

}
