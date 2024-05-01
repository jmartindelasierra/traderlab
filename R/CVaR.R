
#' Monthly Conditional Value-at-Risk
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param pct A number with the level of confidence. Default 0.95.
#'
CVaR <- function(ohlcv_data, pct = 0.95) {

  # Initialization to avoid notes in R CMD check
  close_time <- balance <- balance_end <- balance_start <- roc <- NULL

  monthly_returns <-
    ohlcv_data |>
    dplyr::mutate(month = as.POSIXct(paste0(format(close_time, "%Y-%m"), "-01"))) |>
    dplyr::group_by(month) |>
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance)) |>
    dplyr::mutate(roc = (balance_end - balance_start) / balance_start) |>
    dplyr::pull(roc)

  unname(mean(stats::quantile(monthly_returns, seq(0, 1 - pct, length.out = 50), na.rm = TRUE)))
}
