
#' Plot Monte Carlo simulations
#'
#' @param step An integer with a valid step in balances.
#' @param scope A string for the scope taking "is" (in-sample) or "oos" (out-of-sample). Default "is".
#' @param samples An integer with the number of iterations. Default 500.
#' @param replace Logical value for resampling with or without replacement. Default TRUE.
#' @param oos_zoom Logical value for zooming out-of-sample region. Default TRUE.
#' @param verbose Logical value for showing the progress. Default TRUE.
#'
#' @export
#'
plot_monte_carlo <- function(step, scope = "is", samples = 500, replace = TRUE, oos_zoom = FALSE, verbose = TRUE) {

  # Initialization to avoid notes in R CMD check
  time <- .lower <- .upper <- variable <- value <- NULL

  if (missing(step) || is.null(step))
    stop("'step' must be provided.", call. = FALSE)
  if (!is.numeric(step))
    stop("'step' must be numeric.", call. = FALSE)
  if (length(step) > 1)
    stop("'step' must have length 1.", call. = FALSE)
  if (step < 1)
    stop("'step' must be equal or greater than 1.", call. = FALSE)

  step <- as.integer(step)

  if (is.null(scope))
    stop("'scope' must be provided.", call. = FALSE)
  if (!scope %in% c("is", "oos"))
    stop("'scope' must be either 'is' or 'oos'.", call. = FALSE)

  if (is.null(samples))
    stop("'samples' must be provided.", call. = FALSE)
  if (!is.numeric(samples))
    stop("'samples' must be numeric.", call. = FALSE)
  if (length(samples) > 1)
    stop("'samples' must have length 1.", call. = FALSE)
  if (samples < 1)
    stop("'samples' must be equal or greater than 1.", call. = FALSE)

  if (is.null(replace))
    stop("'replace' must be provided.", call. = FALSE)
  if (!is.logical(replace))
    stop("'replace' must be logical.", call. = FALSE)
  if (length(replace) > 1)
    stop("'replace' must have length 1.", call. = FALSE)

  if (is.null(oos_zoom))
    stop("'oos_zoom' must be provided.", call. = FALSE)
  if (!is.logical(oos_zoom))
    stop("'oos_zoom' must be logical.", call. = FALSE)
  if (length(oos_zoom) > 1)
    stop("'oos_zoom' must have length 1.", call. = FALSE)

  if (is.null(verbose))
    stop("'verbose' must be provided.", call. = FALSE)
  if (!is.logical(verbose))
    stop("'verbose' must be logical.", call. = FALSE)
  if (length(verbose) > 1)
    stop("'verbose' must have length 1.", call. = FALSE)

  last_run_db_exists()

  # set.seed(1234)
  monte_carlo(step = step, scope = scope, samples = samples, replace = replace, verbose = verbose)

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))

  if (!"balance_resample" %in% DBI::dbListTables(con)) {
    DBI::dbDisconnect(con)
    stop("Monte Carlo samples do not exist. Please run 'monte_carlo()' first.", call. = FALSE)
  }

  if (!"balance_resample_ci" %in% DBI::dbListTables(con)) {
    DBI::dbDisconnect(con)
    stop("Monte Carlo samples do not exist. Please run 'monte_carlo()' first.", call. = FALSE)
  }

  balance <-
    dplyr::tbl(con, "balances") |>
    dplyr::filter(step == {{step}}) |>
    dplyr::collect()

  metrics <-
    dplyr::tbl(con, "metrics") |>
    dplyr::filter(step == {{step}}) |>
    dplyr::collect()

  balance_smp <-
    dplyr::tbl(con, "balance_resample") |>
    dplyr::collect()

  balance_ci <-
    dplyr::tbl(con, "balance_resample_ci") |>
    dplyr::collect()

  DBI::dbDisconnect(con)

  balance <-
    balance |>
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"))

  balance_smp <-
    balance_smp |>
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"))

  # Recompute balance and drawdowns before calculation of OOS metrics
  if (scope == "oos") {

    balance_smp <-
      balance_smp |>
      dplyr::group_split(sample) |>
      lapply(function(x) {
        x$balance <- x$balance - x$balance[1] + balance$balance[1]
        if (sum(x$balance < 0) >= 1)
          x$balance[min(which(x$balance < 0)):length(x$balance)] <- 0
        compute_drawdown(x)
      })

    balance_smp <- do.call(rbind, balance_smp)
  }

  balance_ci <-
    balance_ci |>
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"))

  time_locale <- Sys.getlocale("LC_TIME")
  Sys.setlocale("LC_TIME", "C")

  p1 <-
    ggplot2::ggplot() +
    ggdist::geom_lineribbon(data = balance_ci, ggplot2::aes(x = time, y = balance, ymin = .lower, ymax = .upper), linewidth = 0, linetype = "dashed", alpha = 0.7) +
    ggplot2::geom_line(data = balance, ggplot2::aes(x = time, y = balance, color = factor(scope)), show.legend = FALSE) +
    # ggplot2::annotate("rect", xmin = oos_start, xmax = oos_end, ymin = -Inf, ymax = Inf, fill = "black", alpha = 0.3) +
    ggplot2::scale_y_continuous(name = "Balance", labels = scales::dollar) +
    ggplot2::scale_color_manual(values = c("is" = "black", "oos" = "firebrick")) +
    ggplot2::scale_fill_brewer(palette = "Blues", labels = c("95%", "80%", "50%")) +
    ggplot2::theme_bw() +
    # ggplot2::theme(zoom = ggplot2::element_rect(fill = "gray96")) +
    ggplot2::labs(title = glue::glue("Monte Carlo analysis after {samples} simulations"), x = NULL, y = "Balance", fill = "Confidence")

  if (oos_zoom) {
    oos_start <- balance$time[balance$scope == "oos"][1]
    p1 <-
      p1 + ggforce::facet_zoom(xy = time >= as.character(as.Date(oos_start)), zoom.size = 0.5)
  }

  returns_smp <- lapply(unique(balance_smp$sample), function(x) {
    diff(balance_smp |>
           dplyr::filter(sample == x) |>
           dplyr::pull(balance))
  })

  cagr_is <-
    metrics |>
    dplyr::filter(scope == "is") |>
    dplyr::filter(variable == "cagr") |>
    dplyr::pull(value)

  cagr_oos <-
    metrics |>
    dplyr::filter(scope == "oos") |>
    dplyr::filter(variable == "cagr") |>
    dplyr::pull(value)

  cagrs <- lapply(unique(balance_smp$sample), function(x) {
    CAGR(balance_smp |> dplyr::filter(sample == x) |> dplyr::rename(open_time = time))
  }) |> unlist()

  win_rate_is <-
    metrics |>
    dplyr::filter(scope == "is") |>
    dplyr::filter(variable == "win_rate") |>
    dplyr::pull(value)

  win_rate_oos <-
    metrics |>
    dplyr::filter(scope == "oos") |>
    dplyr::filter(variable == "win_rate") |>
    dplyr::pull(value)

  win_rates <- lapply(returns_smp, function(x) {
    win_probability(x)
  }) |> unlist()

  profit_factor_is <-
    metrics |>
    dplyr::filter(scope == "is") |>
    dplyr::filter(variable == "profit_factor") |>
    dplyr::pull(value)

  profit_factor_oos <-
    metrics |>
    dplyr::filter(scope == "oos") |>
    dplyr::filter(variable == "profit_factor") |>
    dplyr::pull(value)

  profit_factors <- lapply(returns_smp, function(x) {
    profit_factor(x)
  }) |> unlist()

  max_consec_losses_is <-
    metrics |>
    dplyr::filter(scope == "is") |>
    dplyr::filter(variable == "max_consec_losses") |>
    dplyr::pull(value)

  max_consec_losses_oos <-
    metrics |>
    dplyr::filter(scope == "oos") |>
    dplyr::filter(variable == "max_consec_losses") |>
    dplyr::pull(value)

  max_consec_losses <- lapply(returns_smp, function(x) {
    max_consecutive_losses(x)
  }) |> unlist()

  pct_dd_is <-
    metrics |>
    dplyr::filter(scope == "is") |>
    dplyr::filter(variable == "pct_dd") |>
    dplyr::pull(value)

  pct_dd_oos <-
    metrics |>
    dplyr::filter(scope == "oos") |>
    dplyr::filter(variable == "pct_dd") |>
    dplyr::pull(value)

  pct_drawdowns <- lapply(unique(balance_smp$sample), function(x) {
    max_pct_drawdown(balance_smp |> dplyr::filter(sample == x))
  }) |> unlist()

  return_dd_is <-
    metrics |>
    dplyr::filter(scope == "is") |>
    dplyr::filter(variable == "return_dd") |>
    dplyr::pull(value)

  return_dd_oos <-
    metrics |>
    dplyr::filter(scope == "oos") |>
    dplyr::filter(variable == "return_dd") |>
    dplyr::pull(value)

  returns_dd <- lapply(unique(balance_smp$sample), function(x) {
    return_drawdown_ratio(balance_smp |> dplyr::filter(sample == x))
  }) |> unlist()

  sharpe_is <-
    metrics |>
    dplyr::filter(scope == "is") |>
    dplyr::filter(variable == "sharpe_ratio") |>
    dplyr::pull(value)

  sharpe_oos <-
    metrics |>
    dplyr::filter(scope == "oos") |>
    dplyr::filter(variable == "sharpe_ratio") |>
    dplyr::pull(value)

  sharpes <- lapply(unique(balance_smp$sample), function(x) {
    Sharpe_ratio(balance_smp |> dplyr::filter(sample == x) |> dplyr::rename(close_time = time))
  }) |> unlist()

  r_squared_is <-
    metrics |>
    dplyr::filter(scope == "is") |>
    dplyr::filter(variable == "r_squared") |>
    dplyr::pull(value)

  r_squared_oos <-
    metrics |>
    dplyr::filter(scope == "oos") |>
    dplyr::filter(variable == "r_squared") |>
    dplyr::pull(value)

  r_squares <- lapply(unique(balance_smp$sample), function(x) {
    r_squared(balance_smp |> dplyr::filter(sample == x) |> dplyr::mutate(exit = TRUE))
  }) |> unlist()

  vars_is <-
    metrics |>
    dplyr::filter(scope == "is") |>
    dplyr::filter(variable == "var") |>
    dplyr::pull(value)

  vars_oos <-
    metrics |>
    dplyr::filter(scope == "oos") |>
    dplyr::filter(variable == "var") |>
    dplyr::pull(value)

  vars <- lapply(unique(balance_smp$sample), function(x) {
    VaR(balance_smp |> dplyr::filter(sample == x) |> dplyr::rename(close_time = time))
  }) |> unlist()

  metrics_smp <-
    data.frame(cagr = cagrs,
               win_rate = win_rates,
               profit_factor = profit_factors,
               max_consecutive_losses = max_consec_losses,
               pct_drawdown = pct_drawdowns,
               return_dd = returns_dd,
               sharpe = sharpes,
               r_squared = r_squares,
               var = vars)

  p2 <-
    ggplot2::ggplot() +
    ggplot2::geom_histogram(data = metrics_smp, ggplot2::aes(x = cagrs), bins = 30, fill = "steelblue", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = stats::median(metrics_smp$cagr), color = "steelblue3", linewidth = 1) +
    ggplot2::geom_vline(xintercept = cagr_is, color = "black", linewidth = 1) +
    ggplot2::geom_vline(xintercept = cagr_oos, color = "firebrick", linewidth = 1) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "CAGR", y = "Count")

  p3 <-
    ggplot2::ggplot() +
    ggplot2::geom_histogram(data = metrics_smp, ggplot2::aes(x = win_rates), bins = 30, fill = "steelblue", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = stats::median(metrics_smp$win_rate), color = "steelblue3", linewidth = 1) +
    ggplot2::geom_vline(xintercept = win_rate_is, color = "black", linewidth = 1) +
    ggplot2::geom_vline(xintercept = win_rate_oos, color = "firebrick", linewidth = 1) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Win rate", y = "Count")

  p4 <-
    ggplot2::ggplot() +
    ggplot2::geom_histogram(data = metrics_smp, ggplot2::aes(x = profit_factors), bins = 30, fill = "steelblue", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = stats::median(metrics_smp$profit_factor), color = "steelblue3", linewidth = 1) +
    ggplot2::geom_vline(xintercept = profit_factor_is, color = "black", linewidth = 1) +
    ggplot2::geom_vline(xintercept = profit_factor_oos, color = "firebrick", linewidth = 1) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Profit factor", y = "Count")

  p4 <-
    ggplot2::ggplot() +
    ggplot2::geom_histogram(data = metrics_smp, ggplot2::aes(x = max_consec_losses), bins = 30, fill = "steelblue", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = stats::median(metrics_smp$max_consecutive_losses), color = "steelblue3", linewidth = 1) +
    ggplot2::geom_vline(xintercept = max_consec_losses_is, color = "black", linewidth = 1) +
    ggplot2::geom_vline(xintercept = max_consec_losses_oos, color = "firebrick", linewidth = 1) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Max. consec. losses", y = "Count")

  p5 <-
    ggplot2::ggplot() +
    ggplot2::geom_histogram(data = metrics_smp, ggplot2::aes(x = pct_drawdowns), bins = 30, fill = "steelblue", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = stats::median(metrics_smp$pct_drawdown), color = "steelblue3", linewidth = 1) +
    ggplot2::geom_vline(xintercept = pct_dd_is, color = "black", linewidth = 1) +
    ggplot2::geom_vline(xintercept = pct_dd_oos, color = "firebrick", linewidth = 1) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Max. drawdown", y = "Count")

  p6 <-
    ggplot2::ggplot() +
    ggplot2::geom_histogram(data = metrics_smp, ggplot2::aes(x = returns_dd), bins = 30, fill = "steelblue", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = stats::median(metrics_smp$return_dd), color = "steelblue3", linewidth = 1) +
    ggplot2::geom_vline(xintercept = return_dd_is, color = "black", linewidth = 1) +
    ggplot2::geom_vline(xintercept = return_dd_oos, color = "firebrick", linewidth = 1) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Return drawdown ratio", y = "Count")

  p7 <-
    ggplot2::ggplot() +
    ggplot2::geom_histogram(data = metrics_smp, ggplot2::aes(x = sharpes), bins = 30, fill = "steelblue", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = stats::median(metrics_smp$sharpe), color = "steelblue3", linewidth = 1) +
    ggplot2::geom_vline(xintercept = sharpe_is, color = "black", linewidth = 1) +
    ggplot2::geom_vline(xintercept = sharpe_oos, color = "firebrick", linewidth = 1) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Sharpe ratio", y = "Count")

  p8 <-
    ggplot2::ggplot() +
    ggplot2::geom_histogram(data = metrics_smp, ggplot2::aes(x = r_squares), bins = 30, fill = "steelblue", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = stats::median(metrics_smp$r_squared), color = "steelblue3", linewidth = 1) +
    ggplot2::geom_vline(xintercept = r_squared_is, color = "black", linewidth = 1) +
    ggplot2::geom_vline(xintercept = r_squared_oos, color = "firebrick", linewidth = 1) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "R-squared", y = "Count")

  p9 <-
    ggplot2::ggplot() +
    ggplot2::geom_histogram(data = metrics_smp, ggplot2::aes(x = vars), bins = 30, fill = "steelblue", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = stats::median(metrics_smp$var), color = "steelblue3", linewidth = 1) +
    ggplot2::geom_vline(xintercept = vars_is, color = "black", linewidth = 1) +
    ggplot2::geom_vline(xintercept = vars_oos, color = "firebrick", linewidth = 1) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Monthly 5%-VaR", y = "Count")

  bottom_row <- cowplot::plot_grid(p2, p3, p4, p5, p6, p7, p8, p9, nrow = 2, ncol = 4)
  pl <- cowplot::plot_grid(p1, bottom_row, nrow = 2)

  cat("\n")

  if (scope == "is") {
    original <-
      data.frame(
        cagr = cagr_is,
        win_rate = win_rate_is,
        profit_factor = profit_factor_is,
        max_consec_losses = max_consec_losses_is,
        pct_dd = pct_dd_is,
        return_dd = return_dd_is,
        sharpe_ratio = sharpe_is,
        r_squared = r_squared_is,
        var = vars_is
      )
  } else if (scope == "oos") {
    original <-
      data.frame(
        cagr = cagr_oos,
        win_rate = win_rate_oos,
        profit_factor = profit_factor_oos,
        max_consec_losses = max_consec_losses_oos,
        pct_dd = pct_dd_oos,
        return_dd = return_dd_oos,
        sharpe_ratio = sharpe_oos,
        r_squared = r_squared_oos,
        var = vars_oos
      )
  }

  row.names(original) <- "original"

  print.data.frame(
    rbind(
      original,
      data.frame(cagr = -stats::quantile(-cagrs, probs = c(0.5, 0.6, 0.7, 0.8, 0.9, 0.95)),
                 win_rate = -stats::quantile(-win_rates, probs = c(0.5, 0.6, 0.7, 0.8, 0.9, 0.95)),
                 profit_factor = -stats::quantile(-profit_factors, probs = c(0.5, 0.6, 0.7, 0.8, 0.9, 0.95)),
                 max_consec_losses = stats::quantile(max_consec_losses, probs = c(0.5, 0.6, 0.7, 0.8, 0.9, 0.95)),
                 pct_dd = -stats::quantile(-pct_drawdowns, probs = c(0.5, 0.6, 0.7, 0.8, 0.9, 0.95)),
                 return_dd = -stats::quantile(-returns_dd, probs = c(0.5, 0.6, 0.7, 0.8, 0.9, 0.95)),
                 sharpe_ratio = -stats::quantile(-sharpes, probs = c(0.5, 0.6, 0.7, 0.8, 0.9, 0.95)),
                 r_squared = -stats::quantile(-r_squares, probs = c(0.5, 0.6, 0.7, 0.8, 0.9, 0.95)),
                 var = -stats::quantile(-vars, probs = c(0.5, 0.6, 0.7, 0.8, 0.9, 0.95)))
    ) |> round(2)
  )

  Sys.setlocale("LC_TIME", time_locale)

  suppressWarnings(pl)
}
