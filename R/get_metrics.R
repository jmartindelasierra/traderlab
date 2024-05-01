
#' Get full-sample, in-sample and out-of-sample metrics
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
#' @return The function returns a list of three elements.
#'
get_metrics <- function(ohlcv_data, model) {

  full_sample_metrics <- get_full_sample_metrics(ohlcv_data)

  if (!is.null(model$periods$oos_start))
    in_sample_metrics <- get_in_sample_metrics(ohlcv_data, model)

  if (!is.null(model$periods$oos_start))
    out_of_sample_metrics <- get_out_of_sample_metrics(ohlcv_data, model)

  metrics <-
    list(
      full_sample_metrics = full_sample_metrics
    )

  if (!is.null(model$periods$oos_start))
    metrics[["in_sample_metrics"]] <- in_sample_metrics

  if (!is.null(model$periods$oos_start))
    metrics[["out_of_sample_metrics"]] <- out_of_sample_metrics

  metrics
}
