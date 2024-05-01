
#' Retrieve variables setup from the last run model
#'
#' @export
#'
variables <- function() {

  # Initialization to avoid notes in R CMD check
  run_id <- step <- variable <- value <- NULL

  last_run_db_exists()

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  variables <-
    dplyr::tbl(con, "variables") |>
    dplyr::select(-run_id) |>
    dplyr::collect()
  DBI::dbDisconnect(con)

  variables <-
    variables |>
    dplyr::relocate(step, .before = variable) |>
    dplyr::mutate(value = as.numeric(value))

  invisible(variables)
}
