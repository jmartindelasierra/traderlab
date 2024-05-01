
#' Profit factor
#'
#' @param returns A vector of returns.
#'
profit_factor <- function(returns) {

  sum(returns[returns > 0]) / abs(sum(returns[returns < 0]))

}
