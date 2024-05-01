
#' Average number of bars per trade
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
avg_bars_per_trade <- function(ohlcv_data) {

  (rle(ohlcv_data$trade)$lengths[rle(ohlcv_data$trade)$values == 1] - 1) |>
    mean()

}
