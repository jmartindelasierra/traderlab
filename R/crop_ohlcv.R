
#' Crop OHLCV data according to start and end periods
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
crop_ohlcv <- function(ohlcv_data, model) {

  # Initialization to avoid notes in R CMD check
  open_time <- close_time <- NULL

  if (!is.null(model$periods$start))
    ohlcv_data <-
      ohlcv_data |>
      dplyr::filter(as.Date(open_time) >= as.Date(model$periods$start))

  if (!is.null(model$periods$end))
    ohlcv_data <-
      ohlcv_data |>
      dplyr::filter(as.Date(close_time) <= as.Date(model$periods$end))

  ohlcv_data
}
