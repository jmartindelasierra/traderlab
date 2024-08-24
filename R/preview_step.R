
#' Preview the performance of the current model step
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#' @param steps An integer with the total steps.
#' @param step An integer with the current step.
#' @param metric A string with the metric name,
#' @param metric_value A number with the metric value.
#'
#' @return The function returns preview plots.
#'
preview_step <- function(model, ohlcv_data, steps, step, metric, metric_value) {

  # Initialization to avoid notes in R CMD check
  exit <- close_time <- year <- balance <- balance_end <- balance_start <- returns <- NULL

  grDevices::graphics.off()

  try({

    graphics::par(mfrow = c(2, 2), oma = c(0, 0, 2, 0), mai = c(0.7, 0.7, 0.4, 0.1))

    plot(ohlcv_data$close_time, ohlcv_data$balance0, type = "l", main = NULL, sub = NULL, xlab = "", ylab = "Balance", lwd = 0, cex.sub = 0.7, cex.axis = 0.8, frame.plot = FALSE)
    graphics::polygon(c(min(ohlcv_data$close_time), ohlcv_data$close_time, max(ohlcv_data$close_time)), c(ohlcv_data$balance0[1], ohlcv_data$balance0, ohlcv_data$balance0[1]), lwd = 0.7, col = "lightgray")
    graphics::abline(v = ohlcv_data$close_time[which(ohlcv_data$scope == "oos")[1]], lty = "dashed", lwd = 1.5, col = "black")
    sub <- glue::glue("{toupper(metric)}: {round(metric_value, 2)}")
    graphics::title(sub = substitute(paste(bold(sub))), line = 2, cex.sub = 0.7)

    # plot(ohlcv_data$close_time, ohlcv_data$pct_drawdown, type = "l", main = NULL, xlab = "", ylab = "Drawdown", lwd = 0, yaxt = "n", frame.plot = FALSE)
    # graphics::polygon(c(min(ohlcv_data$close_time), ohlcv_data$close_time, max(ohlcv_data$close_time)), c(0, ohlcv_data$pct_drawdown, 0), lwd = 0.7, col = "indianred")
    # graphics::abline(v = ohlcv_data$close_time[which(ohlcv_data$scope == "oos")[1]], lty = "dashed", lwd = 1.5, col = "black")
    # graphics::axis(2, at = pretty(ohlcv_data$pct_drawdown), lab = paste0(pretty(ohlcv_data$pct_drawdown) * 100, "%"), las = TRUE)

    annual_returns <-
      ohlcv_data |>
      dplyr::mutate(year = format(close_time, "%Y")) |>
      dplyr::group_by(year) |>
      dplyr::summarise(returns = sum(pct_return, na.rm = TRUE)) |>
      # dplyr::summarise(balance_start = dplyr::first(balance),
      #                  balance_end = dplyr::last(balance)) |>
      dplyr::mutate(
        # roc = (balance_end - balance_start) / balance_start,
                    color = ifelse(returns >= 0, "lightgray", "gray30"))

    graphics::barplot(annual_returns$returns, names.arg = annual_returns$year, col = annual_returns$color, ylab = "Annual cum. return (%)", cex.names = 0.7, yaxt = "n")
    graphics::axis(2, at = pretty(annual_returns$returns), lab = paste0(pretty(annual_returns$returns) * 100, "%"), las = TRUE, cex.axis = 0.7)

    # pct_returns <-
    #   ohlcv_data |>
    #   dplyr::filter(exit) |>
    #   dplyr::pull(pct_return)
    #
    # avg_pct_return <- mean(pct_returns)
    #
    # h <- graphics::hist(pct_returns, breaks = "FD", plot = FALSE)
    # graphics::hist(pct_returns, main = NULL, sub = NULL, xlab = NULL, ylab = NULL, xaxt = "n", breaks = "FD", freq = FALSE, col = ifelse(h$mids >= 0, "forestgreen", "indianred"), border = "black", cex.sub = 0.7, axes = FALSE)
    # graphics::axis(1, at = pretty(pct_returns), lab = paste0(pretty(pct_returns) * 100, "%"), las = TRUE)
    # sub <- glue::glue("{round(avg_pct_return * 100, 2)}% per trade")
    # graphics::title(sub = substitute(paste(bold(sub))), line = 2, cex.sub = 0.7)

    if (!is.null(model$description$name) && !is.null(model$description$symbol) && !is.null(model$description$timeframe))
      graphics::mtext(glue::glue("{model$description$name} - {model$description$symbol} {model$description$timeframe}"), line = 0, side = 3, outer = TRUE, cex = 1.5)

    graphics::mtext(glue::glue("(previewing step {step} out of {steps})"), line = -1.25, side = 3, outer = TRUE, cex = 0.8)

  }, silent = TRUE)

}
