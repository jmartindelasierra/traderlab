
#' Plot interactive portfolio balance
#'
#' @param pf_data Portfolio data from run_portfolio.
#'
#' @export
#'
iplot_portfolio_balance <- function(pf_data) {

  # Initialization to avoid notes in R CMD check
  total_balance <- total_drawdown <- NULL

  if (is.null(pf_data))
    stop("'pf_data' must be provided.", call. = FALSE)

  pf_data$total_balance <-
    pf_data$total_balance |>
    dplyr::rename("Total balance" = total_balance, "Total drawdown" = total_drawdown)

  cols <- names(pf_data$total_balance)[-1]

  xts::xts(x = pf_data$total_balance[, cols],
           order.by = as.POSIXct(pf_data$total_balance$time)) |>
    dygraphs::dygraph(main = NULL) |>
    dygraphs::dySeries() |>
    dygraphs::dyAxis("y", label = "Balance", valueFormatter = "function(v){return (v*100).toFixed(1) + '%'}", axisLabelFormatter = "function(v){return (v*100).toFixed(0) + '%'}") |>
    dygraphs::dyLegend(show = "follow", labelsSeparateLines = TRUE) |>
    dygraphs::dyHighlight() |>
    dygraphs::dyOptions(fillGraph = FALSE, fillAlpha = 0.4, drawGrid = TRUE, stepPlot = TRUE, strokeWidth = 2)

}
