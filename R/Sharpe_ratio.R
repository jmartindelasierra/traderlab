
#' Sharpe ratio
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
Sharpe_ratio <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  close_time <- year <- balance <- balance_end <- balance_start <- roc <- NULL

  annual_risk_free_rate <- 0.05

  annual_roc <-
    ohlcv_data |>
    dplyr::mutate(year = format(close_time, "%Y")) |>
    dplyr::group_by(year) |>
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance)) |>
    dplyr::mutate(roc = (balance_end - balance_start) / balance_start) |>
    dplyr::pull(roc)

  (mean(annual_roc) - annual_risk_free_rate) / stats::sd(annual_roc)
}
