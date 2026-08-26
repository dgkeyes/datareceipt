#' Set your Data Receipt API key
#'
#' Data Receipt identifies you by an API token, which you create on the site
#' under Settings > API tokens. Every function in this package looks for it in
#' the `DATARECEIPT_API_KEY` environment variable, or takes it directly as a
#' `key` argument.
#'
#' With `install = TRUE` the key is written to your `.Renviron` file so it is
#' picked up in every future R session, the same way
#' `tidycensus::census_api_key()` works. Any existing `.Renviron` is backed up
#' to `.Renviron_backup` first.
#'
#' @param key Your token, as shown once when you created it. It looks like
#'   `"12|dr_..."`.
#' @param install If `TRUE`, save the key to `.Renviron` for future sessions.
#'   If `FALSE` (the default), set it for the current session only.
#' @param overwrite If `TRUE`, replace a key already saved in `.Renviron`.
#'
#' @return The key, invisibly.
#' @examples
#' \dontrun{
#' # Once, on each computer you use:
#' datareceipt_api_key("12|dr_...", install = TRUE)
#'
#' # Or for this session only:
#' datareceipt_api_key("12|dr_...")
#' }
#' @export
datareceipt_api_key <- function(key, install = FALSE, overwrite = FALSE) {
  check_key(key)

  if (!install) {
    Sys.setenv(DATARECEIPT_API_KEY = key)
    cli::cli_inform(c(
      "v" = "API key set for this session.",
      "i" = "Run with {.code install = TRUE} to save it for future sessions."
    ))
    return(invisible(key))
  }

  renviron <- file.path(Sys.getenv("HOME"), ".Renviron")
  lines <- if (file.exists(renviron)) readLines(renviron, warn = FALSE) else character()
  existing <- grepl("^DATARECEIPT_API_KEY=", lines)

  if (any(existing) && !overwrite) {
    cli::cli_abort(c(
      "A {.envvar DATARECEIPT_API_KEY} is already saved in {.path {renviron}}.",
      "i" = "Run with {.code overwrite = TRUE} to replace it."
    ))
  }

  if (file.exists(renviron)) {
    file.copy(renviron, paste0(renviron, "_backup"), overwrite = TRUE)
  }

  lines <- c(lines[!existing], sprintf("DATARECEIPT_API_KEY='%s'", key))
  writeLines(lines, renviron)
  Sys.setenv(DATARECEIPT_API_KEY = key)

  cli::cli_inform(c(
    "v" = "API key saved to {.path {renviron}} and set for this session.",
    "i" = "It will be picked up automatically whenever R starts."
  ))

  invisible(key)
}

#' Is an API key available?
#'
#' @return `TRUE` if a key is set in the `DATARECEIPT_API_KEY` environment
#'   variable, `FALSE` otherwise.
#' @examples
#' datareceipt_has_key()
#' @export
datareceipt_has_key <- function() {
  nzchar(Sys.getenv("DATARECEIPT_API_KEY"))
}

# The key to use: an explicit argument first, then the environment variable.
dr_key <- function(key = NULL, call = rlang::caller_env()) {
  key <- key %||% Sys.getenv("DATARECEIPT_API_KEY")

  if (!is_string(key) || !nzchar(key)) {
    cli::cli_abort(c(
      "A Data Receipt API key is required.",
      "i" = "Create one on the site under Settings > API tokens, then run {.code datareceipt_api_key(\"...\", install = TRUE)} or pass it as {.arg key}."
    ), call = call)
  }

  key
}

check_key <- function(key, call = rlang::caller_env()) {
  if (!is_string(key) || !nzchar(key)) {
    cli::cli_abort("{.arg key} must be a single non-empty string.", call = call)
  }
}

is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}
