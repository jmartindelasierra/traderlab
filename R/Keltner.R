
#' Keltner channels
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param periods An integer with number of periods.
#' @param atr_periods An integer with number of ATR periods.
#'
#' @return This function returns 'lwr', 'avg', 'upr' and 'pct' series.
#'
Keltner <- function(ohlcv_data, periods, atr_periods) {

  channels <- TTR::keltnerChannels(ohlcv_data[, c("high", "low", "close")], n = periods, atr = atr_periods)

  as.data.frame(channels) |>
    stats::setNames(c("lwr", "avg", "upr"))

}
