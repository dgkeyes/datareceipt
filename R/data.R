#' Get every row sent to a request
#'
#' All accepted rows across all of a request's submissions, as one tibble with
#' a typed column per spec column. Text columns are character, numbers are
#' double, whole numbers are integer, dates are `Date`, and yes/no columns are
#' logical; an empty cell is `NA`. Ahead of the data columns come
#' `submission_id` and `row` (the row's position within its submission), plus,
#' unless `include_sender = FALSE`, `submitted_at`, `sender_name`, and
#' `sender_email`.
#'
#' A cell that broke a rule on a column set to accept and flag (rather than
#' block the submission) is kept as the sender typed it. Where that text still
#' fits the column's type it is cast like any other value (an out-of-range
#' `"200"` in a whole-number column is `200L`); where it does not (`"abc"` in
#' the same column) it is `NA`. Either way [get_flags()] lists every flagged
#' cell with its text and the rule it broke.
#'
#' The site paginates large requests; this function follows every page and
#' returns the whole thing.
#'
#' @inheritParams get_request
#' @param include_sender Add `submitted_at`, `sender_name`, and `sender_email`
#'   columns. `TRUE` by default.
#'
#' @return A tibble with one row per submitted row. A request with no
#'   submissions yet gives a zero-row tibble with the right columns.
#' @examples
#' \dontrun{
#' hours <- get_data(12)
#' hours <- get_data("https://datareceipt.io/requests/12")
#'
#' # Without the sender columns:
#' get_data(12, include_sender = FALSE)
#' }
#' @export
get_data <- function(request, include_sender = TRUE, key = NULL) {
  id <- parse_request_id(request)
  pages <- fetch_data(id, key = key)

  values <- rows_to_tibble(field(pages$rows, "values"), pages$columns)

  meta <- tibble::tibble(
    submission_id = int_col(pages$rows, "submission_id"),
    row = int_col(pages$rows, "row")
  )

  flagged <- sum(lengths(field(pages$rows, "flags")))

  cli::cli_inform(c(
    "Fetched {nrow(values)} row{?s} from {nrow(pages$submissions)} submission{?s} for request {id}.",
    if (flagged > 0) c("i" = "{flagged} cell{?s} {?was/were} flagged; {.fn get_flags} lists them.")
  ))

  bind_meta(with_sender(meta, pages$submissions, include_sender), values)
}

# Every page of a request's data endpoint, gathered: the rows, the spec, and
# the submissions they came from.
fetch_data <- function(id, key = NULL) {
  req <- dr_request(c("requests", id, "data"), key = key) |>
    httr2::req_url_query(per_page = getOption("datareceipt.per_page", 20))

  pages <- dr_perform_cursor(req)

  list(
    rows = pages_field(pages, "data"),
    columns = pages[[1]]$meta$columns,
    submissions = submissions_to_tibble(unlist(lapply(pages, function(page) page$meta$submissions), recursive = FALSE) %||% list())
  )
}
