
#' Plot balances for best metrics interactively
#'
#' @export
#'
plot_best_metrics_i <- function() {

  # Initialization to avoid notes in R CMD check
  variable <- step <- pct_balance0 <- cagr <- cagr_dd <- max_consec_losses <- pct_dd <- return_dd <- risk_adj_return <- sharpe_ratio <- var <- NULL

  last_run_db_exists()

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))

  metrics <-
    dplyr::tbl(con, "metrics") |>
    dplyr::collect()

  balances <-
    dplyr::tbl(con, "balances") |>
    dplyr::collect()

  DBI::dbDisconnect(con)

  p1 <-
    highcharter::highchart(type = "chart") |>
    highcharter::hc_xAxis(dateTimeLabelFormats = list(day = "%m  %Y"), type = "datetime", crosshair = TRUE) |>
    highcharter::hc_yAxis(labels = list(format = "{value}%"), crosshair = TRUE) |>
    highcharter::hc_tooltip(valueDecimals = 2)

  plot_metric <- function(pl, legend, ...) {

    steps <-
      metrics |>
      dplyr::rename(metric = variable) |>
      filter_is() |>
      filter_metrics(...) |>
      dplyr::pull(step) |>
      unique()

    steps <- steps[1]

    if (!is.na(steps)) {
      balance <-
        balances |>
        dplyr::filter(step == steps)

      bal_xts <-
        xts::xts(balance |>
                   dplyr::mutate(pct_balance0 = pct_balance0 * 100) |>
                   dplyr::select(pct_balance0), as.POSIXct(balance$time, origin = "1970-01-01"))

      pl <-
        pl |>
        highcharter::hc_add_series(bal_xts, type = "line", marker = list(symbol = "circle"), name = glue::glue("{legend} ({steps})"), lineWidth = 0.5, color = "black")
    }

    pl
  }

  p1 <- plot_metric(p1, "CAGR", cagr == max(cagr))
  p1 <- plot_metric(p1, "Profit factor", profit_factor == max(profit_factor))
  p1 <- plot_metric(p1, "Exposure", exposure == min(exposure))
  p1 <- plot_metric(p1, "Risk-adjusted return", risk_adj_return == max(risk_adj_return))
  p1 <- plot_metric(p1, "Consec. losses", max_consec_losses == min(max_consec_losses))
  p1 <- plot_metric(p1, "% drawdown", pct_dd == max(pct_dd))
  p1 <- plot_metric(p1, "CAGR/drawdown", cagr_dd == max(cagr_dd))
  p1 <- plot_metric(p1, "Return/drawdown", return_dd == max(return_dd))
  p1 <- plot_metric(p1, "Sharpe ratio", sharpe_ratio == max(sharpe_ratio))
  p1 <- plot_metric(p1, "R-squared", r_squared == max(r_squared))
  p1 <- plot_metric(p1, "Monthly 5%-VaR", var == max(var))

  p1
}
