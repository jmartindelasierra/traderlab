
#' Hours to day end
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#'
#' @return This function returns 24 - hour in datetime source.
#'
hours_to_day_end <- function(ohlcv_data, source) {

  24 - (ohlcv_data[[source]] |> format("%H") |> as.integer())

}
