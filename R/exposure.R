
#' Exposure
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
exposure <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  trade <- NULL

  (ohlcv_data |> dplyr::filter(trade) |> nrow()) / nrow(ohlcv_data)
}
