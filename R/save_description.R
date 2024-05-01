
#' Save description data to temporary database
#'
#' @param model An R object with model.
#' @param step An integer with the current step.
#' @param run_id A string with the current run ID.
#'
save_description <- function(model, step, run_id) {

  if (step == 1) {

    model_description <-
      model$description |>
      unlist() |>
      data.frame() |>
      tibble::rownames_to_column() |>
      stats::setNames(c("variable", "value")) |>
      dplyr::mutate(run_id = run_id)

    con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
    DBI::dbWriteTable(con, "models", model_description, append = TRUE)
    DBI::dbDisconnect(con)

  }

}
