
#' Checks the structure of the YAML file
#'
#' The function is_model() performs a series of checkings on the YAML structure.
#'
#' @param model A string of parsed YAML file describing the model
#'
#' @return Returns TRUE if the structure is as expected. Otherwise the execution is stopped.
#'
is_model <- function(model) {

  if (!all(c("description", "indicators", "rules", "management", "periods", "target", "steps") %in% names(model)))
    stop("Missing key(s): 'description', 'indicators', 'rules', 'management', 'periods', 'target' and 'steps' must exist.", call. = FALSE)

  if (!"data" %in% names(model$description))
    stop("Missing 'data' key in 'description'.", call. = FALSE)

  if (!all(c("name", "symbol", "timeframe") %in% names(model$description)))
    message("Missing key(s) in 'description': 'name', 'symbol' or 'timeframe'. Not mandatory but recommended.")

  if(!is.character(model$description$symbol))
    stop("Invalid format for 'symbol'. Must be character.", call. = FALSE)

  if(!is.character(model$description$timeframe))
    stop("Invalid format for 'timeframe'. Must be character.", call. = FALSE)

  if (length(model$indicators) == 0)
    stop("Missing indicator(s) in model.", call. = FALSE)

  if (!all(c("entry_signal", "exit_signal") %in% names(model$rules)))
    stop("Missing key(s) in 'rules': 'entry_signal' and 'exit_signal' must exist.", call. = FALSE)

  if (is.null(model$rules$entry_signal) | is.null(model$rules$exit_signal))
    stop("Missing values(s) in 'rules': 'entry_signal' or 'exit_signal')", call. = FALSE)

  if (!all(c("position", "start_capital", "interest_type", "reinvest", "leverage", "fee_type", "fee") %in% names(model$management)))
    stop("Missing key(s) in 'management': 'position', 'start_capital', 'interest_type', 'reinvest', 'leverage', 'fee_type' and 'fee' must exist.", call. = FALSE)

  if(!all(!lapply(model$management, is.null) |> unlist()))
    stop("Missing values(s) in 'management': 'position', 'start_capital', 'interest_type', 'reinvest', 'leverage', 'fee_type' or 'fee'.", call. = FALSE)

  if (!model$management$position %in% c("long"))
    stop("Invalid 'position' format. Must be 'long' ('short' is disabled for now).", call. = FALSE)

  if (!is.numeric(model$management$start_capital))
    stop("Invalid 'start_capital' format. Must be numeric.", call. = FALSE)

  if (!model$management$interest_type %in% c("simple", "compound"))
    stop("Invalid 'interest_type'. Must be either 'simple' or 'compound'.", call. = FALSE)

  if (!is.numeric(model$management$reinvest))
    stop("Invalid 'reinvest' format. Must be numeric.", call. = FALSE)

  if (!is.numeric(model$management$leverage) & !grepl("\\$", model$management$leverage))
    stop("Invalid 'leverage' format. Must be either numeric or variable.", call. = FALSE)

  if (!model$management$fee_type %in% c("per_trade_pct", "per_trade_fixed"))
    stop("Invalid 'fee_type'. Must be either 'per_trade_pct' or 'per_trade_fixed'.", call. = FALSE)

  if (!is.numeric(model$management$fee))
    stop("Invalid 'fee' format. Must be numeric.", call. = FALSE)

  if (!is.null(model$periods$start)) {
    tryCatch({
      as.Date(model$periods$start)
    },
    error = function(e) { stop("Invalid 'start' format. Must be yyyy-mm-dd.", call. = FALSE) }
    )
  }

  if (!is.null(model$periods$end)) {
    tryCatch({
      as.Date(model$periods$end)
    },
    error = function(e) { stop("Invalid 'end' format. Must be yyyy-mm-dd.", call. = FALSE) }
    )
  }

  if (!"oos_start" %in% names(model$periods))
    stop("Missing key in 'periods': 'oos_start' must exist.", call. = FALSE)

  if (is.null(model$periods$oos_start))
    stop("Missing value for 'oos_start'.", call. = FALSE)

  tryCatch({
    as.Date(model$periods$oos_start)
  },
  error = function(e) { stop("Invalid 'oos_start' format. Must be yyyy-mm-dd.", call. = FALSE) }
  )

  if (!all(c("scope", "metric", "operation") %in% names(model$target)))
    stop("Missing key(s) in 'target': 'scope', 'metric' and 'operation' must exist.", call. = FALSE)

  if (is.null(model$target$scope) | is.null(model$target$metric) | is.null(model$target$operation))
    stop("Missing value(s) in 'target': 'scope', 'metric' or 'operation'.", call. = FALSE)

  if (!model$target$scope %in% c("full", "is", "oos"))
    stop("Invalid 'scope'. Must be either 'full', 'is' or 'oos'.", call. = FALSE)

  if (!model$target$operation %in% c("max", "min"))
    stop("Invalid 'operation'. Must be either 'max' or 'min'.", call. = FALSE)

  invisible(TRUE)
}
