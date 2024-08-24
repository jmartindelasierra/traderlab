
#' Plot balance and excursions
#'
#' @param step An integer with the model step to plot.
#'
#' @export
#'
plot_balance_excursions <- function(step = 1) {

  # Initialization to avoid notes in R CMD check
  pct_balance0 <- pct_exc0 <- pct_exc_balance0 <- time <- trade_index <- NULL

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

  p1 <-
    balance |>
    ggplot2::ggplot() +
    #ggplot2::geom_rect(ggplot2::aes(xmin = time, xmax = dplyr::lead(time), ymin = 0, ymax = pct_balance0), fill = "skyblue") +
    ggplot2::geom_step(ggplot2::aes(x = time, y = pct_balance0), linewidth = 0.25, color = "black") +
    ggplot2::geom_line(ggplot2::aes(x = time, y = pct_exc_balance0), color = "purple") +
    ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = NULL, y = "Return, Excursion (abs.) (%)")

  p2 <-
    balance |>
    dplyr::group_by(trade_index) |>
    dplyr::mutate(pct_exc0 = pct_exc_balance0 - dplyr::first(pct_exc_balance0)) |>
    ggplot2::ggplot() +
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.25) +
    ggplot2::geom_step(ggplot2::aes(x = time, y = pct_exc0), color = "purple") +
    ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = NULL, y = "Excursion (abs.) (%)")

  p3 <-
    balance |>
    dplyr::group_by(trade_index) |>
    dplyr::mutate(pct_exc0 = dplyr::first(pct_exc_balance0),
                  pct_exc0 = (pct_exc_balance0 - pct_exc0) / pct_exc0) |>
    ggplot2::ggplot() +
    ggplot2::geom_hline(yintercept = 0, linewidth = 0.25) +
    ggplot2::geom_step(ggplot2::aes(x = time, y = pct_exc0), color = "purple") +
    ggplot2::geom_hline(yintercept = -1, linetype = "dashed", linewidth = 0.2) +
    ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
    ggplot2::scale_y_continuous(labels = scales::percent, limits = c(-1, NA)) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = NULL, y = "Excursion (rel.) (%)") +
    ggplot2::coord_cartesian(ylim = c(NA, 1))

  suppressWarnings({
    cowplot::plot_grid(p1, p2, p3, nrow = 3, align = "v", rel_heights = c(3, 1, 1))
  })
}
