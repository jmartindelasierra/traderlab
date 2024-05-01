
#' Add indicator to OHLCV data
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param indicator Indicator function (unquoted).
#' @param name A string with the named indicator.
#' @param ... Other parameters passed to indicator().
#'
#' @return This function returns an updated OHLCV data with the new indicator in 'name' column.
#'
add_indicator <- function(ohlcv_data, indicator, name, ...) {

  ohlcv_data[[name]] <- indicator(ohlcv_data, ...)
  ohlcv_data

}
