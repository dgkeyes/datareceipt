#' List the flagged cells of a request
#'
#' A request's owner can set a column to accept a value that breaks its rules
#' and flag it, rather than block the whole submission. This returns every
#' such cell across every submission: where it is, what the sender typed, and
#' which rule it broke. The same cells appear in [get_data()] cast to the
#' column's type where the text allows it, and as `NA` where it does not.
#'
#' @inheritParams get_request
#'
#' @return A tibble with one row per flagged cell: `submission_id`, `row` (the
#'   row's position within its submission), `submitted_at`, `sender_name`,
#'   `sender_email`, `column`, `value` (the text as sent), and `message` (the
#'   rule it broke). Zero rows when nothing is flagged.
#' @examples
#' \dontrun{
#' get_flags(12)
#' }
#' @export
get_flags <- function(request, key = NULL) {
  id <- parse_request_id(request)
  pages <- fetch_data(id, key = key)

  flags_to_tibble(pages$rows, pages$submissions)
}

# One row per flag across a list of data rows, with the sender looked up.
flags_to_tibble <- function(rows, submissions) {
  items <- unlist(lapply(rows, function(row) {
    lapply(row$flags %||% list(), function(flag) {
      c(list(submission_id = row$submission_id, row = row$row), flag)
    })
  }), recursive = FALSE) %||% list()

  meta <- tibble::tibble(
    submission_id = int_col(items, "submission_id"),
    row = int_col(items, "row")
  )

  out <- with_sender(meta, submissions, include_sender = TRUE)
  out$column <- chr_col(items, "column")
  out$value <- chr_col(items, "value")
  out$message <- chr_col(items, "message")

  out
}
