
#' Filter by the specified step
#'
#' @param data A data.frame with step feature in it.
#' @param step An integer with the step to filter.
#'
#' @export
#'
filter_step <- function(data, step) {

  if (missing(data) || is.null(data))
    stop("'data' not provided.", call. = FALSE)

  if (missing(step) || is.null(step))
    stop("'step' not provided.", call. = FALSE)
  if (!is.numeric(step))
    stop("'step' must be numeric.", call. = FALSE)
  if (length(step) > 1)
    stop("'step' must have length 1.", call. = FALSE)

  step <- as.integer(step)

  if (!is.null(data$step)) {
    data |>
      dplyr::filter(step == {{step}})
  } else {
    stop("'data' must have 'step' feature.", call. = FALSE)
  }

}
