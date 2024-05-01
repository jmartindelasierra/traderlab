
#' Compute the capital flow per trade
#'
#' @param position A string with trade position being either 'long' or 'short'.
#' @param start_capital A number with capital before executing the strategy.
#' @param current_capital A number with capital at the current trade.
#' @param interest_type A string with interest type being either 'simple' or 'compound'.
#' @param reinvest A number with the percentage of current capital to reinvest in each trade. The percentage is given from 0 to 1.
#' @param buy_price A number with the price at the time of buy.
#' @param sell_price A number with the price at the time of sell.
#' @param leverage A number with the leverage.
#' @param fee_type A string with the fee type being either 'per_trade_pct' or 'per_trade_fixed'.
#' @param fee A number with the percentage of the fees per trade (buy + sell).
#'
capital_flow <- function(position,
                         start_capital,
                         current_capital,
                         interest_type,
                         reinvest,
                         buy_price,
                         sell_price,
                         leverage,
                         fee_type,
                         fee) {

  pct_buy_sell <- (sell_price - buy_price) / buy_price

  if (interest_type == "simple") {
    remain_capital <- current_capital - min(current_capital, start_capital * reinvest)
    in_use_capital <- min(current_capital, start_capital * reinvest)
  } else if (interest_type == "compound") {
    remain_capital <- current_capital - current_capital * reinvest
    in_use_capital <- current_capital * reinvest
  }

  if (position == "long") {
    if (fee_type == "per_trade_pct") {
      end_capital <-
        in_use_capital + (
          (in_use_capital * pct_buy_sell) -
            (in_use_capital * fee)) * leverage + remain_capital
    } else if (fee_type == "per_trade_fixed") {
      end_capital <-
        in_use_capital + (
          (in_use_capital * pct_buy_sell) -
            fee) * leverage + remain_capital
    }
  } else if (position == "short") {
    if (fee_type == "per_trade_pct") {
      end_capital <-
        in_use_capital + (
          -(in_use_capital * pct_buy_sell) -
            (in_use_capital * fee)) * leverage + remain_capital
    } else if (fee_type == "per_trade_fixed") {
      end_capital <-
        in_use_capital + (
          -(in_use_capital * pct_buy_sell) -
            fee) * leverage + remain_capital
    }
  }

  return <- end_capital - (in_use_capital + remain_capital)
  pct_return <- return / (in_use_capital + remain_capital)

  if (end_capital < 0)
    end_capital <- 0

  if (fee_type == "per_trade_pct") {
    fees <- (in_use_capital * fee) * leverage
  } else if (fee_type == "per_trade_fixed") {
    fees <- fee * leverage
  }

  list(start = current_capital, end = end_capital, return = return, pct_return = pct_return, fees = fees)
}
