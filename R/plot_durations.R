
#' Plot durations
#'
#' @param step A integer with the model step to plot.
#'
#' @export
#'
plot_durations <- function(step) {

  # Initialization to avoid notes in R CMD check
  time <- exit <- bars_from_entry <- color <- year <- NULL

  if (missing(step) || is.null(step))
    stop("'step' must be provided.", call. = FALSE)
  if (!is.numeric(step))
    stop("'step' must be numeric.", call. = FALSE)
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

  balance <-
    balance |>
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"),
                  color = ifelse(pct_return > 0, "forestgreen", "indianred"))

  mean_bars <-
    balance |>
    dplyr::filter(exit == 1) |>
    dplyr::pull(bars_from_entry) |>
    mean(na.rm = TRUE)

  p1 <-
    balance |>
    dplyr::filter(exit == 1) |>
    ggplot2::ggplot(ggplot2::aes(x = time)) +
    ggplot2::geom_point(ggplot2::aes(y = bars_from_entry, color = color)) +
    ggplot2::geom_hline(yintercept = mean_bars) +
    ggplot2::scale_color_identity() +
    ggplot2::theme_bw() +
    ggplot2::labs(title = "Per trade", subtitle = glue::glue("Mean {round(mean_bars, 1)}"), x = NULL, y = "Duration (bars)")

  p2 <-
    balance |>
    dplyr::filter(exit == 1) |>
    ggplot2::ggplot(ggplot2::aes(x = bars_from_entry)) +
    ggplot2::geom_histogram(bins = 30, fill = "steelblue", boundary = 0) +
    ggplot2::geom_vline(xintercept = mean_bars) +
    ggplot2::scale_fill_identity() +
    ggplot2::theme_bw() +
    ggplot2::labs(title = "Per trade distribution", subtitle = glue::glue("Mean {round(mean_bars, 1)}"), x = "Duration (bars)", y = "Trades")

  mean_monthly_bars <-
    balance |>
    dplyr::mutate(month = as.POSIXct(paste0(format(time, "%Y-%m"), "-01"))) |>
    dplyr::filter(exit == 1) |>
    dplyr::group_by(month) |>
    dplyr::summarise(mean_bars = mean(bars_from_entry)) |>
    dplyr::pull(mean_bars) |>
    mean(na.rm = TRUE)

  p3 <-
    balance |>
    dplyr::mutate(month = as.POSIXct(paste0(format(time, "%Y-%m"), "-01"))) |>
    dplyr::filter(exit == 1) |>
    dplyr::group_by(month) |>
    dplyr::summarise(mean_bars = mean(bars_from_entry)) |>
    ggplot2::ggplot(ggplot2::aes(x = month)) +
    ggplot2::geom_col(ggplot2::aes(y = mean_bars), fill = "steelblue", show.legend = FALSE) +
    ggplot2::geom_hline(yintercept = mean_monthly_bars) +
    ggplot2::theme_bw() +
    ggplot2::labs(title = "Monthly", subtitle = glue::glue("Mean {round(mean_monthly_bars, 1)}"), x = NULL, y = "Duration (bars)")

  mean_annual_bars <-
    balance |>
    dplyr::mutate(year = format(time, "%Y")) |>
    dplyr::filter(exit == 1) |>
    dplyr::group_by(year) |>
    dplyr::summarise(mean_bars = mean(bars_from_entry)) |>
    dplyr::pull(mean_bars) |>
    mean(na.rm = TRUE)

  p4 <-
    balance |>
    dplyr::mutate(year = format(time, "%Y")) |>
    dplyr::filter(exit == 1) |>
    dplyr::group_by(year) |>
    dplyr::summarise(mean_bars = mean(bars_from_entry)) |>
    ggplot2::ggplot(ggplot2::aes(x = year)) +
    ggplot2::geom_col(ggplot2::aes(y = mean_bars), fill = "steelblue", show.legend = FALSE) +
    ggplot2::geom_hline(yintercept = mean_annual_bars) +
    ggplot2::theme_bw() +
    ggplot2::labs(title = "Annual", subtitle = glue::glue("Mean {round(mean_annual_bars, 1)}"), x = NULL, y = "Duration (bars)")

  cowplot::plot_grid(p1, p2, p3, p4, nrow = 2, ncol = 2, align = "vh")
}
