
#' Plot maximum excursions
#'
#' @param step An integer with the model step to plot.
#' @param show_sum_return A logical value. If TRUE, sum of returns line is shown.
#'
#' @export
#'
plot_max_excursions <- function(step = 1, show_sum_return = FALSE) {

  # Initialization to avoid notes in R CMD check
  trade_index <- pct_balance0 <- pct_exc <- ret <- mfe <- mae <- cum_return <- NULL

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

  # balance <-
  #   balance |>
  #   dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"))

  # balance |>
  #   dplyr::group_by(trade_index) |>
  #   dplyr::summarise(ret = dplyr::last(pct_return),
  #                    pct_balance = dplyr::last(pct_balance0),
  #                    mae = min(pct_exc),
  #                    mfe = max(pct_exc)) |>
  #   dplyr::mutate(cum_return = cumsum(ret)) |>
  #   tidyr::drop_na() |>
  #   ggplot2::ggplot(ggplot2::aes(x = trade_index)) +
  #   ggplot2::geom_col(ggplot2::aes(y = ret, fill = ifelse(ret >= 0, "forestgreen", "indianred")), alpha = 0.7) +
  #   ggplot2::geom_line(ggplot2::aes(y = mfe, color = "forestgreen")) +
  #   ggplot2::geom_line(ggplot2::aes(y = mae, color = "indianred")) +
  #   #geom_line(aes(y = pct_balance), linewidth = 1) +
  #   ggplot2::geom_line(ggplot2::aes(y = cum_return, color = "black"), linewidth = 0.7) +
  #   ggplot2::scale_y_continuous(labels = scales::percent) +
  #   ggplot2::scale_color_identity(guide = "legend", name = NULL, labels = c("Cum. return", "MFE", "MAE")) +
  #   ggplot2::scale_fill_identity(guide = "legend", name = NULL, labels = c("Pos. return", "Neg. return")) +
  #   ggplot2::theme_bw() +
  #   ggplot2::labs(x = "Trades", y = "Returns / MFE / MAE / Cum. return (%)")

  p <-
    balance |>
    dplyr::group_by(trade_index) |>
    dplyr::summarise(ret = dplyr::last(pct_return),
                     # pct_balance = dplyr::last(pct_balance0),
                     mae = min(pct_exc),
                     mfe = max(pct_exc)) |>
    dplyr::mutate(cum_return = cumsum(ret)) |>
    # dplyr::mutate(cum_return = cumprod(ret + 1) - 1) |>
    tidyr::drop_na() |>
    ggplot2::ggplot(ggplot2::aes(x = trade_index)) +
    ggplot2::geom_col(ggplot2::aes(y = mfe, fill = "Pos. return/MFE"), alpha = 0.4) +
    ggplot2::geom_col(ggplot2::aes(y = mae, fill = "Neg. return/MAE"), alpha = 0.4) +
    ggplot2::geom_col(ggplot2::aes(y = ret, fill = ifelse(ret >= 0, "Pos. return/MFE", "Neg. return/MAE")), alpha = 0.7) +
    # ggplot2::geom_line(ggplot2::aes(y = cum_return, color = "black"), linewidth = 0.7) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    # ggplot2::scale_color_identity(guide = "legend", name = NULL, labels = c("Cum. return")) +
    ggplot2::scale_fill_manual(guide = "legend", name = NULL, values = c("Pos. return/MFE" = "forestgreen", "Neg. return/MAE" = "indianred")) +
    ggplot2::theme_bw() +
    ggplot2::theme(legend.position = "bottom") +
    ggplot2::labs(x = "Trades", y = "Returns / MFE / MAE (%)")

  if (show_sum_return) {

    p <-
      p +
      ggplot2::geom_line(ggplot2::aes(y = cum_return, color = "black"), linewidth = 0.7) +
      ggplot2::scale_color_identity(guide = "legend", name = NULL, labels = c("Sum return")) +
      ggplot2::labs(x = "Trades", y = "Returns / MFE / MAE / Sum return (%)")

  }

  p
}
