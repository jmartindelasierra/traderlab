
#' Williams %R (WPR)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param periods An integer with number of periods.
#'
#' @return This function returns the Williams %R computed as -100 * (highest high - close) / (highest high - lowest low).
#'
WPR <- function(ohlcv_data, periods) {

  highest_high <- slider::slide_dbl(ohlcv_data$high, max, .before = periods, .complete = TRUE)
  lowest_low <- slider::slide_dbl(ohlcv_data$low, min, .before = periods, .complete = TRUE)

  ((highest_high - ohlcv_data$close) / (highest_high - lowest_low)) * (- 100)

}
