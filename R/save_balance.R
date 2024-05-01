
#' Save balance to temporary database
#'
#' @param ohlcv_data A data.frame with OHLCV data.
#' @param step An integer with the current step.
#' @param run_id A string with the current run ID.
#'
save_balance <- function(ohlcv_data, step, run_id) {

  # Initialization to avoid notes in R CMD check
  close_time <- close <- scope <- entry <- exit <- trade <- bars_from_entry <- balance0 <- pct_balance0 <- drawdown <- pct_drawdown <- fees <- time <- NULL

  balance <-
    ohlcv_data |>
    dplyr::select(time = close_time, close, scope, entry, exit, trade, bars_from_entry, pct_return, balance, balance0, pct_balance0, drawdown, pct_drawdown, fees) |>
    dplyr::mutate(run_id = run_id,
                  step = step) |>
    dplyr::relocate(run_id, .before = time) |>
    dplyr::relocate(step, .after = run_id)

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  DBI::dbWriteTable(con, "balances", balance, append = TRUE)
  DBI::dbDisconnect(con)

}
