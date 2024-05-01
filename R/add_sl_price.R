
#' Add stop loss price to OHLCV data
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param model An R object with model.
#' @param mode A string with the mode of stop loss.
#'
#' @return This function returns an updated OHLCV data with stop loss price.
#'
add_sl_price <- function(ohlcv_data, model, mode = "entry_bars") {

  # Initialization to avoid notes in R CMD check
  entry <- trade <- stop_loss_price <- exit <- entry_price <- bars_from_entry <- NULL

  if (!is.null(model$rules$stop_loss_price)) {

    sl_price <- model$rules$stop_loss_price

    switch(mode,
           "all_bars" = {
             ohlcv_data <-
               ohlcv_data |>
               dplyr::mutate(stop_loss_price = eval(parse(text = sl_price)))
           },
           "entry_bars" = {
             tryCatch({
               ohlcv_data <-
                 ohlcv_data |>
                 dplyr::mutate(stop_loss_price = ifelse(entry & trade, eval(parse(text = sl_price)), NA))
             },
             error = function(e) stop("Invalid 'stop_loss_price' conditions.", call. = FALSE)
             )

             ohlcv_data$stop_loss_price <- zoo::na.locf(ohlcv_data$stop_loss_price, na.rm = FALSE)

             ohlcv_data <-
               ohlcv_data |>
               dplyr::mutate(stop_loss_price = ifelse(trade, stop_loss_price, NA))

             # Set exit signal by stop loss
             ohlcv_data <-
               ohlcv_data |>
               dplyr::mutate(exit = ifelse(close <= stop_loss_price, TRUE, exit))
           }
    )

    if (!is.logical(ohlcv_data$entry))
      stop("'entry_signal' must be logical.", call. = FALSE)

    if (!is.logical(ohlcv_data$exit))
      stop("'exit_signal' must be logical.", call. = FALSE)

    entries <- which(ohlcv_data$entry)
    exits <- which(ohlcv_data$exit)
    trades <- vector(length = nrow(ohlcv_data))

    # Trade = TRUE between entry and exit
    if (length(entries) > 0) {
      for (i in 1:length(entries)) {
        exits <- exits[exits > entries[i]]
        if (length(exits) == 0) {
          exits <- length(trades) # Artificial exit at the end to keep trade = TRUE
        }
        trades[entries[i]:exits[1]] <- TRUE
      }
    }

    ohlcv_data$trade <- trades

    # Cancel entry if trade in progress
    # Cancel exit if not trade in progress
    ohlcv_data <-
      ohlcv_data |>
      dplyr::mutate(entry = ifelse(entry & !dplyr::lag(exit) & dplyr::lag(trade), FALSE, entry)) |>
      dplyr::mutate(exit = ifelse(exit & !trade, FALSE, exit))

    # Fix first entry replaced with NA in previous logic
    if (is.na(ohlcv_data$entry[1]) & ohlcv_data$trade[1])
        ohlcv_data$entry[1] <- TRUE

    # Remove entry price where trade = FALSE
    ohlcv_data <-
      ohlcv_data |>
      dplyr::mutate(entry_price = ifelse(trade, entry_price, NA))

    # Remove stop loss price where trade = FALSE
    ohlcv_data <-
      ohlcv_data |>
      dplyr::mutate(stop_loss_price = ifelse(trade, stop_loss_price, NA))

    ohlcv_data <-
      ohlcv_data |>
      dplyr::mutate(bars_from_entry = ifelse(trade, bars_from_entry, NA),
                    exit = ifelse(trade, exit, FALSE))

  }

  ohlcv_data
}
