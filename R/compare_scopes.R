
#' Print metrics in three scope comparable columns
#'
#' @param data A data.frame with metrics data.
#'
#' @export
#'
compare_scopes <- function(data) {

  # Initialization to avoid notes in R CMD check
  i <- scope.x <- scope.y <- scope <- NULL

  if (missing(data) || is.null(data))
    stop("'data' not provided.", call. = FALSE)
  if (is.null(data$step))
    stop("Invalid 'data'. It must be metrics.", call. = FALSE)
  if (length(unique(data$step)) > 1)
    stop("More than one step to compare.", call. = FALSE)

  step <- unique(data$step)

  data <-
    data |>
    filter_step(step)

  merge(data |> filter_scope("is") |> dplyr::mutate(i = 1:dplyr::n()),
        data |> filter_scope("oos"),
        by = c("step", "metric")) |>
    dplyr::select(-scope.x, -scope.y) |>
    merge(data |> filter_scope("full"),
          by = c("step", "metric")) |>
    dplyr::arrange(i) |>
    dplyr::select(-scope, -i) |>
    stats::setNames(c("step", "metric", "is", "oos", "full")) |>
    tibble::as_tibble()

}
