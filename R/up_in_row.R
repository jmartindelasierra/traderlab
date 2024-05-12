
#' Up in a row
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param periods An integer with number of periods.
#'
up_in_row <- function(ohlcv_data, source, periods) {

  is_increasing <- function(numbers) {
    all(diff(numbers) > 0)
  }

  slider::slide_lgl(ohlcv_data[[source]], is_increasing, .before = periods - 1, .complete = TRUE)

}
