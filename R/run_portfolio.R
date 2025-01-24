
run_portfolio <- function(...) {

  # Initialization to avoid notes in R CMD check
  trade_index <- time <- year <- week <- pct_balance0 <- drawdown <- NULL

  models <- list(...)

  if (length(models) <= 1)
    stop("2 or more models are required.", call. = FALSE)

  steps <- lapply(models, function(x) {
    s <- get_model_steps(x)
    if (s$n_steps > 1) {
      stop(x, " must have 1 step.", call. = FALSE)
    }
  })

  model_names <-
    sapply(unlist(models), function(x) {
      model <- read_model(x)
      model$description$name
    })

  # Compute the individual balances in the portfolio
  pf_balances <- lapply(models, function(x) {
    message("Processing ", x, appendLF = FALSE)
    run_model(x, steps = 1, verbose = FALSE)

    balances() |>
      dplyr::mutate(model = x,
                    name = unname(model_names[unique(match(x, names(model_names)))]))
  })

  create_intervals <- function(df) {
    df |>
      dplyr::filter(!is.na(trade_index)) |>
      dplyr::group_by(trade_index) |>
      dplyr::summarise(interval = lubridate::interval(dplyr::first(time), dplyr::last(time)))
  }

  check_overlap <- function(intervals1, intervals2) {
    overlap_count <- 0
    for (i in seq_along(intervals1$interval)) {
      overlap <- any(lubridate::int_overlaps(intervals1$interval[i], intervals2$interval))
      overlap_count <- overlap_count + as.integer(overlap)
    }
    return(overlap_count)
  }

  message("Computing overlaps...")

  n_models <- length(pf_balances)
  overlap_matrix <- matrix(0, n_models, n_models, dimnames = list(model_names, model_names))

  for (i in 1:n_models) {
    intervalsi <- create_intervals(pf_balances[[i]])
    for (j in 1:n_models) {
      intervalsj <- create_intervals(pf_balances[[j]])
      overlap_matrix[i, j] <- check_overlap(intervalsi, intervalsj) / length(intervalsi$interval)
      message(model_names[i], " | ", model_names[j], " -> ", round(overlap_matrix[i, j], 2))
    }
  }

  message("Processing correlations...")

  # Compute weekly returns
  weekly_returns <- lapply(pf_balances, function(x) {

    weekly_returns <-
      x |>
      dplyr::mutate(year = format(time, "%Y") |> as.integer(),
                    week = format(time, "%w") |> as.integer()) |>
      dplyr::group_by(year, week) |>
      dplyr::summarise(weekly_return = sum(pct_return, na.rm = TRUE))

    weekly_returns[[unique(x$name)]] <- weekly_returns$weekly_return
    weekly_returns$weekly_return <- NULL
    weekly_returns
  })

  # Join
  weekly_returns <-
    weekly_returns |>
    purrr::reduce(dplyr::left_join, by = c("year", "week"))

  weekly_correlations <-
    weekly_returns |>
    dplyr::ungroup() |>
    dplyr::select(-year, -week) |>
    tidyr::drop_na() |>
    stats::cor()

  # Compute monthly returns
  monthly_returns <- lapply(pf_balances, function(x) {

    monthly_returns <-
      x |>
      dplyr::mutate(year = format(time, "%Y") |> as.integer(),
                    month = format(time, "%m") |> as.integer()) |>
      dplyr::group_by(year, month) |>
      dplyr::summarise(monthly_return = sum(pct_return, na.rm = TRUE))

    monthly_returns[[unique(x$name)]] <- monthly_returns$monthly_return
    monthly_returns$monthly_return <- NULL
    monthly_returns
  })

  # Join
  monthly_returns <-
    monthly_returns |>
    purrr::reduce(dplyr::left_join, by = c("year", "month"))

  monthly_correlations <-
    monthly_returns |>
    dplyr::ungroup() |>
    dplyr::select(-year, -month) |>
    tidyr::drop_na() |>
    stats::cor()

  # Extract the individual balances in the portfolio
  bals <- lapply(pf_balances, function(x) {

    bal <-
      x |>
      dplyr::select(time, pct_balance0)

    bal[[unique(x$name)]] <- bal$pct_balance0
    bal$pct_balance0 <- NULL
    bal
  })

  # Join
  bals <-
    bals |>
    purrr::reduce(dplyr::full_join, by = "time") |>
    dplyr::arrange(time)

  for (i in 2:ncol(bals)) {
    bals[[model_names[i - 1]]] <- zoo::na.locf0(bals[[model_names[i - 1]]])
  }

  # Drawdown
  bals <-
    bals |>
    dplyr::mutate(total_balance = rowSums(dplyr::across(dplyr::contains(model_names)), na.rm = TRUE))

  bals$balance <- bals$total_balance
  bals <- compute_drawdown(bals)
  bals$balance <- NULL
  bals$pct_drawdown <- NULL
  bals <- bals |> dplyr::rename("total_drawdown" = drawdown)

  list(overlap = overlap_matrix,
       weekly_correlations = weekly_correlations,
       monthly_correlations = monthly_correlations,
       drawdown = c("Avg. drawdown" = mean(bals$total_drawdown, na.rm = TRUE),
                    "Max. drawdown" = min(bals$total_drawdown, na.rm = TRUE)),
       total_balance = bals)
}
