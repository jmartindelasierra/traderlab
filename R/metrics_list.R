
#' Get list of computed metrics
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
metrics_list <- function(ohlcv_data) {

  returns <- get_returns(ohlcv_data)

  list(
    trades = number_of_trades(returns),
    monthly_trades = trades_per_month(ohlcv_data, returns),
    pct_return = pct_return(ohlcv_data),
    avg_pct_return = avg_percent_return(ohlcv_data),
    avg_pct_winner = avg_percent_winner(ohlcv_data),
    avg_pct_loser = avg_percent_loser(ohlcv_data),
    win_rate = win_probability(returns),
    winners_losers_ratio = win_loss_ratio(returns),
    avg_bars = avg_bars_per_trade(ohlcv_data),
    exposure = exposure(ohlcv_data),
    expectancy = expectancy(returns),
    profit_factor = profit_factor(returns),
    max_consec_winners = max_consecutive_wins(returns),
    max_consec_losers = max_consecutive_losses(returns),
    reward_risk_ratio = risk_reward_ratio(ohlcv_data),
    return_exposure_ratio = risk_adjusted_return(ohlcv_data),
    cagr = CAGR(ohlcv_data),
    annual_return = annualized_return(ohlcv_data),
    annual_volatility = annualized_volatility(ohlcv_data),
    # avg_annual_return = expected_annual_return(ohlcv_data),
    # std_annual_return = std_annual_return(ohlcv_data),
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
