
#' Load OHLCV data from file
#'
#' @param ohlcv_file A string with full path to OHLCV file.
#'
load_ohlcv <- function(ohlcv_file) {

  if (missing(ohlcv_file))
    stop("'ohlcv_file' must be provided.", call. = FALSE)

  if (is.null(ohlcv_file))
    stop("'ohlcv_file' must be provided.", call. = FALSE)

  tryCatch({
    readRDS(ohlcv_file)
  },
  warning = function(w) stop(glue::glue("Could not read file {ohlcv_file}."), call. = FALSE),
  error = function(e) stop(glue::glue("Could not read file {ohlcv_file}."), call. = FALSE)
  )

}
