
#' Computes drawdown given balance
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
compute_drawdown <- function(ohlcv_data) {

  drawdown <- vector("numeric", nrow(ohlcv_data))
  pct_drawdown <- vector("numeric", nrow(ohlcv_data))

  ohlcv_data$drawdown <- 0
  ohlcv_data$pct_drawdown <- 0
  max_balance <- 0

  for (i in 1:nrow(ohlcv_data)) {

    if (ohlcv_data$balance[i] > max_balance) {

      max_balance <- ohlcv_data$balance[i]

    } else {

      drawdown[i] <- ohlcv_data$balance[i] - max_balance
      pct_drawdown[i] <- drawdown[i] / max_balance

    }

  }

  ohlcv_data$drawdown <- drawdown
  ohlcv_data$pct_drawdown <- pct_drawdown

  ohlcv_data
}
