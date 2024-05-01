
#' Add the indicators defined in the model to OHLCV data
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
#' @return This function returns an updated OHLCV data with indicators.
#'
add_indicators <- function(ohlcv_data, model) {

  indicators <- get_indicators(model)
  indicator_names <- names(indicators)

  lapply(indicator_names, function(name) {

    indicator_params <- indicators[[name]]

    indicator <-
      indicator_params[names(indicator_params) == "indicator"] |>
      unlist() |>
      unname()

    indicator_params <- indicator_params[names(indicator_params) != "indicator"]
    indicator_params$name <- name

      ohlcv_data <<-
        do.call(
          function(ind = indicator, ...) {
            tryCatch({
              add_indicator(ohlcv_data, indicator = get(ind), ...)
            },
            error = function(e) { stop(glue::glue("Failed to add {ind} indicator."), call. = FALSE) })
          },
          indicator_params)

  })

  do.call(data.frame, ohlcv_data)
}
