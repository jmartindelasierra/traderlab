
#' Add entry and exit signals from the model
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#'
#' @return This function returns an updated OHLCV data with entry and exit signals.
#'
add_signals <- function(ohlcv_data, model) {

  entry_signal <- model$rules$entry_signal
  exit_signal <- model$rules$exit_signal

  data <- ohlcv_data |> tidyr::drop_na()

  if (nrow(data) == 0)
    stop("Empty data after computing indicators.", call. = FALSE)

  entry_price_v <- rep(NA_real_, nrow(data))
  bars_from_entry_v <- rep(NA_integer_, nrow(data))
  exit_v <- vector("logical", nrow(data))
  trade_v <- vector("logical", nrow(data))

  entry_price <- NA
  bars_from_entry <- NA
  trade_in_progress <- FALSE

  tryCatch({
    entry_signal_parsed <- parse(text = entry_signal)
    entry_v <- with(data, eval(entry_signal_parsed))
  },
  warning = function(w) stop("'entry_signal' conditions could not be evaluated.", call. = FALSE),
  error = function(e) stop("'entry_signal' conditions could not be evaluated.", call. = FALSE)
  )

  entry_v[is.na(entry_v)] <- FALSE

  tryCatch({
    exit_signal_parsed <- parse(text = exit_signal)
  },
  error = function(e) stop("'exit_signal' conditions could not be evaluated.", call. = FALSE)
  )

  for (i in 1:nrow(data)) {

      if (entry_v[i] && !trade_in_progress) {
        trade_in_progress <- TRUE
        entry_price <- data$close[i]
        bars_from_entry <- -1
        trade_v[i] <- TRUE
      }

      if (trade_in_progress) {

        entry_price_v[i] <- entry_price
        bars_from_entry <- bars_from_entry + 1
        bars_from_entry_v[i] <- bars_from_entry

        tryCatch({
          exit_v[i] <- with(data[i,], eval(exit_signal_parsed))
        },
        warning = function(w) stop("'exit_signal' conditions could not be evaluated.", call. = FALSE),
        error = function(e) stop("'exit_signal' conditions could not be evaluated.", call. = FALSE)
        )

        if (!is.logical(exit_v[i]))
          stop("'exit_signal' conditions could not be evaluated.", call. = FALSE)

        if (exit_v[i])
          trade_in_progress <- FALSE

        if (entry_v[i] && identical(entry_price_v[i], dplyr::lag(entry_price_v)[i]))
          entry_v[i] <- FALSE

        trade_v[i] <- TRUE

      } else {
        exit_v[i] <- FALSE
      }

  }

  data$entry <- entry_v
  data$entry_price <- entry_price_v
  data$bars_from_entry <- bars_from_entry_v
  data$exit <- exit_v
  data$trade <- trade_v

  data
}
