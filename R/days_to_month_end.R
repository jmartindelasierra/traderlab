
#' Days to month end
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#'
#' @return This function returns the number of days in the month - the current day of the month.
#'
days_to_month_end <- function(ohlcv_data, source) {

  unname(lubridate::days_in_month(ohlcv_data[[source]])) - as.integer(format(ohlcv_data[[source]], "%d"))

}
