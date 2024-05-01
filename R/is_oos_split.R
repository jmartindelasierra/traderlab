
#' In-sample out-of-sample percentage split
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
is_oos_split <- function(ohlcv_data, model) {

  # Initialization to avoid notes in R CMD check
  open_time <- close_time <- NULL

  pct_is <-
    (ohlcv_data |>
       dplyr::filter(close_time < model$periods$oos_start) |>
       nrow()) /
    nrow(ohlcv_data)

  pct_oos <-
    (ohlcv_data |>
       dplyr::filter(open_time >= model$periods$oos_start) |>
       nrow()) /
    nrow(ohlcv_data)

  list(pct_is = pct_is, pct_oos = pct_oos)
}
