
#' Compound Annual Growth Rate (CAGR)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
CAGR <- function(ohlcv_data) {

  yrs <- lubridate::interval(ohlcv_data$open_time[1], ohlcv_data$open_time[nrow(ohlcv_data)]) / lubridate::years()

  (utils::tail(ohlcv_data$balance, 1) / ohlcv_data$balance[1]) ^(1 / yrs) - 1

}
