
#' R-squared
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
r_squared <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  exit <- NULL

  if (sum(ohlcv_data$exit, na.rm = TRUE) > 0) {

    ohlcv_data <-
      ohlcv_data |>
      dplyr::filter(exit) |>
      dplyr::mutate(x = 1:dplyr::n())

    linear <- stats::lm(balance ~ x, data = ohlcv_data)

    suppressWarnings(summary(linear)$adj.r.squared)

  } else {
    NA
  }

}
