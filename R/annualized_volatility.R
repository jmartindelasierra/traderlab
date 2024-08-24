
#' Annualized volatility
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
annualized_volatility <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  close_time <- year_month <- balance <- balance_end <- balance_start <- roc <- NULL

  monthly_roc <-
    ohlcv_data |>
    dplyr::mutate(year_month = format(close_time, "%Y-%m")) |>
    dplyr::group_by(year_month) |>
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance)) |>
    dplyr::mutate(roc = (balance_end - balance_start) / balance_start) |>
    dplyr::pull(roc)

  stats::sd(monthly_roc) * sqrt(12)
}
