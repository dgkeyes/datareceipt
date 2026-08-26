# List your requests

Every request in your account, newest first.

## Usage

``` r
list_requests(key = NULL)
```

## Arguments

- key:

  Your API key. Defaults to the `DATARECEIPT_API_KEY` environment
  variable; see
  [`datareceipt_api_key()`](https://dgkeyes.github.io/datareceipt/reference/datareceipt_api_key.md).

## Value

A tibble with one row per request: `id`, `title`, `description`,
`is_open`, `closed_at`, `submission_count`, `row_count`, `share_url`,
`created_at`, `updated_at`, and `columns`, a list column holding each
request's spec in the shape
[`get_columns()`](https://dgkeyes.github.io/datareceipt/reference/get_columns.md)
returns.

## Examples

``` r
if (FALSE) { # \dontrun{
list_requests()
} # }
```
