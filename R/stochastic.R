
#' Stochastic oscillator
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param fast_k_periods An integer with number of periods for fast %K.
#' @param fast_d_periods An integer with number of periods for fast %D.
#' @param slow_d_periods An integer with number of periods for slow %D.
#'
stochastic <- function(ohlcv_data, source = NULL, fast_k_periods, fast_d_periods, slow_d_periods) {

  if (is.null(source)) {
    stoch <- TTR::stoch(ohlcv_data[, c("high", "low", "close")], nFastK = fast_k_periods, nFastD = fast_d_periods, nSlowD = slow_d_periods)
  } else {
    stoch <- TTR::stoch(ohlcv_data[[source]], nFastK = fast_k_periods, nFastD = fast_d_periods, nSlowD = slow_d_periods)
  }

  as.data.frame(stoch) |>
    stats::setNames(c("fastK", "fastD", "slowD"))

}
