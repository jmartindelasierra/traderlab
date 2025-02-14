# traderlab (0.0.0.9004)

* Additions:
  - New indicator: MFI (Money Flow Index)
* Fixes:
  - Conversion of open and close times in Binance data when they come with different accuracy
  - daily_value calculation

# traderlab (0.0.0.9003)

* Additions:
  - Interactive plots: iplot_balance(), iplot_balance_excursions(), iplot_portfolio_balance()
  - Portfolio analysis: run_porfolio()
  - New metrics: monthly_trades, avg_pct_return, avg_bal_pct_winner, avg_bal_pct_loser
  - Added margin call price
* Updates:
  - Risk/reward metric now calculated as avg. winner/avg. loser
  - Document lag parameter in daily_value indicator
  - Change of day of week numeration in day_of_week indicator (Monday is 1)
* Fixes:
  - Average bars metric calculation
  - ATR multiplier parameter in Keltner indicator changed from atr_period to atr_mult
  - daily_value indicator with lag = 0 is now valid

# traderlab (0.0.0.9002)

* New metrics:
  - Trades per month
  - Average % return
  - Annualized return (similar to CAGR)
  - Annualized volatility
* New plot:
  - plot_max_excursions()
* New table:
  - print_metrics()
* Updates:
  - print_returns()
  - plot_max_excursions()
  - List of metrics to compute
  - daily_value indicator (accepting lagging days as parameter)
* Fixes:
  - Week to minutes conversion
  - avg_bars metric calculation
* Other updates and fixes

# traderlab (0.0.0.9001)

* Two new indicators:
  - Aroon
  - Stochastic
* A special indicator to add Gaussian noise to data.
* Two new metrics to be used in the future for portfolio optimization:
  - Expected annual return
  - Standard deviation of annual returns
* New function plot_balance_excursions() to see the gain/loss evolution during an open position.
* The function plot_excursions() has been updated to be consistent with leverage settings.
* Other minor fixes and updates.

# traderlab (0.0.0.9000)

* Public release.
