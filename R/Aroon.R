
#' Aroon
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param periods An integer with number of periods.
#'
Aroon <- function(ohlcv_data, periods) {

  aroon <- TTR::aroon(ohlcv_data[["close"]], n = periods)

  as.data.frame(aroon) |>
    stats::setNames(c("up", "dn", "osc"))

}
