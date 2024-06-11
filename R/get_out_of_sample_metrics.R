
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

  # Recompute balance and drawdown before calculation of OOS metrics
  oos_data$balance <- (oos_data$balance - oos_data$balance[1]) + ohlcv_data$balance[1]
  if (sum(oos_data$balance < 0) >= 1)
    oos_data$balance[min(which(oos_data$balance < 0)):length(oos_data$balance)] <- 0
  oos_data <- compute_drawdown(oos_data)

  metrics_list(oos_data)

}
