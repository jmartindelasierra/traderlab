
#' Daily value of open, maximum high, minimum low or close
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param lag An integer with number of lagged days.
#'
daily_value <- function(ohlcv_data, source, lag = 0) {

  # Initialization to avoid notes in R CMD check
  date_idx <- open_time <- value <- NULL

  daily_values <-
    ohlcv_data |>
    dplyr::mutate(date = as.Date(open_time)) |>
    dplyr::group_by(date) |>
    dplyr::mutate(date_idx = dplyr::cur_group_id(),
                  value = dplyr::case_when(
                    source == "open" ~ dplyr::first(get(source)),
                    source == "high" ~ max(get(source)),
                    source == "low" ~ min(get(source)),
                    source == "close" ~ dplyr::last(get(source)))
    ) |>
    dplyr::ungroup() |>
    dplyr::select(date_idx, value)

  date_indexes <-
    daily_values |>
    dplyr::pull(date_idx) |>
    unique()

  if (lag > 0) {
    date_indexes <-
      date_indexes |>
      utils::head(-lag)
  }

  values <-
    daily_values |>
    dplyr::filter(date_idx %in% date_indexes) |>
    dplyr::pull(value)

  c(rep(NA, nrow(daily_values) - length(values)), values)

}
