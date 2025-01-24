
#' Average percent loser from balance
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
avg_balance_percent_loser <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  balance <- NULL

  ohlcv_data |>
    dplyr::mutate(pct_return = (balance - dplyr::lag(balance)) / dplyr::lag(balance)) |>
    dplyr::filter(pct_return < 0) |>
    dplyr::pull(pct_return) |>
    mean(na.rm = TRUE)

}
