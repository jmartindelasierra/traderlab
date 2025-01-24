
#' Add margin call price to OHLCV data
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
#' @return This function returns an updated OHLCV data with stop loss price.
#'
add_margin_call_price <- function(ohlcv_data, model) {

  # Initialization to avoid notes in R CMD check
  entry_price <- NULL

  pct_margin_call <- model$management$start_capital/(model$management$start_capital * model$management$leverage)

  ohlcv_data <-
    ohlcv_data |>
    dplyr::mutate(margin_call_price = ifelse(!is.na(entry_price),
                                             entry_price - pct_margin_call * entry_price,
                                             NA))

  margin_calls <- which(ohlcv_data$low <= ohlcv_data$margin_call_price)
  ohlcv_data$margin_call <- NA
  if (length(margin_calls) > 0)
    ohlcv_data$margin_call[min(margin_calls)] <- TRUE

  ohlcv_data
}
