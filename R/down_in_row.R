
#' Down in a row
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param periods An integer with number of periods.
#'
down_in_row <- function(ohlcv_data, source, periods) {

  is_decreasing <- function(numbers) {
    all(diff(numbers) < 0)
  }

  slider::slide_lgl(ohlcv_data[[source]], is_decreasing, .before = periods - 1, .complete = TRUE)

}
