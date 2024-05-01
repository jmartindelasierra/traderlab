
#' Update the steps grid according to the provided steps to run
#'
#' The function update_steps() checks if 'steps' has a value. If so, filters the steps grid such that the grid contains only the provided steps.
#'
#' @param steps An integer. The number of steps provided in run_model().
#' @param steps_from_model An integer. The number of steps provided by the model.
#'
#' @return The function returns the updated steps grid.
#'
update_steps <- function(steps, steps_from_model) {

  if (!is.null(steps)) {
    if (max(steps) <= steps_from_model$n_steps) {

      steps_from_model$n_steps <- length(steps)
      steps_from_model$steps <- steps_from_model$steps[steps, ]

      return(steps_from_model)

    } else {
      stop("'steps' exceeds total steps in model.", call. = FALSE)
    }
  }

  steps_from_model
}
