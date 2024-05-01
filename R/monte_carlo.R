
#' Monte Carlo simulation
#'
#' @param step An integer with a valid step in balances.
#' @param scope A string for the scope taking values "is" (in-sample) or "oos" (out-of-sample).
#' @param samples An integer with the number of iterations.
#' @param replace Logical value for resampling with or without replacement.
#' @param verbose Shows the progress.
#'
monte_carlo <- function(step = NULL, scope, samples, replace, verbose) {

  # Initialization to avoid notes in R CMD check
  exit <- time <- NULL

  if (is.null(step))
    stop("'step' must be provided.", call. = FALSE)

  if (!is.numeric(step))
    stop("'step' must be numeric.", call. = FALSE)

  step <- as.integer(step)

  if (!scope %in% c("is", "oos"))
    stop("'scope' must be either 'is' or 'oos'.", call. = FALSE)

  if (is.null(samples))
    stop("'samples' must be provided.", call. = FALSE)

  if (verbose) {
    message(glue::glue("Computing {samples} "), appendLF = FALSE)
    scope_description <-
      switch(scope,
           "full" = "full-sample",
           "is" = "in-sample",
           "oos" = "out-of-sample"
    )
    message(glue::glue("{scope_description} simulations..."))
  }

  last_run_db_exists()

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  balance <-
    dplyr::tbl(con, "balances") |>
    dplyr::filter(step == {{step}},
                  scope == {{scope}}) |>
    dplyr::collect()
  DBI::dbDisconnect(con)

  balance <-
    balance |>
    dplyr::filter(exit == 1) |>
    dplyr::mutate(time = as.POSIXct(time, origin = "1970-01-01"))

  start_capital <- balance$balance[1] / (1 + balance$pct_return[1])

  balance_smp <- data.frame()

  # Progress bar init
  if (verbose) {
    pb <- utils::txtProgressBar(max = samples, char = "+", width = 50, style = 3)
  }

  for (i in 1:samples) {

    balance_tmp <- balance

    i_smp <- sample(1:nrow(balance_tmp), length(1:nrow(balance_tmp)), replace = {{replace}})
    pct_return_smp <- balance_tmp$pct_return[i_smp]

    balance_vec <- c()
    bal <- start_capital
    for (j in 1:nrow(balance_tmp)) {
      balance_vec[j] <- bal + pct_return_smp[j] * bal
      bal <- balance_vec[j]
    }

    balance_smp_tmp <-
      data.frame(sample = ids::random_id(),
                 time = balance_tmp$time,
                 pct_return = pct_return_smp,
                 balance = balance_vec)

    dd <- balance_drawdown(balance_smp_tmp)
    balance_smp_tmp$drawdown <- dd[[1]]
    balance_smp_tmp$pct_drawdown <- dd[[2]]

    balance_smp <-
      rbind(balance_smp, balance_smp_tmp)

    if (verbose) {
      utils::setTxtProgressBar(pb, i)
    }
  }

  balance_smp$sample <- as.factor(balance_smp$sample)

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  DBI::dbWriteTable(con, "balance_resample", balance_smp, overwrite = TRUE)
  DBI::dbDisconnect(con)

  balance_smp_ci <-
    balance_smp |>
    dplyr::group_by(time) |>
    ggdist::median_qi(balance, .width = c(0.50, 0.80, 0.95)) |>
    dplyr::ungroup()

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  DBI::dbWriteTable(con, "balance_resample_ci", balance_smp_ci, overwrite = TRUE)
  DBI::dbDisconnect(con)

}

balance_drawdown <- function(balance_data) {

  drawdown <- vector("numeric", nrow(balance_data))
  pct_drawdown <- vector("numeric", nrow(balance_data))

  balance_data$drawdown <- 0
  balance_data$pct_drawdown <- 0
  max_balance <- 0

  for (i in 1:nrow(balance_data)) {
    if (balance_data$balance[i] > max_balance) {
      max_balance <- balance_data$balance[i]
    } else {
      drawdown[i] <- balance_data$balance[i] - max_balance
      pct_drawdown[i] <- drawdown[i] / max_balance
    }
  }

  list(drawdown = drawdown, pct_drawdown = pct_drawdown)
}
