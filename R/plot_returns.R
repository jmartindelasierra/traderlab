
#' Plot returns
#'
#' @param step A integer with the model step to plot.
#'
#' @export
#'
plot_returns <- function(step = 1) {

  # Initialization to avoid notes in R CMD check
  time <- exit <- color <- balance_end <- balance_start <- roc <- year <- NULL

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

  balance <-
    balance |>
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"),
                  color = ifelse(pct_return > 0, "forestgreen", "indianred"))

  mean_pct_return <-
    balance |>
    dplyr::filter(exit == 1) |>
    dplyr::pull(pct_return) |>
    mean(na.rm = TRUE)

  p1 <-
    balance |>
    dplyr::filter(exit == 1) |>
    ggplot2::ggplot(ggplot2::aes(x = time)) +
    ggplot2::geom_point(ggplot2::aes(y = pct_return, color = color)) +
    ggplot2::geom_hline(yintercept = mean_pct_return) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::scale_color_identity() +
    ggplot2::theme_bw() +
    ggplot2::labs(title = "Per trade", subtitle = glue::glue("Mean {round(mean_pct_return * 100, 2)}%"), x = NULL, y = "Return (%)")

  p2 <-
    balance |>
    dplyr::filter(exit == 1) |>
    ggplot2::ggplot(ggplot2::aes(x = pct_return)) +
    ggplot2::geom_histogram(ggplot2::aes(fill = color), bins = 30, boundary = 0) +
    ggplot2::geom_vline(xintercept = mean_pct_return) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::scale_fill_identity() +
    ggplot2::theme_bw() +
    ggplot2::labs(title = "Per trade distribution", subtitle = glue::glue("Mean {round(mean_pct_return * 100, 2)}%"), x = "Return (%)", y = "Trades")

  mean_monthly_pct_return <-
    balance |>
    # dplyr::filter(!is.na(pct_return)) |>
    dplyr::mutate(month = as.POSIXct(paste0(format(time, "%Y-%m"), "-01"))) |>
    dplyr::group_by(month) |>
    # Balance % change != cumulative return
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance)) |>
    dplyr::mutate(roc = (balance_end - balance_start) / balance_start) |>
    # dplyr::summarise(returns = tail(cumprod(pct_return + 1) - 1, 1)) |>
    dplyr::pull(roc) |>
    mean(na.rm = TRUE)

  p3 <-
    balance |>
    # dplyr::filter(!is.na(pct_return)) |>
    dplyr::mutate(month = as.POSIXct(paste0(format(time, "%Y-%m"), "-01"))) |>
    dplyr::group_by(month) |>
    # Balance % change != cumulative return
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance)) |>
    dplyr::mutate(roc = (balance_end - balance_start) / balance_start) |>
    # dplyr::summarise(returns = tail(cumprod(pct_return + 1) - 1, 1)) |>
    dplyr::mutate(color = ifelse(roc >= 0, "forestgreen", "indianred")) |>
    ggplot2::ggplot(ggplot2::aes(x = month)) +
    ggplot2::geom_col(ggplot2::aes(y = roc, fill = color), show.legend = FALSE) +
    ggplot2::geom_hline(yintercept = mean_monthly_pct_return) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::scale_fill_identity() +
    ggplot2::theme_bw() +
    ggplot2::labs(title = "Monthly", subtitle = glue::glue("Mean {round(mean_monthly_pct_return * 100, 2)}%"), x = NULL, y = "Balance ROC (%)")

  mean_annual_pct_return <-
    balance |>
    # dplyr::filter(!is.na(pct_return)) |>
    dplyr::mutate(year = format(time, "%Y")) |>
    dplyr::group_by(year) |>
    # Balance % change != cumulative return
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance)) |>
    dplyr::mutate(roc = (balance_end - balance_start) / balance_start) |>
    # dplyr::summarise(returns = tail(cumprod(pct_return + 1) - 1, 1)) |>
    dplyr::pull(roc) |>
    mean(na.rm = TRUE)

  p4 <-
    balance |>
    # dplyr::filter(!is.na(pct_return)) |>
    dplyr::mutate(year = format(time, "%Y")) |>
    dplyr::group_by(year) |>
    # Balance % change != cumulative return
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance)) |>
    dplyr::mutate(roc = (balance_end - balance_start) / balance_start) |>
    # dplyr::summarise(returns = tail(cumprod(pct_return + 1) - 1, 1)) |>
    dplyr::mutate(color = ifelse(roc >= 0, "forestgreen", "indianred")) |>
    ggplot2::ggplot(ggplot2::aes(x = year)) +
    ggplot2::geom_col(ggplot2::aes(y = roc, fill = color), show.legend = FALSE) +
    ggplot2::geom_hline(yintercept = mean_annual_pct_return) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::scale_fill_identity() +
    ggplot2::theme_bw() +
    ggplot2::labs(title = "Annual", subtitle = glue::glue("Mean {round(mean_annual_pct_return * 100, 2)}%"), x = NULL, y = "Balance ROC (%)")

  cowplot::plot_grid(p1, p2, p3, p4, nrow = 2, ncol = 2, align = "vh")
}
