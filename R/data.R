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

  req <- dr_request(c("requests", id, "data"), key = key) |>
    httr2::req_url_query(per_page = getOption("datareceipt.per_page", 20))

  pages <- dr_perform_cursor(req)

  rows <- pages_field(pages, "data")
  columns <- pages[[1]]$meta$columns
  submissions <- submissions_to_tibble(unlist(lapply(pages, function(page) page$meta$submissions), recursive = FALSE) %||% list())

  values <- rows_to_tibble(field(rows, "values"), columns)

  meta <- tibble::tibble(
    submission_id = int_col(rows, "submission_id"),
    row = int_col(rows, "row")
  )

  cli::cli_inform("Fetched {nrow(values)} row{?s} from {nrow(submissions)} submission{?s} for request {id}.")

  bind_meta(with_sender(meta, submissions, include_sender), values)
}
