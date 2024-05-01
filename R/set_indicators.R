
#' Set indicators to OHLCV data
#'
#' @param model_file A string with the name of the YAML file describing the model.
#' @param step An integer with the model step,
#'
#' @export
#'
set_indicators <- function(model_file, step = 1) {

  if (missing(model_file) || is.null(model_file))
    stop("'model_file' must be provided.", call. = FALSE)
  if (!is.character(model_file))
    stop("'model_file' must be character.", call. = FALSE)
  if (length(model_file) > 1)
    stop("'model_file' must have length 1.", call. = FALSE)

  # Read model from file
  model <- read_model(model_file)

  # Check model
  is_model(model)

  # Check OHLCV
  ohlcv_data <- load_ohlcv(model$description$data)
  is_ohlcv(ohlcv_data)

  if (is.null(step))
    stop("'step' must be provided.", call. = FALSE)
  if (!is.numeric(step))
    stop("'step' must be positive integer.", call. = FALSE)

  step <- as.integer(step)

  indicators <- get_indicators(model)
  indicator_names <- names(indicators)

  st <- get_model_steps(model)
  model_step <- set_step_values(model, st, step)
  ohlcv_data <- add_indicators(ohlcv_data, model_step)
  ohlcv_data <- add_signals(ohlcv_data, model_step)
  ohlcv_data <- add_sl_price(ohlcv_data, model_step)
  ohlcv_data$bars_from_entry <- NULL

  if (!is.null(ohlcv_data$stop_loss_price)) {
    ohlcv_data <-
      ohlcv_data |>
      dplyr::relocate(stop_loss_price, .after = entry_price)
  }

  ohlcv_data
}
