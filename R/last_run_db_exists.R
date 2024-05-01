
#' Check if last run database exists
#'
last_run_db_exists <- function() {

  check_db_path()

  db_exists <- file.exists(glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))

  if (!db_exists)
    stop("Missing last run data. Make sure you first run a model.", call. = FALSE)

  invisible(db_exists)
}
