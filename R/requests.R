#' List your requests
#'
#' Every request in your account, newest first.
#'
#' @param key Your API key. Defaults to the `DATARECEIPT_API_KEY` environment
#'   variable; see [datareceipt_api_key()].
#'
#' @return A tibble with one row per request: `id`, `title`, `description`,
#'   `is_open`, `closed_at`, `submission_count`, `row_count`, `share_url`,
#'   `created_at`, `updated_at`, and `columns`, a list column holding each
#'   request's spec in the shape [get_columns()] returns.
#' @examples
#' \dontrun{
#' list_requests()
#' }
#' @export
list_requests <- function(key = NULL) {
  req <- dr_request("requests", key = key) |>
    httr2::req_url_query(per_page = 100)

  requests_to_tibble(pages_field(dr_perform_pages(req), "data"))
}

#' Get one request
#'
#' @param request A request id (`12`), or the request's URL on the site
#'   (`"https://datareceipt.io/requests/12"`), or one row of [list_requests()].
#' @inheritParams list_requests
#'
#' @return A one-row tibble in the shape of [list_requests()].
#' @examples
#' \dontrun{
#' get_request(12)
#' get_request("https://datareceipt.io/requests/12")
#' }
#' @export
get_request <- function(request, key = NULL) {
  id <- parse_request_id(request)

  body <- dr_perform(dr_request(c("requests", id), key = key))

  requests_to_tibble(list(body$data))
}

#' Get a request's columns
#'
#' The spec a request was built with: each column's name, type, and rules.
#' This is what the data you get back from [get_data()] is typed by, so it is
#' the place to look before deciding what to do with the data.
#'
#' @inheritParams get_request
#'
#' @return A tibble with one row per column: `name` (the variable name the
#'   data is keyed by), `type` (one of `"text"`, `"numeric"`, `"integer"`,
#'   `"date"`, `"boolean"`), `required` (no empty cells allowed), `min`, `max`,
#'   `allowed_values` (a list column of the permitted values, empty when there
#'   is no such rule), `on_break` (`"block"` if a value breaking a rule stops
#'   the submission, `"flag"` if it is accepted and flagged; see
#'   [get_flags()]), `friendly_name` (what the form shows people, `NA` when
#'   the variable name is used), and `description` (the explanation shown to
#'   senders, `NA` when there is none).
#' @examples
#' \dontrun{
#' get_columns(12)
#' }
#' @export
get_columns <- function(request, key = NULL) {
  get_request(request, key = key)$columns[[1]]
}

requests_to_tibble <- function(items) {
  tibble::tibble(
    id = int_col(items, "id"),
    title = chr_col(items, "title"),
    description = chr_col(items, "description"),
    is_open = lgl_col(items, "is_open"),
    closed_at = time_col(items, "closed_at"),
    submission_count = int_col(items, "submission_count"),
    row_count = int_col(items, "row_count"),
    share_url = chr_col(items, "share_url"),
    created_at = time_col(items, "created_at"),
    updated_at = time_col(items, "updated_at"),
    columns = lapply(items, function(item) columns_to_tibble(item$columns))
  )
}
