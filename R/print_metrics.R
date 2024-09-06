
#' Print metrics
#'
#' @param step A integer with the model step to print.
#'
#' @export
#'
print_metrics <- function(step = 1) {

  # Initialization to avoid notes in R CMD check
  metric <- NULL

  if (is.null(step))
    stop("'step' must be provided.", call. = FALSE)
  if (!is.numeric(step))
    stop("'step' must be integer.", call. = FALSE)
  if (length(step) > 1)
    stop("'step' must have length 1.", call. = FALSE)
  if (step < 1)
    stop("'step' must equal or greater than 1.", call. = FALSE)

  step <- as.integer(step)

  last_run_db_exists()

  con <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{Sys.getenv('TRADERLAB_DB_PATH')}/last_run.sqlite"))
  metrics <-
    dplyr::tbl(con, "metrics") |>
    dplyr::filter(step == {{step}}) |>
    dplyr::collect()
  DBI::dbDisconnect(con)

  metrics |>
    compare_scopes() |>
    dplyr::select(-step) |>
    dplyr::slice(match(c("trades",
                         "monthly_trades",
                         "pct_return",
                         "avg_pct_return",
                         "avg_pct_winner",
                         "avg_pct_loser",
                         "win_rate",
                         "winners_losers_ratio",
                         "avg_bars",
                         "exposure",
                         "expectancy",
                         "profit_factor",
                         "max_consec_losers",
                         "reward_risk_ratio",
                         "cagr",
                         "annual_volatility",
                         "pct_dd",
                         "return_dd",
                         "sharpe_ratio",
                         "r_squared",
                         "sqn",
                         "var"),
                       metric)) |>
    gt::gt() |>
    gt::cols_label(metric = "",
                   is = "In-sample",
                   oos = "Out-of-sample",
                   full = "Full-sample") |>
    gt::text_replace(pattern = "^trades", replacement = "# trades") |>
    gt::text_replace(pattern = "monthly_trades", replacement = "# trades / month") |>
    gt::text_replace(pattern = "^pct_return", replacement = "% return") |>
    gt::text_replace(pattern = "avg_pct_return", replacement = "Avg. % return") |>
    gt::text_replace(pattern = "avg_pct_winner", replacement = "Avg. % winner") |>
    gt::text_replace(pattern = "avg_pct_loser", replacement = "Avg. % loser") |>
    gt::text_replace(pattern = "win_rate", replacement = "% winners") |>
    gt::text_replace(pattern = "winners_losers_ratio", replacement = "# winners / # losers") |>
    gt::text_replace(pattern = "avg_bars", replacement = "Avg. bars") |>
    gt::text_replace(pattern = "exposure", replacement = "Exposure") |>
    gt::text_replace(pattern = "expectancy", replacement = "Expectancy") |>
    gt::text_replace(pattern = "profit_factor", replacement = "Profit factor") |>
    # gt::text_replace(pattern = "max_consec_winners", replacement = "Max. consec. wins") |>
    gt::text_replace(pattern = "max_consec_losers", replacement = "Max. consec. losers") |>
    gt::text_replace(pattern = "reward_risk_ratio", replacement = "Reward / risk") |>
    gt::text_replace(pattern = "cagr", replacement = "CAGR") |>
    # gt::text_replace(pattern = "annual_return", replacement = "Annualized return") |>
    gt::text_replace(pattern = "annual_volatility", replacement = "Annualized volatility") |>
    gt::text_replace(pattern = "pct_dd", replacement = "% drawdown") |>
    gt::text_replace(pattern = "return_dd", replacement = "Return / drawdown") |>
    # gt::text_replace(pattern = "CAGR_dd", replacement = "CAGR / drawdown") |>
    gt::text_replace(pattern = "sharpe_ratio", replacement = "Sharpe ratio") |>
    gt::text_replace(pattern = "r_squared", replacement = "R-squared") |>
    gt::text_replace(pattern = "sqn", replacement = "SQN") |>
    gt::text_replace(pattern = "^var", replacement = "Monthly 5%-VaR") |>
    # gt::text_replace(pattern = "cvar", replacement = "Monthly 5%-CVaR") |>
    gt::fmt_percent(rows = metric %in% c("pct_return", "avg_pct_return", "avg_pct_winner", "avg_pct_loser", "win_rate", "cagr", "exposure", "annual_return", "annual_volatility", "pct_dd", "var", "cvar")) |>
    gt::fmt_integer(rows = metric %in% c("trades", "max_consec_winners", "max_consec_losers")) |>
    gt::fmt_number(rows = metric %in% c("monthly_trades", "profit_factor", "winners_losers_ratio", "reward_risk_ratio", "avg_bars", "return_dd", "cagr_dd", "sharpe_ratio", "r_squared", "k_ratio", "sqn")) |>
    gt::fmt_currency(rows = metric %in% c("expectancy")) |>
    gt::tab_options(table.font.size = gt::px(10))
}
