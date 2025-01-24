
#' Keltner channels
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param periods An integer for number of periods.
#' @param atr_mult A number for ATR multiplier.
#'
#' @return This function returns 'lwr', 'avg' and 'upr' series.
#'
Keltner <- function(ohlcv_data, periods, atr_mult) {

  channels <- TTR::keltnerChannels(ohlcv_data[, c("high", "low", "close")], n = periods, atr = atr_mult)

  as.data.frame(channels) |>
    stats::setNames(c("lwr", "avg", "upr"))

}
