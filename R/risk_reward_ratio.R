
#' Risk to reward ratio
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
risk_reward_ratio <- function(ohlcv_data) {

  exit <- dif_entry_exit <- entry_price <- stop_loss_price <- risk <- NULL

  if (!is.null(ohlcv_data$stop_loss_price)) {

    r_multiples <-
      ohlcv_data |>
      dplyr::filter(exit, dif_entry_exit > 0) |>
      dplyr::mutate(risk = entry_price - stop_loss_price,
                    r_multiples = dif_entry_exit / risk) |>
      dplyr::pull(r_multiples)

    mean(r_multiples)

  } else {
    NA_real_
  }

}
