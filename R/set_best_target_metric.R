
#' Initialize the best metric according to the target metric defined in the model
#'
#' @param model An R object with model.
#' @param best A number with the index model that best fits the target metric.
#'
#' @return The function returns extreme values -Inf or Inf for the best metric as they are required for the first update.
#'
set_best_target_metric <- function(model, best) {

  if (model$target$operation == "max") {
    best <- -Inf
  } else if (model$target$operation == "min") {
    best <- Inf
  }

  best
}
