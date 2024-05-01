
#' Get OHLCV data from Yahoo
#'
#' @param symbol A string with the symbol ("SPY", "QQQ", "NVDA", "TSLA", "EUR=X", "GBP=X", ...).
#' @param from A string with the start date in YYYY-mm-dd format.
#'
#' @return This function retrieves OHLCV data from Yahoo and saves in ./datasets.
#' @export
#'
get_yahoo_ohlcv_data <- function(symbol, from = "2000-01-01") {

  if (missing(symbol) || is.null(symbol))
    stop("'symbol' must be provided.", call. = FALSE)
  if (!is.character(symbol))
    stop("'symbol' must be character.", call. = FALSE)
  if (length(symbol) > 1)
    stop("'symbol' must have length 1.", call. = FALSE)

  if (is.null(from))
    stop("'from' must be provided.", call. = FALSE)
  if (!is.character(from))
    stop("'from' must be character.", call. = FALSE)
  if (length(from) > 1)
    stop("'from' must have length 1.", call. = FALSE)

  quantmod::getSymbols(symbol, src = "yahoo", from = from, return.class = 'data.frame')

  ohlcv_data <- get(symbol)

  ohlcv_data <-
    ohlcv_data |>
    tibble::rownames_to_column("open_time")

  ohlcv_data$open_time <-
    ohlcv_data$open_time |>
    as.POSIXct(tz = "UTC")

  ohlcv_data$close_time <-
    ohlcv_data$open_time +
    lubridate::hours(23) +
    lubridate::minutes(59) +
    lubridate::seconds(59)

  ohlcv_data <-
    ohlcv_data |>
    dplyr::select(-7) |>
    stats::setNames(c("open_time", "open", "high", "low", "close", "volume", "close_time"))

  # Imputation: fill with last non-NA values
  ohlcv_data$open <- zoo::na.locf0(ohlcv_data$open)
  ohlcv_data$high <- zoo::na.locf0(ohlcv_data$high)
  ohlcv_data$low <- zoo::na.locf0(ohlcv_data$low)
  ohlcv_data$close <- zoo::na.locf0(ohlcv_data$close)
  ohlcv_data$volume <- zoo::na.locf0(ohlcv_data$volume)

  # Check /datasets folder existence
  if (!dir.exists(glue::glue("{getwd()}/datasets"))) {
    dir.create(glue::glue("{getwd()}/datasets"))
  }

  # Save OHLCV data as .RDS file
  saveRDS(ohlcv_data, file = glue::glue("{getwd()}/datasets/{tolower(symbol)}_1d.rds"))
}
