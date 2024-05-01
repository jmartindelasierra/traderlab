
#' Signals
#'
#' @param data A data.frame with balance data.
#' @param step A integer with the model step to get timings.
#'
#' @export
#'
signals <- function(data, step) {

  # Initialization to avoid notes in R CMD check
  entry <- entries <- exit <- exits <- scope <- trade <- trading <- bars <- NULL

  if (missing(data) || is.null(data))
    stop("'data' not provided.", call. = FALSE)

  is_balance(data)

  if (missing(step) || is.null(step))
    stop("'step' not provided.", call. = FALSE)
  if (!is.numeric(step))
    stop("'step' must be numeric.", call. = FALSE)

  step <- as.integer(step)

  total_entries <-
    data |>
    dplyr::filter(step == {{step}}) |>
    dplyr::summarise(entries = sum(entry)) |>
    dplyr::pull(entries)

  total_exits <-
    data |>
    dplyr::filter(step == {{step}}) |>
    dplyr::summarise(exits = sum(exit)) |>
    dplyr::pull(exits)

  scope_signals <-
    data |>
    dplyr::filter(step == {{step}}) |>
    dplyr::group_by(scope) |>
    dplyr::summarise(entries = sum(entry),
                     exits = sum(exit)) |>
    dplyr::mutate(p_entries = entries / sum(entries),
                  p_exits = exits / sum(exits)) |>
    dplyr::ungroup() |>
    data.frame()

  exposure <-
    data |>
    dplyr::filter(step == {{step}}) |>
    dplyr::summarise(bars = dplyr::n(),
                     trading = sum(trade)) |>
    dplyr::mutate(p_trading = trading / bars) |>
    data.frame()

  avg_bars <- avg_bars_per_trade(data)

  avg_duration <-
    lubridate::interval(data$time[1], data$time[2]) |>
    lubridate::as.duration()

  avg_duration <- avg_duration * avg_bars

  list(total_entries = total_entries,
       total_exits = total_exits,
       scope = scope_signals,
       exposure = exposure,
       avg_bars = avg_bars,
       avg_duration = avg_duration)
}
