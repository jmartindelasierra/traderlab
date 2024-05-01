
#' Retrieve metrics from the last run model
#'
#' @export
#'
metrics <- function() {

  # Initialization to avoid notes in R CMD check
  run_id <- variable <- step <- metric <- scope <- NULL

  last_run_db_exists()

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  metrics <-
    dplyr::tbl(con, "metrics") |>
    dplyr::select(-run_id) |>
    dplyr::collect()
  DBI::dbDisconnect(con)

  metrics <-
    metrics |>
    dplyr::rename(metric = variable) |>
    dplyr::relocate(step, .before = metric) |>
    dplyr::relocate(scope, .after = step)

  invisible(metrics)
}
