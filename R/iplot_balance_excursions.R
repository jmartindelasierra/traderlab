
#' Plot interactive balance and excursions
#'
#' @param step An integer with the model step to plot.
#'
#' @export
#'
iplot_balance_excursions <- function(step = 1) {

  # Initialization to avoid notes in R CMD check
  time <- entry <- pct_balance0 <- exit <- NULL

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

  oos_start <- balance$time[balance$scope == "oos"][1]
  oos_end <- max(balance$time)

  balance <-
    balance |>
    dplyr::mutate(entry = ifelse(entry == 1, pct_balance0, NA),
                  exit = ifelse(exit == 1, pct_balance0, NA))

  xts::xts(x = balance[, c("entry", "exit", "pct_balance0", "pct_exc_balance0")],
             order.by = as.POSIXct(balance$time)) |>
    dygraphs::dygraph(main = NULL) |>
    dygraphs::dySeries("pct_balance0", "Balance gain [%]", color = "steelblue", strokeWidth = 2, stepPlot = TRUE) |>
    dygraphs::dySeries("pct_exc_balance0", "Excursion [%]", color = "purple", strokeWidth = 2, stepPlot = TRUE) |>
    dygraphs::dySeries("entry", "ENTRY", color = "limegreen", strokeWidth = 0, drawPoints = TRUE, pointSize = 2, pointShape = "dot") |>
    dygraphs::dySeries("exit", "EXIT", color = "red", strokeWidth = 0, drawPoints = TRUE, pointSize = 2, pointShape = "dot") |>
    dygraphs::dyAxis("y", label = "Balance / Excursions [%]", valueFormatter = "function(v){return (v*100).toFixed(1) + '%'}", axisLabelFormatter = "function(v){return (v*100).toFixed(0) + '%'}") |>
    dygraphs::dyEvent(oos_start, "Out-of-sample", labelLoc = "bottom") |>
    dygraphs::dyLegend(show = "follow", labelsSeparateLines = TRUE) |>
    dygraphs::dyOptions(fillGraph = FALSE, fillAlpha = 0.4, drawGrid = TRUE)

}
