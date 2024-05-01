
#' Check periods coherence
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
check_periods <- function(ohlcv_data, model) {

  if (is.null(model$periods$start)) {
    start_date <- as.Date(ohlcv_data$open_time[1])
  } else {
    start_date <- as.Date(model$periods$start)
  }

  if (is.null(model$periods$end)) {
    end_date <- as.Date(ohlcv_data$close_time[nrow(ohlcv_data)])
  } else {
    end_date <- as.Date(model$periods$end)
  }

  if (start_date >= as.Date(model$periods$oos_start))
    stop("Invalid 'start'. It must be less than 'oos_start'.", call. = FALSE)

  if (end_date <= as.Date(model$periods$oos_start))
    stop("Invalid 'end'. It must be greater than 'oos_start'.", call. = FALSE)

}
