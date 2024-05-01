
#' Pivot points
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#'
pivot_points <- function(ohlcv_data) {

  # Initialization to avoid notes in R CMD check
  close_time <- high <- low <- p <- r1 <- r2 <- s1 <- s2 <- NULL

  pivots <-
    ohlcv_data |>
    dplyr::mutate(date = as.Date(close_time)) |>
    dplyr::group_by(date) |>
    dplyr::summarise(high = max(high),
                     low = min(low),
                     close = dplyr::last(close)) |>
    dplyr::mutate(p = (high + low + close) / 3,
                  r1 = (p * 2) - low,
                  r2 = p + (high - low),
                  s1 = (p * 2) - high,
                  s2 = p - (high - low)) |>
    dplyr::select(-high, -low, -close)

  merge(
    ohlcv_data |>
      dplyr::mutate(close_date = as.Date(close_time)),
    pivots,
    by.x = "close_date",
    by.y = "date",
    all = TRUE
  ) |>
    dplyr::select(p, r1, r2, s1, s2)

}
