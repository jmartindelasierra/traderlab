
#' Checks if provided data is variable data as expected
#'
#' @param data A data.frame with variable data.
#'
is_variable <-  function(data) {

  # Initialization to avoid notes in R CMD check
  V1 <- same_class <- NULL

  if (!"data.frame" %in% class(data))
    return(FALSE)

  expected_cols <- c("step", "variable", "value")
  expected_classes <- c("integer", "character", "numeric")

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

  valid_data
}
