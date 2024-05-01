
#' Check if model timeframe matches OHLCV timeframe
#'
#' @param model An R object with model.
#' @param ohlcv_data A data.frame with OHLCV data.
#'
#' @return If timeframes mismatch a console warning is shown.
#'
check_timeframe <- function(model, ohlcv_data) {

  model_minutes <-
    switch(tolower(model$description$timeframe),
           "5m" = 5,
           "15m" = 15,
           "30m" = 30,
           "1h" = 60,
           "4h" = 240,
           "8h" = 480,
           "12h" = 720,
           "1d" = 1440,
           "1s" = 10080)

  ohlc_minutes <-
    difftime(ohlcv_data$close_time[2], ohlcv_data$close_time[1], units = "mins") |>
    as.integer()

  if (model_minutes != ohlc_minutes)
    message("Warning: model and data timeframes mismatch.")

}
