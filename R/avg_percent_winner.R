
#' Average percent winner
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
avg_percent_winner <- function(ohlcv_data) {

  ohlcv_data |>
    dplyr::filter(pct_return > 0) |>
    dplyr::pull(pct_return) |>
    mean()

}
