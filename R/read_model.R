
#' Read a model in a YAML file
#'
#' @param file A string with the YAML file name describing the model.
#'
#' @return This function returns an R object of the model.
#'
read_model <- function(file) {

  tryCatch({
    yaml::read_yaml(file)
  },
  warning = function(w) stop("Invalid file.", call. = FALSE),
  error = function(e) stop("Invalid file.", call. = FALSE)
  )

}
