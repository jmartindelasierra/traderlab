
#' Average number of bars per trade
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
avg_bars_per_trade <- function(ohlcv_data) {

  ohlcv_data |>
    dplyr::filter(!is.na(bars_from_entry),
                  bars_from_entry != 0) |>
    dplyr::pull(bars_from_entry) |>
    mean()

}
