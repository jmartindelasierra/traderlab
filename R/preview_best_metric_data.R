
#' Preview the best performance of the model
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param step An integer with the current step.
#' @param metric A string with the metric name,
#' @param metric_value A number with the metric value.
#'
#' @return The function returns preview plots.
#'
preview_best_metric_data <- function(ohlcv_data, step, metric, metric_value) {

  close_time <- year <- balance <- balance_end <- balance_start <- roc <- NULL

  try({

    plot(ohlcv_data$close_time,
         ohlcv_data$balance0,
         type = "l",
         main = glue::glue("Best step: {step}"),
         sub = NULL,
         xlab = "",
         ylab = "Balance",
         lwd = 0,
         cex.main = 1,
         cex.sub = 0.7,
         cex.axis = 0.8,
         frame.plot = FALSE)

    graphics::polygon(c(min(ohlcv_data$close_time), ohlcv_data$close_time, max(ohlcv_data$close_time)), c(ohlcv_data$balance0[1], ohlcv_data$balance0, ohlcv_data$balance0[1]), lwd = 0.7, col = "skyblue")
    graphics::abline(v = ohlcv_data$close_time[which(ohlcv_data$scope == "oos")[1]], lty = "dashed", lwd = 1.5, col = "black")
    sub <- glue::glue("{toupper(metric)}: {round(metric_value, 2)}")
    graphics::title(sub = substitute(paste(bold(sub))), line = 2, cex.sub = 0.7)

    annual_returns <-
      ohlcv_data |>
      dplyr::mutate(year = format(close_time, "%Y")) |>
      dplyr::group_by(year) |>
      dplyr::summarise(balance_start = dplyr::first(balance),
                       balance_end = dplyr::last(balance)) |>
      dplyr::mutate(roc = (balance_end - balance_start) / balance_start,
                    color = ifelse(roc >= 0, "forestgreen", "indianred"))

    graphics::barplot(annual_returns$roc, names.arg = annual_returns$year, col = annual_returns$color, ylab = "Return", cex.names = 0.7, yaxt = "n")
    graphics::axis(2, at = pretty(annual_returns$roc), lab = paste0(pretty(annual_returns$roc) * 100, "%"), las = TRUE, cex.axis = 0.7)

  }, silent = TRUE)

}
