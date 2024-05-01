
#' Maximum price value in a number of previous periods (support)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param periods An integer with number of periods.
#'
#' @return This function returns the maximum 'source' in a number of 'periods'.
#'
highest_value <- function(ohlcv_data, source, periods) {

  slider::slide_dbl(dplyr::lag(ohlcv_data[[source]], 1), max, .before = periods, .complete = TRUE)

}
