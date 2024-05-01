
#' Daily value of open, maximum high, minimum low or close
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#'
daily_value <- function(ohlcv_data, source) {

  # Initialization to avoid notes in R CMD check
  open_time <- value <- NULL

  ohlcv_data |>
    dplyr::mutate(date = as.Date(open_time)) |>
    dplyr::group_by(date) |>
    dplyr::mutate(value = dplyr::case_when(
      source == "open" ~ dplyr::first(get(source)),
      source == "high" ~ max(get(source)),
      source == "low" ~ min(get(source)),
      source == "close" ~ dplyr::last(get(source)))
    ) |>
    dplyr::pull(value)

}
