
#' Get all the step combinations from model
#'
#' The function get_model_steps() reads the steps section in the model or the model YAML file and builds a grid with all the possible combinations.
#'
#' @param model An R object with model or a string with the name of the YAML file describing the model.
#'
#' @return The function returns a list with 'n_steps' (the number of steps) and 'steps' (a data.frame with the combinations).
#' @export
#'
get_model_steps <- function(model) {

  tryCatch({
    is_model(model)
  },
  error = function(e) model <<- read_model(model))

  tryCatch({
    steps <-
      lapply(model$steps, function(x) {
        if (length(x) == 1) {
          x
        } else if (length(x) == 3) {
          seq(x[1], x[2], x[3])
        } else {
          NULL
        }
      })
  },
  error = function(e) stop("Invalid definition in 'steps' model section. Must be either a single number or [start, end, step].", call. = FALSE))

  if (any(lapply(steps, is.null) |> unlist()))
    stop("Invalid definition in 'steps' model section. Must be either a single number or [start, end, step].", call. = FALSE)

  steps <-
    steps |>
    expand.grid() |>
    data.frame()

  new_names <-
    lapply(names(steps), function(x) {
    paste0("$", x)
  }) |> unlist()

  names(steps) <- new_names

  list(n_steps = nrow(steps), steps = steps)
}
