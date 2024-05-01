
#' Win to loss ratio
#'
#' @param returns A vector with the returns.
#'
#' @return The function returns the number of wins divided by the number of losses.
#'
win_loss_ratio <- function(returns) {

  length(returns[returns > 0]) / length(returns[returns < 0])

}
