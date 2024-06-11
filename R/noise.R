
#' Gaussian noise
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param pct_dev A number with the average percentage deviation.
#'
noise <- function(ohlcv_data, source, pct_dev) {

  std_dev <- ohlcv_data[[source]] * as.numeric(pct_dev)
  noise <- stats::rnorm(length(std_dev), mean = 0, sd = std_dev)

  ohlcv_data[[source]] + noise

}
