
#' Sort metrics
#'
#' @param data Metrics data from metrics().
#' @param ... Variable to sort.
#'
#' @export
#'
sort_metrics <- function(data, ...) {

  if (missing(data) || is.null(data))
    stop("'data' not provided.", call. = FALSE)

  if (is_metric(data)) {
    data <-
      data |>
      tidyr::pivot_wider(id_cols = c("scope", "step"), names_from = "metric", values_from = "value")
  }

  data |>
    dplyr::arrange(...)

}
