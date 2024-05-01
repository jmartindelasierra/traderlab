
#' Day of the month (as number)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#'
day_of_month <- function(ohlcv_data, source) {

  format(ohlcv_data[[source]], "%d") |>
    as.integer()

}
