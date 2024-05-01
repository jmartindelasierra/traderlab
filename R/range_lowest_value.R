
#' Minimum price value in a hour range (resistance)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param start An integer with start hour.
#' @param end An integer with end hour.
#'
#' @return This function returns the minimum 'source' in a hour range.
#'
range_lowest_value <- function(ohlcv_data, source, start, end) {

  # Initialization to avoid notes in R CMD check
  close_time <- lowest <- NULL

  lowest_value <-
    ohlcv_data |>
    dplyr::mutate(date = as.Date(close_time),
                  hour = format(close_time, "%H") |> as.integer(),
                  source = ifelse(hour >= start & hour <= end, get(source), NA)) |>
    dplyr::group_by(date) |>
    dplyr::mutate(lowest = slider::slide_min(source, before = 23, complete = FALSE, na_rm = TRUE),
                  lowest = ifelse(lowest == -Inf, NA, lowest)) |>
    dplyr::pull(lowest)

  zoo::na.locf0(lowest_value)

}
