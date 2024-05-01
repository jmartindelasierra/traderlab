
#' Average True Range (ATR)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param periods An integer with number of periods.
#' @param type A character with moving average type:
#' - 'e': exponential
#' - 's': simple
#'
#' Default 's'.
#'
#' @return The ATR is computed as the moving average of TR.
#'
ATR <- function(ohlcv_data, periods, type = "s") {

  pracma::movavg(TR(ohlcv_data), n = periods, type = type)

}
