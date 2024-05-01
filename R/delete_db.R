
#' Delete the last run database
#'
delete_db <- function() {

  if (file.exists(glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite")))
    file.remove(glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))

}
