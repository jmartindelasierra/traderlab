
#' Day of the week (as number)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#'
day_of_week <- function(ohlcv_data, source) {

  format(ohlcv_data[[source]], "%w") |>
    as.integer()

}
