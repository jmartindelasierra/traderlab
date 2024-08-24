
#' Annualized return
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
annualized_return <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  close_time <- year_month <- balance <- balance_end <- balance_start <- NULL

  n_months <-
    ohlcv_data |>
    dplyr::mutate(year_month = format(close_time, "%Y-%m")) |>
    dplyr::pull(year_month) |>
    unique() |>
    length()

  roc <-
    ohlcv_data |>
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance)) |>
    dplyr::mutate(roc = (balance_end - balance_start) / balance_start) |>
    dplyr::pull(roc)

  (roc + 1) ^ (12/n_months) - 1
}
