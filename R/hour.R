
#' Hour
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#'
#' @return This function returns the hour from a datetime.
#'
hour <- function(ohlcv_data, source) {

  format(ohlcv_data[[source]], "%H") |>
    as.integer()

}
