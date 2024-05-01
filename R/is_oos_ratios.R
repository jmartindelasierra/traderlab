
#' Print in-sample to out-os-sample ratio
#'
#' @param data A data.frame with metrics data.
#' @param assess A boolean for ratio assessment.
#'
#' @export
#'
is_oos_ratios <- function(data, assess = TRUE) {

  # Initialization to avoid notes in R CMD check
  is <- oos <- metric <- ratio <- NULL

  if (missing(data) || is.null(data))
    stop("'data' not provided.", call. = FALSE)
  if (is.null(data$is) | is.null(data$oos))
    stop("Invalid 'data'. It must be scope comparison.", call. = FALSE)

  if (is.null(assess))
    stop("'assess' not provided.", call. = FALSE)
  if (!is.logical(assess))
    stop("'assess' must be logical.", call. = FALSE)

  data <-
    data |>
    dplyr::mutate(ratio = is / oos) |>
    dplyr::select(metric, ratio)

  if (assess) {
    data <-
      data |>
      dplyr::mutate(assess = ifelse(ratio <= 1, "+", "-")) |>
      dplyr::mutate(assess = dplyr::case_when(
                      metric == "avg_bars" & ratio <= 1 ~ "-",
                      metric == "avg_bars" & ratio > 1 ~ "+",
                      metric == "exposure" & ratio <= 1 ~ "-",
                      metric == "exposure" & ratio > 1 ~ "+",
                      metric == "max_consec_losses" & ratio <= 1 ~ "-",
                      metric == "max_consec_losses" & ratio > 1 ~ "+",
                      metric == "pct_dd" & ratio <= 1 ~ "-",
                      metric == "pct_dd" & ratio > 1 ~ "+",
                      metric == "var" & ratio <= 1 ~ "-",
                      metric == "var" & ratio > 1 ~ "+",
                      TRUE ~ assess
                    ))
  }

  data
}
