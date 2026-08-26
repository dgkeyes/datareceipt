# A request id from whatever a person is likely to have to hand: the number,
# the request's URL on the site copied from the browser, or a row from
# list_requests() or get_request().
parse_request_id <- function(request, call = rlang::caller_env()) {
  if (is.data.frame(request) && nrow(request) == 1 && "id" %in% names(request)) {
    return(as.integer(request$id))
  }

  id <- parse_id(request, pattern = "requests/([0-9]+)")

  if (is.na(id)) {
    cli::cli_abort(c(
      "{.arg request} must be a request id, or its URL on the site.",
      "i" = "For example {.code get_data(12)} or {.code get_data(\"https://datareceipt.io/requests/12\")}."
    ), call = call)
  }

  id
}

parse_submission_id <- function(submission, call = rlang::caller_env()) {
  if (is.data.frame(submission) && nrow(submission) == 1 && "id" %in% names(submission)) {
    return(as.integer(submission$id))
  }

  id <- parse_id(submission, pattern = "submissions/([0-9]+)")

  if (is.na(id)) {
    cli::cli_abort(c(
      "{.arg submission} must be a submission id.",
      "i" = "Find ids with {.fn list_submissions}."
    ), call = call)
  }

  id
}

parse_id <- function(x, pattern) {
  if (is.numeric(x) && length(x) == 1 && !is.na(x) && x > 0 && x == trunc(x)) {
    return(as.integer(x))
  }

  if (is_string(x)) {
    if (grepl("^[0-9]+$", x)) {
      return(as.integer(x))
    }

    match <- regmatches(x, regexec(pattern, x))[[1]]

    if (length(match) == 2) {
      return(as.integer(match[[2]]))
    }
  }

  NA_integer_
}
