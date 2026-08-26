#' Which account does my key belong to?
#'
#' The cheapest way to check that a key works.
#'
#' @inheritParams list_requests
#'
#' @return A one-row tibble: `id`, `name`, `email`.
#' @examples
#' \dontrun{
#' datareceipt_whoami()
#' }
#' @export
datareceipt_whoami <- function(key = NULL) {
  body <- dr_perform(dr_request("user", key = key))

  tibble::tibble(
    id = as.integer(body$id),
    name = as.character(body$name),
    email = as.character(body$email)
  )
}
