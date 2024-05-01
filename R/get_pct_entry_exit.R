
#' Compute the difference between entry price and exit price
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
#' @return The function returns the OHLCV data with the computed differences in 'diff_entry_exit' column.
#'
get_pct_entry_exit <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  exit <- entry_price <- stop_loss_price <- dif_entry_exit <- NULL

  # Exit by profit exit or by stop loss
  if (is.null(ohlcv_data$stop_loss_price)) {
    ohlcv_data <-
      ohlcv_data |>
      dplyr::mutate(dif_entry_exit = ifelse(exit, close - entry_price, NA))
  } else {
    ohlcv_data <-
      ohlcv_data |>
      dplyr::mutate(dif_entry_exit = ifelse(exit | close <= stop_loss_price, close - entry_price, NA))
  }

  ohlcv_data <-
    ohlcv_data |>
    dplyr::mutate(pct_entry_exit = dif_entry_exit / entry_price)

  ohlcv_data
}
