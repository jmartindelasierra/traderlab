
#' Save the metrics to temporary database
#'
#' @param metrics A data.frame with metrics.
#'
save_metrics <- function(metrics) {

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  DBI::dbWriteTable(con, "metrics", metrics, append = TRUE)
  DBI::dbDisconnect(con)

}
