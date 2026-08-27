# List a request's submissions

Who sent what, and when, oldest first. The rows themselves come from
[`get_data()`](https://dgkeyes.github.io/datareceipt/reference/get_data.md)
(all submissions at once) or
[`get_submission()`](https://dgkeyes.github.io/datareceipt/reference/get_submission.md)
(one).

## Usage

``` r
list_submissions(request, key = NULL)
```

## Arguments

- request:

  A request id (`12`), or the request's URL on the site
  (`"https://datareceipt.io/requests/12"`), or one row of
  [`list_requests()`](https://dgkeyes.github.io/datareceipt/reference/list_requests.md).

- key:

  Your API key. Defaults to the `DATARECEIPT_API_KEY` environment
  variable; see
  [`datareceipt_api_key()`](https://dgkeyes.github.io/datareceipt/reference/datareceipt_api_key.md).

## Value

A tibble with one row per submission: `id`, `request_id`, `sender_name`,
`sender_email`, `source` (how the data came in: an uploaded `"xlsx"` or
`"csv"`; submissions from August 2026 may read `"paste"`, `"typed"`, or
`"form"`, from sender methods the site no longer offers), `row_count`,
`flag_count` (cells that broke a rule but were accepted; see
[`get_flags()`](https://dgkeyes.github.io/datareceipt/reference/get_flags.md)),
`original_filename`, `submitted_at`, and `revised_at` (when the
request's owner last edited the submission's data on the site, or `NA`
if it is as received).

## Examples

``` r
if (FALSE) { # \dontrun{
list_submissions(12)
} # }
```
