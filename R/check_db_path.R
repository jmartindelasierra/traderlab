
#' Check folder and environment variable for the database
#'
#' The function check_db_path() looks for the value in RADERLAB_DB_PATH. If the value is not the path to the database, then it's set and the directory for the database is created.
#'
#' @return The function returns the value for the TRADERLAB_DB_PATH environment variable.
#'
check_db_path <- function() {

  # Set DB path
  if (Sys.getenv("TRADERLAB_DB_PATH") == "")
    Sys.setenv("TRADERLAB_DB_PATH" = glue::glue("{getwd()}/database/"))

  # Create DB directory
  if (!dir.exists(Sys.getenv("TRADERLAB_DB_PATH")))
    dir.create(Sys.getenv("TRADERLAB_DB_PATH"))

  # Get environment DB path variable
  invisible(Sys.getenv("TRADERLAB_DB_PATH"))
}
