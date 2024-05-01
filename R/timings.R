
#' Total timing and per scope
#'
#' @param data A data.frame with balance data.
#'
#' @export
#'
timings <- function(data) {

  # Initialization to avoid notes in R CMD check
  step <- time <- start <- end <- scope <- bars <- NULL

  if (missing(data) || is.null(data))
    stop("'data' not provided.", call. = FALSE)

  if (!is_balance(data))
    stop("Invalid data.", call. = FALSE)

  total_time <-
    data |>
    dplyr::filter(step == min(step)) |>
    dplyr::summarise(start = dplyr::first(time),
                     end = dplyr::last(time)) |>
    dplyr::mutate(duration = lubridate::interval(start, end) |>
                    lubridate::as.period()) |>
    data.frame()

  scope_time <-
    merge(
      data |>
        dplyr::group_by(scope) |>
        dplyr::summarise(start = dplyr::first(time),
                         end = dplyr::last(time)) |>
        dplyr::mutate(duration = lubridate::interval(start, end) |>
                        lubridate::as.period()),
      data |>
        dplyr::filter(step == data$step[1]) |>
        dplyr::count(scope, name = "bars") |>
        dplyr::mutate(p = bars / sum(bars)),
      by = "scope"
    )

  list(total_time = total_time,
       scope_time = scope_time)
}
