
#' Gaussian noise
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param pct_dev A number with the percentage deviation or a string with the name of a feature in ohlcv_data.
#'
noise <- function(ohlcv_data, source, pct_dev) {

  if (is.character(pct_dev) && !is.null(ohlcv_data[[pct_dev]])) {
    std_dev <- ohlcv_data[[source]] * abs(ohlcv_data[[pct_dev]])
  } else {
    std_dev <- ohlcv_data[[source]] * as.numeric(pct_dev)
  }

  # Why std_dev/3?
  # We known 99.7% of data is within 3 standard deviations, so we look for deviations from the mean that covers that 99.7%
  # If we don't scale, movements of +-pct_dev are constrained to 1 standard deviation so only the 68% of noise would be within +-pct_dev
  noise <- stats::rnorm(length(std_dev), mean = 0, sd = std_dev/3)

  ohlcv_data[[source]] + noise

}
