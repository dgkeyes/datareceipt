# Where the API lives. DATARECEIPT_API_URL points a session at a local or
# preview copy of the site, the way GITHUB_API_URL does for gh.
dr_base_url <- function() {
  sub("/+$", "", Sys.getenv("DATARECEIPT_API_URL", unset = "https://datareceipt.io/api/v1"))
}

# One request builder for every endpoint: auth, user agent, error parsing,
# retries. Exported functions are thin wrappers around this.
dr_request <- function(path, key = NULL, call = rlang::caller_env()) {
  httr2::request(dr_base_url()) |>
    httr2::req_url_path_append(paste(path, collapse = "/")) |>
    httr2::req_auth_bearer_token(dr_key(key, call = call)) |>
    httr2::req_user_agent("datareceipt R package (https://github.com/dgkeyes/datareceipt)") |>
    httr2::req_headers(Accept = "application/json") |>
    httr2::req_error(body = dr_error_body) |>
    httr2::req_retry(max_tries = 3)
}

# What to add to an error: the API's own message plus a hint for the
# statuses a person can do something about.
dr_error_body <- function(resp) {
  body <- tryCatch(httr2::resp_body_json(resp), error = function(e) NULL)

  hint <- switch(
    as.character(httr2::resp_status(resp)),
    "401" = "Your API key was missing, wrong, expired, or revoked. Check it on the site under Settings > API tokens.",
    "403" = "Your API key does not have permission for this.",
    "404" = "Nothing with that id in your account. Check the id, and that the key belongs to the account that owns it.",
    "429" = "Too many requests: the API allows 120 a minute per account.",
    NULL
  )

  c(
    if (is_string(body$message)) body$message,
    if (!is.null(hint)) c("i" = hint)
  )
}

dr_log <- function(req) {
  if (isTRUE(getOption("datareceipt.verbose"))) {
    cli::cli_inform("GET {.url {req$url}}")
  }
}

# A single response, parsed.
dr_perform <- function(req) {
  dr_log(req)
  httr2::resp_body_json(httr2::req_perform(req))
}

# Every page of a page-numbered endpoint (Laravel's `page` + `meta.last_page`).
dr_perform_pages <- function(req) {
  dr_log(req)

  resps <- httr2::req_perform_iterative(
    req,
    next_req = httr2::iterate_with_offset(
      "page",
      resp_pages = function(resp) httr2::resp_body_json(resp)$meta$last_page
    ),
    max_reqs = Inf,
    progress = FALSE
  )

  lapply(resps, httr2::resp_body_json)
}

# Every page of a cursor-paginated endpoint (`cursor` + `meta.next_cursor`).
dr_perform_cursor <- function(req) {
  dr_log(req)

  resps <- httr2::req_perform_iterative(
    req,
    next_req = httr2::iterate_with_cursor(
      "cursor",
      resp_param_value = function(resp) httr2::resp_body_json(resp)$meta$next_cursor
    ),
    max_reqs = Inf,
    progress = FALSE
  )

  lapply(resps, httr2::resp_body_json)
}

# Concatenate one field from every page into a single list.
pages_field <- function(pages, name) {
  out <- lapply(pages, function(page) page[[name]])
  unlist(out, recursive = FALSE) %||% list()
}
