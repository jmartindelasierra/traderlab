
#' Plot excursions
#'
#' @param step An integer with the model step to plot.
#'
#' @export
#'
plot_excursions <- function(step) {

  # Initialization to avoid notes in R CMD check
  time <- trade <- ret <- bars_from_entry <- type <- mae <- NULL

  if (missing(step) || is.null(step))
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
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"),
                  trade = ifelse(trade == 1, TRUE, FALSE))

  trade_index <- c()
  trade_counter <- 0
  trade_in_progress <- FALSE

  for (i in 1:nrow(balance)) {

    if (balance$entry[i] == 1) {
      trade_counter <- trade_counter + 1
      trade_in_progress <- TRUE
    }

    if (!balance$trade[i]) {
      trade_in_progress <- FALSE
    }

    if (trade_in_progress) {
      trade_index[i] <- trade_counter
    } else {
      trade_index[i] <- NA
    }

  }

  balance$trade_index <- trade_index

  balance <-
    balance |>
    dplyr::filter(trade_index > 0) |>
    dplyr::group_by(trade_index) |>
    dplyr::mutate(t = 1:dplyr::n(),
                  open = dplyr::first(close),
                  ret = (close - open) / open,
                  type = ifelse(dplyr::last(ret) >= 0, "winner", "loser")) |>
    dplyr::ungroup()

  p1 <-
    balance |>
    ggplot2::ggplot() +
    ggplot2::geom_line(ggplot2::aes(x = bars_from_entry, y = ret, group = trade_index, color = type), alpha = 0.5, show.legend = FALSE) +
    # ggplot2::geom_smooth(ggplot2::aes(x = bars_from_entry, y = ret, color = type), method = "lm", formula = y ~ x, se = FALSE, show.legend = FALSE) +
    ggplot2::geom_hline(yintercept = 0) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::scale_color_manual(values = c("winner" = "forestgreen", "loser" = "firebrick")) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "Bars", y = "Excursion (%)") +
    ggplot2::facet_wrap(~type)

  # p2 <-
  #   balance |>
  #   dplyr::filter(ret > 0) |>
  #   ggplot2::ggplot() +
  #   ggplot2::geom_histogram(ggplot2::aes(x = ret, fill = type), bins = 30, alpha = 0.7, show.legend = FALSE) +
  #   ggplot2::scale_x_continuous(labels = scales::percent) +
  #   ggplot2::scale_fill_manual(values = c("winner" = "forestgreen", "loser" = "firebrick")) +
  #   ggplot2::theme_bw() +
  #   ggplot2::labs(x = "FE (%)", y = NULL) +
  #   ggplot2::facet_wrap(~type)

  p3 <-
    balance |>
    dplyr::filter(ret < 0) |>
    ggplot2::ggplot() +
    ggplot2::geom_histogram(ggplot2::aes(x = ret, fill = type), bins = 30, alpha = 0.8, show.legend = FALSE) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::scale_fill_manual(values = c("winner" = "forestgreen", "loser" = "firebrick")) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "AE (%)", y = "Count") +
    ggplot2::facet_wrap(~type)

  p4 <-
    balance |>
    dplyr::group_by(trade_index) |>
    dplyr::summarise(mae = min(ret),
                     type = dplyr::first(type),
                     pct_return = max(abs(pct_return))) |>
    ggplot2::ggplot() +
    ggplot2::geom_point(ggplot2::aes(x = mae, y = pct_return, color = type), show.legend = FALSE) +
    ggplot2::scale_x_continuous(labels = scales::percent) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::scale_color_manual(values = c("winner" = "forestgreen", "loser" = "firebrick")) +
    ggplot2::theme_bw() +
    ggplot2::labs(x = "MAE (%)", y = "|Return| (%)")

  top_row <- suppressWarnings(cowplot::plot_grid(p1, p3, nrow = 2, align = "v", rel_heights = c(2, 1)))
  pl <- suppressWarnings(cowplot::plot_grid(top_row, p4, nrow = 2, rel_heights = c(3, 1)))

  pl
}
