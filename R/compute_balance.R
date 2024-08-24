
#' Computes the resulting balance for a model
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
compute_balance <- function(ohlcv_data, model) {

  # Initialization to avoid notes in R CMD check
  balance0 <- open_time <- first_close <- pct_balance0 <- pct_exc <- first_pct_balance0 <- close_time <- ret <- NULL

  position <- model$management$position
  start_capital <- model$management$start_capital
  interest_type <- model$management$interest_type
  reinvest <- model$management$reinvest
  leverage <- model$management$leverage
  fee_type <- model$management$fee_type
  fee <- model$management$fee

  balance <- start_capital
  ohlcv_data$pct_return <- NA
  ohlcv_data$balance <- NA
  ohlcv_data$fees <- NA

  for (i in 1:nrow(ohlcv_data)) {

    if (is.na(ohlcv_data$pct_entry_exit[i])) {

      ohlcv_data$balance[i] <- balance

    } else {

      flow <- capital_flow(position, start_capital, balance, interest_type, reinvest, ohlcv_data$entry_price[i], ohlcv_data$entry_price[i] + ohlcv_data$dif_entry_exit[i], leverage, fee_type, fee)
      balance <- flow$end
      ohlcv_data$pct_return[i] <- flow$pct_return
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
                  pct_balance_return = ret / dplyr::lag(balance)) # return % referenced to total capital

  ohlcv_data$pct_balance_return[1] <- 0

  ohlcv_data <- compute_drawdown(ohlcv_data)

  # Excursions
  trade_index <- c()
  trade_counter <- 0
  trade_in_progress <- FALSE

  for (i in 1:nrow(ohlcv_data)) {

    if (ohlcv_data$entry[i] == 1) {
      trade_counter <- trade_counter + 1
      trade_in_progress <- TRUE
    }

    if (!ohlcv_data$trade[i]) {
      trade_in_progress <- FALSE
    }

    if (trade_in_progress) {
      trade_index[i] <- trade_counter
    } else {
      trade_index[i] <- NA
    }

  }

  ohlcv_data$trade_index <- trade_index

  pct_exc_balance0 <-
    ohlcv_data |>
    dplyr::filter(trade_index > 0) |>
    dplyr::group_by(trade_index) |>
    dplyr::mutate(t = 1:dplyr::n(),
                  first_close = dplyr::first(close),
                  pct_exc = model$management$leverage * (((close - first_close) / first_close) - model$management$fee),
                  first_pct_balance0 = dplyr::first(pct_balance0),
                  pct_exc_balance0 = ifelse(t == max(t), pct_balance0, pct_exc + first_pct_balance0)) |>
    dplyr::ungroup() |>
    dplyr::select(close_time, pct_exc, pct_exc_balance0)

  ohlcv_data <-
    merge(ohlcv_data, # |> dplyr::select(-trade_index),
          pct_exc_balance0,
          by = "close_time",
          all = TRUE)

  ohlcv_data <-
    ohlcv_data |>
    dplyr::mutate(scope = ifelse(open_time >= model$periods$oos_start, "oos", "is"))

  ohlcv_data
}
