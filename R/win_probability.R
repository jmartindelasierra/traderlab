
#' Win probability or win rate
#'
#' @param returns A vector with the returns.
#'
win_probability <- function(returns) {

  length(returns[returns > 0]) / length(returns)

}
