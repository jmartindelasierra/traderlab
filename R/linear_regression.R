
#' Linear regression for last periods of source
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param source A string with input source.
#' @param periods An integer with number of periods.
#'
#' @return This function returns 'fit', 'lwr', 'upr' and 'slope' series.
#'
linear_regression <- function(ohlcv_data, source, periods) {

  suppressWarnings({
    reg <-
      slider::slide(.x = ohlcv_data |> dplyr::mutate(i = 1:dplyr::n()),
                    .f = ~.x,
                    .before = periods - 1) |>
      lapply(function(x) {
        model <- stats::lm(get(source) ~ i, data = x)

        estimates <-
          model |>
          stats::predict(interval = "confidence") |>
          utils::tail(1)

        slope <-
          stats::coef(model)[2]

        names(slope) <- "slope"

        cbind(estimates, slope)
      })
  })

  do.call("rbind", reg) |>
    as.data.frame()

}
