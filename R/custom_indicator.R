
#' Custom calculations for new indicator
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param expression Expression with the calculations on existing features.
#'
custom_indicator <- function(ohlcv_data, expression) {

  tryCatch({
    expr_parsed <- parse(text = expression)
    custom <- with(ohlcv_data, eval(expr_parsed))
  },
  warning = function(w) stop("'expression' could not be evaluated.", call. = FALSE),
  error = function(e) stop("'expression' could not be evaluated.", call. = FALSE)
  )

  custom
}
