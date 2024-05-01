
#' Maximum consecutive wins
#'
#' @param returns A vector of returns.
#'
max_consecutive_wins <- function(returns) {

  suppressWarnings(
    max(rle(sign(returns))$lengths[rle(sign(returns))$values == 1])
  )

}
