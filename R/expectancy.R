
#' Expectancy
#'
#' @param returns A vector of returns.
#'
expectancy <- function(returns) {

  wp <- win_probability(returns)

  # win_prob * avg_win - loss_prob * avg_loss
  wp * mean(returns[returns > 0]) - (1 - wp) * abs(mean(returns[returns < 0]))
}
