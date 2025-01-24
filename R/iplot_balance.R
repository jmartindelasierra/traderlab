
#' Plot interactive balance
#'
#' @param step An integer with the model step to plot.
#' @param show_source A boolean indicating whether or not to plot the data source. If TRUE, the price data from the model will be plotted in a secondary axis.
#'
#' @export
#'
iplot_balance <- function(step = 1, show_source = FALSE) {

  # Initialization to avoid notes in R CMD check
  time <- NULL

  if (is.null(step))
    stop("'step' must be provided.", call. = FALSE)
  if (!is.numeric(step))
    stop("'step' must be integer.", call. = FALSE)
  if (length(step) > 1)
    stop("'step' must have length 1.", call. = FALSE)
  if (step < 1)
    stop("'step' must be equal or greater than 1.", call. = FALSE)

  step <- as.integer(step)

  last_run_db_exists()

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  balance <-
    dplyr::tbl(con, "balances") |>
    dplyr::filter(step == {{step}}) |>
    dplyr::collect()
  DBI::dbDisconnect(con)

  if (nrow(balance) == 0)
    stop(glue::glue("Unavailable data for the step {step}."), call. = FALSE )

  balance <-
    balance |>
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"))

  balance$linear_trend <-
    seq(balance$balance0[1],
        balance$balance0[nrow(balance)],
        by = balance$balance0[nrow(balance)] / (nrow(balance) - 1))

  oos_start <- balance$time[balance$scope == "oos"][1]
  oos_end <- max(balance$time)

  if (show_source) {

    balance <-
      balance |>
      dplyr::mutate(close = close - dplyr::first(close))

    range1 <- range(balance$balance0)
    range1 <- c(-max(abs(range1)), max(abs(range1)))
    range2 <- range(balance$close)
    range2 <- c(-max(abs(range2)), max(abs(range2)))

    map_to_range2 <- function(x1, range1, range2) {
      range2[1] + (x1 - range1[1]) / (range1[2] - range1[1]) * (range2[2] - range2[1])
    }

    bottom1 <- min(balance$drawdown)
    bottom1 <- bottom1 + 0.2 * bottom1
    bottom2 <- map_to_range2(bottom1, range1, range2)

    range1[1] <- bottom1
    range2[1] <- bottom2

    xts::xts(x = balance[, c("close", "balance0", "drawdown", "pct_drawdown", "linear_trend")],
               order.by = as.POSIXct(balance$time)) |>
      dygraphs::dygraph(main = NULL) |>
      dygraphs::dySeries("balance0", "Balance", color = "steelblue", strokeWidth = 2, stepPlot = TRUE) |>
      dygraphs::dySeries("drawdown", "Drawdown", color = "indianred", strokeWidth = 2, stepPlot = TRUE) |>
      dygraphs::dySeries("close", "Rel. price", color = "black", strokeWidth = 1, axis = "y2", stepPlot = TRUE) |>
      dygraphs::dySeries("linear_trend", "Linear trend", color = "lightgray", strokeWidth = 1, axis = "y") |>
      dygraphs::dyAxis("y", label = "Balance / Drawdown", valueFormatter = "function(v){return '$' + (v).toFixed(2)}", axisLabelFormatter = "function(v){return '$' + (v).toFixed(0)}", valueRange = range1) |>
      dygraphs::dyAxis("y2", label = "Relative price", valueFormatter = "function(v){return '$' + (v).toFixed(2)}", axisLabelFormatter = "function(v){return '$' + (v).toFixed(0)}", valueRange = range2) |>
      dygraphs::dyEvent(oos_start, "Out-of-sample", labelLoc = "bottom") |>
      dygraphs::dyLegend(show = "follow", labelsSeparateLines = TRUE) |>
      dygraphs::dyOptions(fillGraph = TRUE, fillAlpha = 0.4, drawGrid = TRUE)

  } else {

    xts::xts(x = balance[, c("balance0", "drawdown", "pct_drawdown", "linear_trend")],
               order.by = as.POSIXct(balance$time)) |>
      dygraphs::dygraph(main = NULL) |>
      dygraphs::dySeries("balance0", "Balance", color = "steelblue", strokeWidth = 2, stepPlot = TRUE) |>
      dygraphs::dySeries("drawdown", "Drawdown", color = "indianred", strokeWidth = 2, stepPlot = TRUE) |>
      dygraphs::dySeries("pct_drawdown", "Drawdown [%]", color = "indianred", strokeWidth = 1, axis = "y2", stepPlot = TRUE) |>
      dygraphs::dySeries("linear_trend", "Linear trend", color = "lightgray", strokeWidth = 1, axis = "y") |>
      dygraphs::dyAxis("y", label = "Balance / Drawdown [$]", valueFormatter = "function(v){return '$' + (v).toFixed(2)}", axisLabelFormatter = "function(v){return '$' + (v).toFixed(0)}") |>
      dygraphs::dyAxis("y2", label = "Drawdown [%]", valueFormatter = "function(v){return (v*100).toFixed(1) + '%'}", axisLabelFormatter = "function(v){return (v*100).toFixed(0) + '%'}") |>
      dygraphs::dyEvent(oos_start, "Out-of-sample", labelLoc = "bottom") |>
      dygraphs::dyLegend(show = "follow", labelsSeparateLines = TRUE) |>
      dygraphs::dyOptions(fillGraph = TRUE, fillAlpha = 0.4, drawGrid = TRUE)

  }

}
