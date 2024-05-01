
#' Plot OHLC bars and trades
#'
#' @param model_file A string with the name of the YAML file describing the model.
#' @param step An integer with the model step to plot.
#' @param from A string with date formated as yyyy-mm-dd.
#' @param to A string with date formated as yyyy-mm-dd.
#' @param show_trades A boolean indicating whether or not show the trades.
#'
#' @export
#'
plot_trades <- function(model_file, step = 1, from = NULL, to = NULL, show_trades = TRUE) {

  open_time <- close_time <- low <- high <- entry <- exit <- ret <- NULL

  if (!missing(model_file) && !is.null(model_file)) {
    if (!is.character(model_file))
      stop("'model_file' must be character.", call. = FALSE)
    if (length(model_file) > 1)
      stop("'model_file' must have length 1.", call. = FALSE)

    # Read model from file
    model <- read_model(model_file)

    # Check model
    is_model(model)

    # Check OHLCV
    ohlcv_data <- load_ohlcv(model$description$data)
    is_ohlcv(ohlcv_data)
  }

  if (is.null(step))
    stop("'step' must be provided.", call. = FALSE)
  if (!is.numeric(step))
    stop("'step' must be integer.", call. = FALSE)
  if (length(step) > 1)
    stop("'step' must have length 1.", call. = FALSE)
  if (step < 1)
    stop("'step' must be equal or greater than 1.", call. = FALSE)

  step <- as.integer(step)

  if (!is.null(from)) {
    tryCatch({
      as.Date(from)
    },
    error = function(e) { stop("Invalid 'from' format. Must be yyyy-mm-dd.", call. = FALSE) }
    )
    ohlcv_data <-
      ohlcv_data |>
      dplyr::filter(open_time >= from)
  }

  if (!is.null(to)) {
    tryCatch({
      as.Date(to)
    },
    error = function(e) { stop("Invalid 'to' format. Must be yyyy-mm-dd.", call. = FALSE) }
    )
    ohlcv_data <-
      ohlcv_data |>
      dplyr::filter(close_time <= to)
  }

  indicators <- get_indicators(model)
  indicator_names <- names(indicators)

  st <- get_model_steps(model)
  model_step <- set_step_values(model, st, step)
  ohlcv_data <- add_indicators(ohlcv_data, model_step)
  ohlcv_data <- add_signals(ohlcv_data, model_step)
  ohlcv_data <- add_sl_price(ohlcv_data, model_step)
  ohlcv_data$bars_from_entry <- NULL

  if (!is.null(ohlcv_data$stop_loss_price)) {
    ohlcv_data <-
      ohlcv_data |>
      dplyr::relocate(stop_loss_price, .after = entry_price)
  }

  bar_gap <-
    difftime(ohlcv_data$close_time[1],
             ohlcv_data$open_time[1],
             units = "secs") |>
    as.integer()

  time_locale <- Sys.getlocale("LC_TIME")
  Sys.setlocale("LC_TIME", "C")

  p <-
    ohlcv_data |>
    ggplot2::ggplot(ggplot2::aes(x = close_time, color = ifelse(close > open, "up", "down"))) +
    ggplot2::geom_linerange(ggplot2::aes(ymin = low, ymax = high)) +
    ggplot2::geom_segment(ggplot2::aes(y = open, yend = open, xend = close_time - bar_gap / 3)) +
    ggplot2::geom_segment(ggplot2::aes(y = close, yend = close, xend = close_time + bar_gap / 3)) +
    ggplot2::scale_y_continuous(labels = scales::dollar) +
    ggplot2::scale_colour_manual(values = c("down" = "darkred", "up" = "darkgreen")) +
    ggplot2::guides(colour = "none") +
    ggplot2::labs(x = NULL, y = "Price") +
    ggplot2::theme_bw()

  if (show_trades) {

    ohlcv_data <-
      ohlcv_data |>
      dplyr::mutate(ret = dplyr::case_when(
        exit & close > entry_price ~ "win",
        exit & close < entry_price ~ "loss",
        !trade ~ "n/a"
      ))

    ohlcv_data$ret <- rev(zoo::na.locf0(rev(ohlcv_data$ret)))

    p <-
      p +
      ggplot2::geom_point(data = ohlcv_data |> dplyr::filter(entry), ggplot2::aes(y = close), shape = 24, fill = "green", color = "black") +
      ggplot2::geom_point(data = ohlcv_data |> dplyr::filter(exit), ggplot2::aes(y = close), shape = 25, fill = "red", color = "black") +
      ggplot2::geom_rect(data = ohlcv_data, ggplot2::aes(xmin = close_time, xmax = c(utils::tail(close_time, -1), utils::tail(close_time, 1)), ymin = -Inf, ymax = Inf, fill = ret), alpha = 0.3, color = NA, show.legend = FALSE) +
      ggplot2::scale_fill_manual(values = c("win" = "green", "loss" = "red", "n/a" = NA), na.value = NA)
  }

  Sys.setlocale("LC_TIME", time_locale)

  p
}
