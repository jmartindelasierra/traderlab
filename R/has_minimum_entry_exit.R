
#' Check if the OHLCV data contains a minimum number of entries and exits
#'
#' @description At least one entry and one exit is necessary.
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
has_minimum_entry_exit <- function(ohlcv_data) {

  sum(ohlcv_data$entry, na.rm = TRUE) > 0 & sum(ohlcv_data$exit, na.rm = TRUE) > 0

}
