
#' Print returns
#'
#' @param step A integer with the model step to print.
#' @param pretty Logical value for showing pretty table. Default TRUE.
#'
#' @export
#'
print_returns <- function(step = 1, pretty = TRUE) {

  # Initialization to avoid notes in R CMD check
  time <- year <- month_name <- balance_end <- balance_start <- roc <- NULL

  if (is.null(step))
    stop("'step' must be provided.", call. = FALSE)
  if (!is.numeric(step))
    stop("'step' must be integer.", call. = FALSE)
  if (length(step) > 1)
    stop("'step' must have length 1.", call. = FALSE)
  if (step < 1)
    stop("'step' must equal or greater than 1.", call. = FALSE)

  step <- as.integer(step)

  if (is.null(pretty))
    stop("'pretty' must be provided.", call. = FALSE)
  if (!is.logical(pretty))
    stop("'pretty' must be logical.", call. = FALSE)
  if (length(pretty) > 1)
    stop("'pretty' must have length 1.", call. = FALSE)

  last_run_db_exists()

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  balance <-
    dplyr::tbl(con, "balances") |>
    dplyr::filter(step == {{step}}) |>
    dplyr::collect()
  DBI::dbDisconnect(con)

  time_locale <- Sys.getlocale("LC_TIME")
  Sys.setlocale("LC_TIME", "C")

  t1 <-
    balance |>
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"),
                  year = format(time, "%Y"),
                  month = format(time, "%m"),
                  month_name = format(time, "%b")) |>
    dplyr::group_by(year, month, month_name) |>
    dplyr::summarise(balance_start = dplyr::first(balance),
                     balance_end = dplyr::last(balance)) |>
    dplyr::mutate(roc = (balance_end - balance_start) / balance_start) |>
    dplyr::ungroup() |>
    dplyr::select(month, month_name, year, roc) |>
    dplyr::arrange(month) |>
    dplyr::mutate(month_name = forcats::fct_inorder(as.character(month_name))) |>
    tidyr::pivot_wider(id_cols = "year", names_from = month_name, values_from = roc) |>
    dplyr::arrange(year)

  if (pretty) {

    t1 <-
      t1 |>
      dplyr::mutate_if(is.numeric, ~na_if(., 0)) |>
      gt::gt() |>
      gt::cols_label("year" = "") |>
      gt::fmt_percent() |>
      gt::sub_missing(missing_text = "--") |>
      gt::cols_align(align = "center") |>
      gt::data_color(
        columns = 2:13,
        fn = scales::col_bin(bins = c(-Inf, 0, Inf), palette = c("firebrick", "forestgreen"), na.color = "darkgray")
      ) |>
      gt::tab_header(title = "Returns")

  }

  Sys.setlocale("LC_TIME", time_locale)

  t1
}
