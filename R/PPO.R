
#' Percentage Price Oscillator (PPO)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param fast_periods An integer with number of periods for the fast EMA.
#' @param slow_periods An integer with number of periods for the slow EMA.
#' @param signal_periods An integer with number of periods for the signal EMA.
#'
PPO <- function(ohlcv_data, source, fast_periods, slow_periods, signal_periods) {

  fast_ema <- pracma::movavg(ohlcv_data[[source]], n = fast_periods, type = "e")
  slow_ema <- pracma::movavg(ohlcv_data[[source]], n = slow_periods, type = "e")

  ppo <- 100 * (fast_ema - slow_ema) / slow_ema

  signal_ema <- pracma::movavg(ppo, n = signal_periods, type = "e")

  data.frame(ppo = ppo,
             hist = ppo - signal_ema)

}
