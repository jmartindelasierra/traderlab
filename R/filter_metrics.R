
#' Filter for metrics from model run
#'
#' @param data Data from metrics().
#' @param ... Expression for the filter.
#'
#' @export
#'
filter_metrics <- function(data, ...) {

  # Initialization to avoid notes in R CMD check
  step <- NULL

  if (missing(data) || is.null(data))
    stop("'data' not provided.", call. = FALSE)
  if (!is_metric(data))
    stop("Invalid 'data'. It must be metrics data.", call. = FALSE)

  steps <-
    data |>
    tidyr::pivot_wider(id_cols = c("scope", "step"), names_from = "metric", values_from = "value") |>
    dplyr::filter(...) |>
    dplyr::pull(step) |>
    unique()

  data |>
    dplyr::filter(step %in% steps)

}
