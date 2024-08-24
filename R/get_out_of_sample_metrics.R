
#' Compute metrics for out-of-sample
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
get_out_of_sample_metrics <- function(ohlcv_data, model) {

  # Initialization to avoid notes in R CMD check
  open_time <- NULL

  oos_start <- model$periods$oos_start

  oos_data <-
    ohlcv_data |>
    dplyr::filter(open_time >= oos_start)

  metrics_list(oos_data)

}
