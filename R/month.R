
#' Month number
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#'
#' @return This function returns the month from a date or datetime.
#'
month <- function(ohlcv_data, source) {

  format(ohlcv_data[[source]], "%m") |>
    as.integer()

}
