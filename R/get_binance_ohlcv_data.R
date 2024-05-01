
#' Get OHLCV data from Binance
#'
#' @param symbol A string with the symbol ("BTC", "ETH", ...).
#' @param timeframe A string with the timeframe ("15m", "1h", "4h", ...).
#'
#' @return This function retrieves OHLCV data from Binance and saves in ./datasets.
#' @export
#'
get_binance_ohlcv_data <- function(symbol, timeframe) {

  # Initialization to avoid notes in R CMD check
  Var1 <- NULL

  if (missing(symbol) || is.null(symbol))
    stop("'symbol' must be provided.", call. = FALSE)
  if (!is.character(symbol))
    stop("'symbol' must be character.", call. = FALSE)
  if (length(symbol) > 1)
    stop("'symbol' must have length 1.", call. = FALSE)

  if (missing(timeframe) || is.null(timeframe))
    stop("'timeframe' must be provided.", call. = FALSE)
  if (!is.character(timeframe))
    stop("'timeframe' must be character.", call. = FALSE)
  if (length(timeframe) > 1)
    stop("'timeframe' must have length 1.", call. = FALSE)

  timeframes <- c("1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w")

  if (!timeframe %in% timeframes)
    stop("Invalid 'timeframe'.", call. = FALSE)

  # Make pair
  pair <- glue::glue(toupper(symbol), "USDT")

  # Repository URL
  url <- glue::glue("https://data.binance.vision/data/spot/monthly/klines/{pair}/{timeframe}/")

  # Make file names
  years <- 2017:format(Sys.Date(), "%Y")
  months <- stringr::str_pad(1:12, width = 2, side = "left", pad = 0)

  files <-
    expand.grid(years, months) |>
    dplyr::arrange(Var1) |>
    dplyr::mutate(file = glue::glue("{pair}-{timeframe}-{Var1}-{Var2}.zip")) |>
    dplyr::pull(file)

  # First 7 months of 2017 are not available in Binance
  files <- utils::tail(files, -7)

  # Remove current month from list
  files <- utils::head(files, -(12 - (lubridate::month(Sys.Date()) - 1)))

  # Initialize vector for files not downloaded
  files_not_downloaded <- c()

  message(glue::glue("Downloading {pair} data..."))

  # Download and unzip
  pbapply::pblapply(files, function(x) {

    if (!file.exists(paste0(tempdir(), stringr::str_replace(x, ".zip", ".csv")))) {

      suppressWarnings(
        try({
          utils::download.file(url = paste0(url, x),
                               destfile = paste0(tempdir(), "/", x),
                               quiet = TRUE)
        }, silent = TRUE)
      )

      if (file.exists(paste0(tempdir(), "/", x))) {

        utils::unzip(zipfile = paste0(tempdir(), "/", x),
                     exdir = tempdir())

        remove_status <- file.remove(paste0(tempdir(), "/", x))

      } else {
        files_not_downloaded <<- c(files_not_downloaded, x)
      }
    }

  })

  if (length(files_not_downloaded) > 0)
    message("Files not downloaded:\n", paste(files_not_downloaded, collapse = "\n"))

  # CSVs with OHLC data
  files <- list.files(tempdir(), pattern = ".csv")

  # CSVs to list of data.frames
  ohlcv <- lapply(files, function(x) {
    utils::read.csv(paste0(tempdir(), "/", x), header = FALSE)
  })

  # Consolidate in a single data.frame
  ohlcv <- do.call(rbind.data.frame, ohlcv)

  # Keep first 7 columns
  ohlcv <- ohlcv[, c(1:7)]
  names(ohlcv) <- c("open_time", "open", "high", "low", "close", "volume", "close_time")

  # Formatting
  ohlcv$open_time <- as.POSIXct(ohlcv$open_time / 1000, origin = "1970-01-01", tz = "UTC")
  ohlcv$close_time <- as.POSIXct(ohlcv$close_time / 1000, origin = "1970-01-01", tz = "UTC")

  # Remove files
  lapply(files, function(x) {
    remove_status <- file.remove(paste0(tempdir(), "/", x))
  })

  # Check /datasets folder existence
  if (!dir.exists(glue::glue("{getwd()}/datasets"))) {
    dir.create(glue::glue("{getwd()}/datasets"))
  }

  # Save OHLCV data as .RDS file
  saveRDS(ohlcv, file = glue::glue("{getwd()}/datasets/{tolower(pair)}_{timeframe}.rds"))
}
