
#' Average number of bars per trade
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
avg_bars_per_trade <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  bars_from_entry <- exit <- NULL

  ohlcv_data |>
    dplyr::filter(exit) |>
    dplyr::pull(bars_from_entry) |>
    mean(na.rm = TRUE)

}
