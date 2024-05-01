
#' Filter balances or metrics data by scope
#'
#' @param data A data.frame with balances or metrics data.
#' @param scope A string with scope 'full', 'is' or 'oos'.
#'
filter_scope <- function(data, scope) {

  data |>
    dplyr::filter(scope == {{scope}})

}
