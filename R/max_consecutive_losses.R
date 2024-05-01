
#' Maximum consecutive losses
#'
#' @param returns A vector of returns.
#'
max_consecutive_losses <- function(returns) {

  suppressWarnings(
    max(rle(sign(returns))$lengths[rle(sign(returns))$values == -1])
  )

}
