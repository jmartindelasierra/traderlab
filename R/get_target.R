
#' Get the value of the metric indicated in target
#'
#' @param model An R object with model.
#' @param metrics A data.frame with metrics.
#'
get_target <- function(model, metrics) {

  # Initialization to avoid notes in R CMD check
  variable <- value <- NULL

  scope <- model$target$scope
  metric <- model$target$metric

  metrics <-
    metrics |>
    dplyr::filter(scope == {{scope}},
                  variable == {{metric}}) |>
    dplyr::pull(value)

  if (length(metrics) == 0)
    stop("Invalid value for 'metric' in target.", call. = FALSE)

  metrics
}
