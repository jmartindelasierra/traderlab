
#' Filter by the in-sample scope for metrics from model run
#'
#' @param data Data from metrics().
#'
#' @export
#'
filter_is <- function(data) {

  # Initialization to avoid notes in R CMD check
  scope <- NULL

  if (missing(data) || is.null(data))
    stop("'data' not provided.", call. = FALSE)

  if (is.null(data$scope))
    stop("'data' must have 'scope' feature.", call. = FALSE)

  data |>
    tidyr::pivot_wider(id_cols = c("scope", "step"), names_from = "metric", values_from = "value") |>
    dplyr::filter(scope == "is")

  invisible(
    data |>
      dplyr::filter(scope == "is")
  )

}
