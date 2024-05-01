
#' Check if provided data is OHLCV data as expected
#'
#' @param data A data.frame with OHLCV data.
#'
is_ohlcv <-  function(data) {

  # Initialization to avoid notes in R CMD check
  V1 <- same_class <- NULL

  expected_cols <- c("open_time", "open", "high", "low", "close", "volume", "close_time")
  expected_classes <- c("POSIXct", "numeric", "numeric", "numeric", "numeric", "numeric", "POSIXct")

  expected_structure <-
    data.frame(column = expected_cols,
               class = expected_classes)

  input_structure <-
    lapply(data, class) |>
    data.frame() |>
    t() |>
    as.data.frame() |>
    tibble::rownames_to_column()

  valid_data <-
    merge(expected_structure,
          input_structure,
          by.x = "column",
          by.y = "rowname",
          all.x = TRUE) |>
    dplyr::mutate(same_class = class == V1) |>
    dplyr::mutate(same_class = ifelse(!is.na(same_class), same_class, FALSE)) |>
    dplyr::pull(same_class) |>
    all()

  if (!valid_data)
    stop("Invalid OHLCV data.", call. = FALSE)

  valid_data
}
