
#' Compute metrics for in-sample
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
get_in_sample_metrics <- function(ohlcv_data, model) {

  # Initialization to avoid notes in R CMD check
  open_time <- NULL

  max_date <- as.character(as.Date(max(ohlcv_data$close_time)))

  os_data <-
    ohlcv_data |>
    dplyr::filter(open_time >= model$periods$oos_start)

  is_ohlc <-
    ohlcv_data |>
    dplyr::filter(!open_time %in% os_data$open_time)

  metrics_list(is_ohlc)

}
