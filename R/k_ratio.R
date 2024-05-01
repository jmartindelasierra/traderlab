
#' K-ratio
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
k_ratio <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  exit <- NULL

  if (sum(ohlcv_data$exit, na.rm = TRUE) > 0) {

    ohlcv_data <-
      ohlcv_data |>
      dplyr::filter(exit) |>
      dplyr::mutate(x = 1:dplyr::n())

    linear <- stats::lm(balance ~ x, data = ohlcv_data)
    linear_sum <- suppressWarnings(summary(linear))

    # 2003 version
    linear_sum$coefficients[2] / (linear_sum$coefficients[4] * nrow(ohlcv_data))

  } else {
    NA
  }

}
