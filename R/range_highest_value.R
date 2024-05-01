
#' Maximum price value in a hour range (support)
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param start An integer with start hour.
#' @param end An integer with end hour.
#'
#' @return This function returns the maximum 'source' in a hour range.
#'
range_highest_value <- function(ohlcv_data, source, start, end) {

  # Initialization to avoid notes in R CMD check
  close_time <- highest <- NULL

  highest_value <-
    ohlcv_data |>
    dplyr::mutate(date = as.Date(close_time),
                  hour = format(close_time, "%H") |> as.integer(),
                  source = ifelse(hour >= start & hour <= end, get(source), NA)) |>
    dplyr::group_by(date) |>
    dplyr::mutate(highest = slider::slide_max(source, before = 23, complete = FALSE, na_rm = TRUE),
                  highest = ifelse(highest == -Inf, NA, highest)) |>
    dplyr::pull(highest)

  zoo::na.locf0(highest_value)

}
