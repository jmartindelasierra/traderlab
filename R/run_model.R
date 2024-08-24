
#' Runs a model on OHLCV data
#'
#' A model is a YAML file containing information about entry/exit strategy rules and indicators setup among other data. The run_model() function performs a complete backtest by taking a model and executing it on the provided OHLCV data.
#'
#' @param model_file A string with the name of the YAML file describing the model.
#' @param steps An integer vector with the subset of steps to be run. If NULL, all the steps are run. Default NULL.
#' @param preview A logical value. If TRUE, a performance preview for each step is plotted. Default TRUE.
#' @param verbose A logical value. If TRUE, informative messages are printed. Default TRUE.
#'
#' @return Balance, metrics and other data is stored in a temporary database for further analysis.
#'
#' @export
#'
run_model <- function(model_file,
                      steps = NULL,
                      preview = FALSE,
                      verbose = TRUE) {

  # Initialization to avoid notes in R CMD check
  scope <- metric <- operation <- value <- step <- open_time <- NULL

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

  # Check periods coherence
  check_periods(ohlcv_data, model)

  if (!is.null(steps)) {
    if (!is.numeric(steps))
      stop("'steps' must be positive integer.", call. = FALSE)

    steps <- as.integer(steps)

    if (any(steps) < 0)
      stop("'steps' must be positive integer.", call. = FALSE)
  }

  if (is.null(preview))
    stop("'preview' must be provided.", call. = FALSE)
  if (!is.logical(preview))
    stop("'preview' must be logical.", call. = FALSE)

  if (is.null(verbose))
    stop("'verbose' must be provided.", call. = FALSE)
  if (!is.logical(verbose))
    stop("'verbose' must be logical.", call. = FALSE)

  ohlcv_data <- crop_ohlcv(ohlcv_data, model)

  # Run ID generation
  run_id <- ids::proquint()
  if (verbose) {
    message("Running model...")
  }

  # Check timeframe coherence
  if (verbose)
    check_timeframe(model, ohlcv_data)

  if (verbose)
    message(model$description$symbol, " ", model$description$timeframe)

  if (verbose) {
    message("Start capital: $", model$management$start_capital)
    if (model$management$interest_type == "simple") {
      message("Reinvest: $", model$management$start_capital * model$management$reinvest, "/trade (or less)")
    } else {
      message("Reinvest: ", model$management$reinvest * 100, "%/trade (or less)")
    }
    message("Leverage: ", model$management$leverage, "x")
  }

  # Print IS-OOS split
  if (verbose) {
    splt <- is_oos_split(ohlcv_data, model)
    message(glue::glue("IS: {round(splt$pct_is * 100, 1)}%, OOS: {round(splt$pct_oos * 100, 1)}%"))
  }

  # Get step grid
  st <- get_model_steps(model)

  # Update steps in model with those specified in the run instruction
  st <- update_steps(steps, st)

  if (verbose)
    message(glue::glue("Steps: {st$n_steps}"))

  # Database path and deletion of previous temporary data
  check_db_path()
  delete_db()

  # Progress bar init
  if (verbose)
    pb <- utils::txtProgressBar(max = max(st$n_steps, 1), char = "+", width = 50, style = 3)

  # Best metric init
  best_target_metric <- set_best_target_metric(model, best_target_metric)

  # Step iteration
  for (i in seq_len(max(st$n_steps, 1))) {

    # Replace values
    model_step <- set_step_values(model, st, i)

    # Temporary copy of original OHLC data
    data <- ohlcv_data

    # Add indicators, entry & exit signals, stop loss price and % entry-exit
    data <- add_indicators(data, model_step)
    data <- add_signals(data, model_step)
    data <- add_sl_price(data, model_step)
    # data <- add_breakeven(data, model_step)
    data <- get_pct_entry_exit(data)

    # Compute balance applying commissions
    data <- compute_balance(data, model_step)

    # Compute metrics
    metrics <- get_metrics(data, model)
    metrics <- tidy_metrics(metrics, i, run_id)

    # Considered valid if at least 1 entry and 1 exit
    if (has_minimum_entry_exit(data)) {
      save_description(model, i, run_id)
      save_variable_step(model, st$steps, i, run_id)
      save_metrics(metrics)
      save_balance(data, i, run_id)
    }

    # Current metric
    target_metric <- get_target(model, metrics)

    if (has_minimum_entry_exit(data)) {

      if (preview) {
        preview_step(model = model,
                     ohlcv_data = data,
                     steps = max(st$n_steps, 1),
                     step = i,
                     metric = model$target$metric,
                     metric_value = target_metric)
      }

      # Target metric logic
      target <- paste(target_metric, ifelse(model$target$operation == "max", ">", "<"), best_target_metric)

      # Parse logic
      tryCatch({
        parsed_target <- parse(text = target)
      },
      error = function(e) stop(glue::glue("Unable to parse target condition '{target}'."), call. = FALSE)
      )

      # Evaluate logic
      eval_target <- eval(parsed_target)

      # Avoid NA return
      if (is.na(eval_target))
         eval_target <- FALSE

      # Update target metric value
      if (eval_target) {
        best_target_metric <- target_metric
        best_metric_data <- data
        best_step_idx <- i
        best_metrics <- metrics
      }

      if (preview) {
        preview_best_metric_data(ohlcv_data = best_metric_data,
                                 step = best_step_idx,
                                 metric = model$target$metric,
                                 metric_value = best_target_metric)
      }

    }

    if (verbose)
      utils::setTxtProgressBar(pb, i)

  }

  cat("\n")

  # Output summary
  tryCatch({
    invisible(
      list(
        model = model_file,
        data = model$description$data,
        target = metrics() |>
          filter_step(best_step_idx) |>
          dplyr::filter(scope == model$target$scope,
                        metric == model$target$metric) |>
          dplyr::mutate(operation = model$target$operation) |>
          dplyr::relocate(operation, .before = value) |>
          dplyr::select(-step) |>
          data.frame(),
        step = best_step_idx,
        variables = variables() |>
          dplyr::filter(step == best_step_idx) |>
          dplyr::select(-step) |>
          data.frame(),
        metrics = metrics() |>
          filter_step(best_step_idx) |>
          compare_scopes() |>
          dplyr::select(-step) |>
          data.frame()
      )
    )
  },
  error = function(e) stop("Model could not return any result.", call. = FALSE))

}
