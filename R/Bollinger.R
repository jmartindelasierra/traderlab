
#' Bollinger bands
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param periods An integer with number of periods.
#' @param sd A number with standard deviations.
#'
#' @return This function returns 'lwr', 'avg', 'upr' and 'pct' series.
#'
Bollinger <- function(ohlcv_data, periods, sd) {

  bands <- TTR::BBands(ohlcv_data[, c("high", "low", "close")], n = periods, sd = sd)

  as.data.frame(bands) |>
    stats::setNames(c("lwr", "avg", "upr", "pct"))

}
