
#' Save the variables setup to the temporary database
#'
#' @param model An R object with model.
#' @param steps Model steps.
#' @param step An integer with the current step.
#' @param run_id A string with the current run ID.
#'
save_variable_step <- function(model, steps, step, run_id) {

  variable_step <- steps[step, ]
  names(variable_step) <- names(model$steps)

  if (length(names(model$steps)) == 1) {

    variable_step <-
      variable_step |>
      data.frame() |>
      tibble::rownames_to_column() |>
      stats::setNames(c("variable", "value")) |>
      dplyr::mutate(run_id = run_id,
                    step = step)

  } else {

    variable_step <-
      variable_step |>
      t() |>
      data.frame() |>
      tibble::rownames_to_column() |>
      stats::setNames(c("variable", "value")) |>
      dplyr::mutate(run_id = run_id,
                    step = step)

  }

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  DBI::dbWriteTable(con, "variables", variable_step, append = TRUE)
  DBI::dbDisconnect(con)
}
