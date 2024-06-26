
#' Update the model with the current variables setup
#'
#' The function set_step_values() takes the original model with variables and replaces them with the values from the step in progress.
#'
#' @param model An R object with model.
#' @param steps A data.frame with the steps grid.
#' @param step An integer with the index of the step in the steps grid.
#'
#' @return The function returns the model with its variables replaced by values.
#'
set_step_values <- function(model, steps, step) {

  model <- yaml::as.yaml(model)

  for (i in seq_len(length(names(steps$steps)))) {
    # name <- paste0(names(steps$steps)[i], "\n")
    # value <- paste0(steps$steps[step, i], "\n")
    # model <- gsub(name, value, model, fixed = TRUE)
    name <- paste0("\\", names(steps$steps)[i], "\\b")
    value <- paste0(steps$steps[step, i])
    model <- stringr::str_replace_all(model, name, value)
  }

  yaml_model <- yaml::read_yaml(text = model)

  if (any(grepl("\\$", unlist(yaml_model))))
    stop("One or more variables have no steps assigned.", call. = FALSE)

  yaml_model
}
