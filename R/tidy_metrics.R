
#' Convert metrics list to tidy data.frame
#'
#' @param metrics A list with metrics.
#' @param step An integer with the current step.
#' @param run_id A string with the ID of the current run.
#'
#' @return The function returns a tidy data.frame.
#'
tidy_metrics <- function(metrics, step, run_id) {

  metrics <-
    lapply(names(metrics), function(name) {
      metrics[[name]] |>
        data.frame() |>
        t() |>
        as.data.frame() |>
        tibble::rownames_to_column() |>
        stats::setNames(c("variable", "value")) |>
        dplyr::mutate(run_id = run_id,
                      step = step,
                      scope = name)
    })

  metrics <-
    do.call(rbind, metrics) |>
    dplyr::mutate(scope = dplyr::case_when(
      grepl("full", scope) ~ "full",
      grepl("in", scope) ~ "is",
      grepl("out", scope) ~ "oos"
    ))

  metrics
}
