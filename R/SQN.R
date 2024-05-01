
#' System Quality Number
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
SQN <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  exit <- entry_price <- stop_loss_price <- dif_entry_exit <- risk <- NULL

  if (!is.null(ohlcv_data$stop_loss_price)) {

    r_multiples <-
      ohlcv_data |>
      dplyr::filter(exit) |>
      dplyr::mutate(risk = entry_price - stop_loss_price,
                    r_multiples = dif_entry_exit / risk) |>
      dplyr::pull(r_multiples)

    n_trades <- sum(ohlcv_data$exit, na.rm = TRUE)

    if (n_trades > 100) {
      sqrt_n <- sqrt(100)
    } else {
      sqrt_n <- sqrt(n_trades)
    }

    (mean(r_multiples) / stats::sd(r_multiples)) * sqrt_n

  } else {

    # risk_estimate <- abs(ohlcv_data$dif_entry_exit[ohlcv_data$dif_entry_exit < 0 & !is.na(ohlcv_data$dif_entry_exit)]) |> mean()
    #
    # r_multiples <-
    #   ohlcv_data |>
    #   dplyr::filter(exit) |>
    #   dplyr::mutate(r_multiples = dif_entry_exit / risk_estimate) |>
    #   dplyr::pull(r_multiples)

    NA_real_
  }

}
