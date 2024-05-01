
#' Donchian channels
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param periods An integer with number of periods.
#'
#' @return This function returns 'upr', 'avg' and 'lwr' series.
#'
Donchian <- function(ohlcv_data, periods) {

  upper <- slider::slide_dbl(dplyr::lag(ohlcv_data$high, 1), max, .before = periods, .complete = TRUE)
  lower <- slider::slide_dbl(dplyr::lag(ohlcv_data$low, 1), min, .before = periods, .complete = TRUE)
  middle <- (upper + lower) / 2

  data.frame(upr = upper,
             avg = middle,
             lwr = lower)
}
