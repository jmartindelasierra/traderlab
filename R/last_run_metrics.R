
#' Retrieve metrics from last run
#'
last_run_metrics <- function() {

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  metrics <- DBI::dbReadTable(con, "metrics")
  DBI::dbDisconnect(con)

  metrics
}
