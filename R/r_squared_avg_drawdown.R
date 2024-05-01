
#' R-squared-to-average drawdown ratio
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
r_squared_avg_drawdown <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  exit <- NULL

  if (sum(ohlcv_data$exit, na.rm = TRUE) > 0) {

    ohlcv_data <-
      ohlcv_data |>
      dplyr::filter(exit) |>
      dplyr::mutate(x = 1:dplyr::n())

    linear <- stats::lm(balance ~ x, data = ohlcv_data)

    suppressWarnings(summary(linear)$adj.r.squared / abs(mean(ohlcv_data$drawdown)))

  } else {
    NA
  }

}
