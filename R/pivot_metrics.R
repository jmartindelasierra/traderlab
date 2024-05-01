
#' Pivot for metrics
#'
#' @param data Data from metrics().
#'
#' @export
#'
pivot_metrics <- function(data) {

  if (missing(data) || is.null(data))
    stop("'data' not provided.", call. = FALSE)
  if (!is_metric(data))
    stop("Invalid 'data'. It must be metrics data.", call. = FALSE)

  data |>
    tidyr::pivot_wider(id_cols = c("scope", "step"), names_from = "metric", values_from = "value")

}
