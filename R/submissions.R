#' List a request's submissions
#'
#' Who sent what, and when, oldest first. The rows themselves come from
#' [get_data()] (all submissions at once) or [get_submission()] (one).
#'
#' @inheritParams get_request
#'
#' @return A tibble with one row per submission: `id`, `request_id`,
#'   `sender_name`, `sender_email`, `row_count`, `original_filename`, and
#'   `submitted_at`.
#' @examples
#' \dontrun{
#' list_submissions(12)
#' }
#' @export
list_submissions <- function(request, key = NULL) {
  id <- parse_request_id(request)

  req <- dr_request(c("requests", id, "submissions"), key = key) |>
    httr2::req_url_query(per_page = 100)

  submissions_to_tibble(pages_field(dr_perform_pages(req), "data"))
}

#' Get one submission's rows
#'
#' The same shape as [get_data()], for a single submission.
#'
#' @param submission A submission id, or one row of [list_submissions()].
#' @inheritParams get_data
#'
#' @return A tibble in the shape of [get_data()].
#' @examples
#' \dontrun{
#' get_submission(8)
#' }
#' @export
get_submission <- function(submission, include_sender = TRUE, key = NULL) {
  id <- parse_submission_id(submission)

  body <- dr_perform(dr_request(c("submissions", id), key = key))$data

  values <- rows_to_tibble(body$rows, body$columns)
  submissions <- submissions_to_tibble(list(body))

  meta <- tibble::tibble(
    submission_id = rep(as.integer(body$id), nrow(values)),
    row = seq_len(nrow(values))
  )

  bind_meta(with_sender(meta, submissions, include_sender), values)
}

submissions_to_tibble <- function(items) {
  tibble::tibble(
    id = int_col(items, "id"),
    request_id = int_col(items, "request_id"),
    sender_name = chr_col(items, "sender_name"),
    sender_email = chr_col(items, "sender_email"),
    row_count = int_col(items, "row_count"),
    original_filename = chr_col(items, "original_filename"),
    submitted_at = time_col(items, "submitted_at")
  )
}

# Add submitted_at, sender_name, and sender_email to per-row metadata by
# looking each row's submission up.
with_sender <- function(meta, submissions, include_sender) {
  if (!include_sender) {
    return(meta)
  }

  at <- match(meta$submission_id, submissions$id)

  meta$submitted_at <- submissions$submitted_at[at]
  meta$sender_name <- submissions$sender_name[at]
  meta$sender_email <- submissions$sender_email[at]

  meta
}
