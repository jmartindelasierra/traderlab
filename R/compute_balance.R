
#' Computes the resulting balance for a model
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
compute_balance <- function(ohlcv_data, model) {

  # Initialization to avoid notes in R CMD check
  balance0 <- open_time <- ret <- NULL

  position <- model$management$position
  start_capital <- model$management$start_capital
  interest_type <- model$management$interest_type
  reinvest <- model$management$reinvest
  leverage <- model$management$leverage
  fee_type <- model$management$fee_type
  fee <- model$management$fee

  balance <- start_capital
  ohlcv_data$balance <- NA
  ohlcv_data$fees <- NA

  for (i in 1:nrow(ohlcv_data)) {

    if (is.na(ohlcv_data$pct_entry_exit[i])) {

      ohlcv_data$balance[i] <- balance

    } else {

      flow <- capital_flow(position, start_capital, balance, interest_type, reinvest, ohlcv_data$entry_price[i], ohlcv_data$entry_price[i] + ohlcv_data$dif_entry_exit[i], leverage, fee_type, fee)
      balance <- flow$end
      ohlcv_data$balance[i] <- balance
      ohlcv_data$fees[i] <- flow$fees

    }

  }

  #
  ohlcv_data <-
    ohlcv_data |>
    dplyr::mutate(balance0 = balance - model$management$start_capital,
                  pct_balance0 = balance0 / model$management$start_capital,
                  ret = balance - dplyr::lag(balance),
                  pct_return = ret / dplyr::lag(balance))

  ohlcv_data$pct_return[1] <- 0

  ohlcv_data <- compute_drawdown(ohlcv_data)

  ohlcv_data <-
    ohlcv_data |>
    dplyr::mutate(scope = ifelse(open_time >= model$periods$oos_start, "oos", "is"))

  ohlcv_data
}
