
#' Get list of computed metrics
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
metrics_list <- function(ohlcv_data) {

  returns <- get_returns(ohlcv_data)

  list(
    trades = number_of_trades(returns),
    pct_return = pct_return(ohlcv_data),
    cagr = CAGR(ohlcv_data),
    win_rate = win_probability(returns),
    profit_factor = profit_factor(returns),
    wl_ratio = win_loss_ratio(returns),
    rr_ratio = risk_reward_ratio(ohlcv_data),
    avg_bars = avg_bars_per_trade(ohlcv_data),
    exposure = exposure(ohlcv_data),
    expectancy = expectancy(returns),
    max_consec_wins = max_consecutive_wins(returns),
    max_consec_losses = max_consecutive_losses(returns),
    risk_adj_return = risk_adjusted_return(ohlcv_data),
    pct_dd = max_pct_drawdown(ohlcv_data),
    return_dd = return_drawdown_ratio(ohlcv_data),
    cagr_dd = CAGR_drawdown(ohlcv_data),
    # cagr_avg_dd = CAGR_avg_drawdown(ohlcv_data),
    sharpe_ratio = Sharpe_ratio(ohlcv_data),
    r_squared = r_squared(ohlcv_data),
    k_ratio = k_ratio(ohlcv_data),
    sqn = SQN(ohlcv_data),
    var = VaR(ohlcv_data),
    cvar = CVaR(ohlcv_data)
  )

}
