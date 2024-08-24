
#' Plot balance
#'
#' @param step An integer with the model step to plot.
#' @param show_source A boolean indicating whether or not to plot the data source. If TRUE, the price data from the model will be plotted in a secondary axis.
#'
#' @export
#'
plot_balance <- function(step = 1, show_source = FALSE) {

  # Initialization to avoid notes in R CMD check
  balance0 <- drawdown <- pct_drawdown <- time <- NULL

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

  if (show_source) {

    scale_coef <- max(balance$close) / max(balance$balance)

    p1 <-
      balance |>
      ggplot2::ggplot() +
      ggplot2::geom_rect(ggplot2::aes(xmin = time, xmax = dplyr::lead(time), ymin = 0, ymax = balance0), fill = "skyblue") +
      ggplot2::geom_step(ggplot2::aes(x = time, y = balance0), linewidth = 0.25, color = "black") +
      ggplot2::geom_step(data = balance |> dplyr::mutate(close = close - dplyr::first(close)), ggplot2::aes(x = time, y = close/scale_coef), linewidth = 0.5, color = "orange3") +
      ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
      ggplot2::scale_y_continuous(name = "Balance", labels = scales::dollar, sec.axis = ggplot2::sec_axis(~.*scale_coef, name = "Price", labels = scales::dollar)) +
      ggplot2::theme_bw() +
      ggplot2::theme(axis.title.y.right = ggplot2::element_text(color = "orange3"), axis.text.y.right = ggplot2::element_text(color = "orange3"), axis.line.y.right = ggplot2::element_line(color = "orange3"), axis.ticks.y.right = ggplot2::element_line(color = "orange3")) +
      ggplot2::labs(x = NULL, y = "Balance")

  } else {

    p1 <-
      balance |>
      ggplot2::ggplot() +
      ggplot2::geom_rect(ggplot2::aes(xmin = time, xmax = dplyr::lead(time), ymin = 0, ymax = balance0), fill = "skyblue") +
      ggplot2::geom_step(ggplot2::aes(x = time, y = balance0), linewidth = 0.25, color = "black") +
      ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
      ggplot2::scale_y_continuous(name = "Balance", labels = scales::dollar) +
      ggplot2::theme_bw() +
      ggplot2::labs(x = NULL, y = "Balance")

  }

  p2 <-
    balance |>
    ggplot2::ggplot(ggplot2::aes(x = time)) +
    ggplot2::geom_rect(ggplot2::aes(xmin = time, xmax = dplyr::lead(time), ymin = drawdown, ymax = 0), fill = "indianred") +
    ggplot2::geom_step(ggplot2::aes(x = time, y = drawdown), linewidth = 0.25, color = "black") +
    ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
    ggplot2::scale_y_continuous(labels = scales::dollar) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = NULL, y = "Drawdown")

  p3 <-
    balance |>
    ggplot2::ggplot(ggplot2::aes(x = time)) +
    ggplot2::geom_rect(ggplot2::aes(xmin = time, xmax = dplyr::lead(time), ymin = pct_drawdown, ymax = 0), fill = "indianred") +
    ggplot2::geom_step(ggplot2::aes(x = time, y = pct_drawdown), linewidth = 0.25, color = "black") +
    ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = NULL, y = "Drawdown (%)")

  suppressWarnings({
    cowplot::plot_grid(p1, p2, p3, nrow = 3, align = "v", rel_heights = c(3, 1, 1))
  })
}
