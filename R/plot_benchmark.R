
#' Plot a comparison of the specified step in model with the Buy & Hold strategy
#'
#' @param step n integer with the balance step to plot.
#'
#' @export
#'
plot_benchmark <- function(step = 1) {

  # Initialization to avoid notes in R CMD check
  time <- pct_balance0 <- pct_balance_bh <- above <- year <- balance_end <- balance_start <- balance_end_bh <- balance_start_bh <- roc_trading <- roc_bh <- pct_drawdown <- NULL

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
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"))

  oos_start <- balance$time[balance$scope == "oos"][1]
  oos_end <- max(balance$time)

  balance <-
    balance |>
    dplyr::mutate(pct_balance_bh = (close - dplyr::first(close)) / dplyr::first(close))

  drawdown_bh <- vector("numeric", nrow(balance))
  pct_drawdown_bh <- vector("numeric", nrow(balance))

  balance$drawdown_bh <- 0
  balance$pct_drawdown_bh <- 0
  max_price <- 0

  for (i in 1:nrow(balance)) {

    if (balance$close[i] > max_price) {

      max_price <- balance$close[i]

    } else {

      drawdown_bh[i] <- balance$close[i] - max_price
      pct_drawdown_bh[i] <- drawdown_bh[i] / max_price

    }

  }

  balance$drawdown_bh <- drawdown_bh
  balance$pct_drawdown_bh <- pct_drawdown_bh

  pct_above <-
    balance |>
    dplyr::mutate(above = pct_balance0 > pct_balance_bh) |>
    dplyr::summarise(pct_above = sum(above) / length(above)) |>
    as.numeric()

  returns_corr <-
    stats::ccf(balance$pct_balance_bh,
               balance$pct_balance0,
               plot = FALSE)

  returns_corr <- returns_corr$acf[which(returns_corr$lag == 0)]

  monthly_returns <-
    balance |>
    dplyr::mutate(year_month = format(time, "%Y-%m")) |>
    dplyr::group_by(year_month) |>
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance),
                     balance_start_bh = dplyr::first(close),
                     balance_end_bh = dplyr::last(close)) |>
    dplyr::mutate(roc_trading = (balance_end - balance_start) / balance_start,
                  roc_bh = (balance_end_bh - balance_start_bh) / balance_start_bh)

  monthly_returns_corr <-
    monthly_returns |>
    dplyr::select(year_month, roc_trading, roc_bh) |>
    with(cor(roc_trading, roc_bh))

  annual_returns <-
    balance |>
    dplyr::mutate(year = format(time, "%Y")) |>
    dplyr::group_by(year) |>
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance),
                     balance_start_bh = dplyr::first(close),
                     balance_end_bh = dplyr::last(close)) |>
    dplyr::mutate(roc_trading = (balance_end - balance_start) / balance_start,
                  roc_bh = (balance_end_bh - balance_start_bh) / balance_start_bh)

  annual_returns_corr <-
    annual_returns |>
    dplyr::select(year, roc_trading, roc_bh) |>
    with(cor(roc_trading, roc_bh))

  p1 <-
    balance |>
    ggplot2::ggplot() +
    ggplot2::geom_line(ggplot2::aes(x = time, y = pct_balance_bh, color = "Buy & Hold"), linewidth = 0.7) +
    ggplot2::geom_step(ggplot2::aes(x = time, y = pct_balance0, color = "Trading"), linewidth = 0.7) +
    ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::scale_color_manual(values = c("Trading" = "steelblue", "Buy & Hold" = "orange2")) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = NULL, y = "Return (%)", color = "Model", caption = glue::glue("Above B&H: {round(pct_above * 100, 1)}%. Monthly balance correlation: {round(monthly_returns_corr, 2)}. Annual balance correlation: {round(annual_returns_corr, 2)}"))

  # p2 <-
  #   merge(ohlcv_data |> dplyr::select(time = close_time, pct_bh),
  #         balance |> dplyr::select(time, pct_balance),
  #         by = "time") |>
  #   dplyr::mutate(excess = pct_balance - pct_bh) |>
  #   ggplot2::ggplot() +
  #   ggplot2::geom_line(ggplot2::aes(x = time, y = excess), linewidth = 0.7) +
  #   ggplot2::geom_hline(yintercept = 0, linetype = "dashed", linewidth = 0.7) +
  #   ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
  #   ggplot2::scale_y_continuous(labels = scales::percent) +
  #   ggplot2::theme_bw() +
  #   ggplot2::labs(x = NULL, y = "Excess")

  p3 <-
    balance |>
    ggplot2::ggplot() +
    ggplot2::geom_line(ggplot2::aes(x = time, y = pct_drawdown_bh, color = "Buy & Hold"), linewidth = 0.7) +
    ggplot2::geom_step(ggplot2::aes(x = time, y = pct_drawdown, color = "Trading"), linewidth = 0.7) +
    ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "forestgreen", alpha = 0.2) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::scale_color_manual(values = c("Trading" = "steelblue", "Buy & Hold" = "orange2")) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = NULL, y = "Drawdown (%)", color = "Model")

  # balance |>
  #   dplyr::mutate(year = format(time, "%Y")) |>
  #   dplyr::group_by(year) |>
  #   dplyr::summarise(balance_start = dplyr::first(balance),
  #                    balance_end = dplyr::last(balance),
  #                    balance_start_bh = dplyr::first(close),
  #                    balance_end_bh = dplyr::last(close)) |>
  #   dplyr::mutate(roc_trading = (balance_end - balance_start) / balance_start,
  #                 roc_bh = (balance_end_bh - balance_start_bh) / balance_start_bh) |>
  #   dplyr::select(year, roc_trading, roc_bh) |>
  #   tidyr::pivot_longer(cols = c(roc_trading, roc_bh)) |>
  #   ggplot2::ggplot() +
  #   ggplot2::geom_col(ggplot2::aes(x = year, y = value, fill = name), position = "dodge") +
  #   ggplot2::scale_y_continuous(labels = scales::percent) +
  #   ggplot2::scale_fill_manual(values = c("roc_trading" = "steelblue", "roc_bh" = "orange2")) +
  #   ggplot2::theme_bw() +
  #   ggplot2::labs(x = NULL, y = "Annual return (%)")

  suppressWarnings({
    cowplot::plot_grid(p1, p3, nrow = 2, align = "v", rel_heights = c(3, 1))
  })
}
