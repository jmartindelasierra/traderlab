
#' Retrieve balance data from last run
#'
#' @export
#'
balances <- function() {

  # Initialization to avoid notes in R CMD check
  run_id <- time <- NULL

  last_run_db_exists()

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  balances <-
    dplyr::tbl(con, "balances") |>
    dplyr::select(-run_id) |>
    dplyr::collect()
  DBI::dbDisconnect(con)

  balances <-
    balances |>
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"))

  invisible(balances)
}
