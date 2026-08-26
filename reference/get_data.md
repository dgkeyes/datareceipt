# Get every row sent to a request

All accepted rows across all of a request's submissions, as one tibble
with a typed column per spec column. Text columns are character, numbers
are double, whole numbers are integer, dates are `Date`, and yes/no
columns are logical; an empty cell is `NA`. Ahead of the data columns
come `submission_id` and `row` (the row's position within its
submission), plus, unless `include_sender = FALSE`, `submitted_at`,
`sender_name`, and `sender_email`.

## Usage

``` r
get_data(request, include_sender = TRUE, key = NULL)
```

## Arguments

- request:

  A request id (`12`), or the request's URL on the site
  (`"https://datareceipt.io/requests/12"`), or one row of
  [`list_requests()`](https://dgkeyes.github.io/datareceipt/reference/list_requests.md).

- include_sender:

  Add `submitted_at`, `sender_name`, and `sender_email` columns. `TRUE`
  by default.

- key:

  Your API key. Defaults to the `DATARECEIPT_API_KEY` environment
  variable; see
  [`datareceipt_api_key()`](https://dgkeyes.github.io/datareceipt/reference/datareceipt_api_key.md).

## Value

A tibble with one row per submitted row. A request with no submissions
yet gives a zero-row tibble with the right columns.

## Details

A cell that broke a rule on a column set to accept and flag (rather than
block the submission) is kept as the sender typed it. Where that text
still fits the column's type it is cast like any other value (an
out-of-range `"200"` in a whole-number column is `200L`); where it does
not (`"abc"` in the same column) it is `NA`. Either way
[`get_flags()`](https://dgkeyes.github.io/datareceipt/reference/get_flags.md)
lists every flagged cell with its text and the rule it broke.

The site paginates large requests; this function follows every page and
returns the whole thing.

## Examples

``` r
if (FALSE) { # \dontrun{
hours <- get_data(12)
hours <- get_data("https://datareceipt.io/requests/12")

# Without the sender columns:
get_data(12, include_sender = FALSE)
} # }
```
