# Get one submission's rows

The same shape as
[`get_data()`](https://dgkeyes.github.io/datareceipt/reference/get_data.md),
for a single submission.

## Usage

``` r
get_submission(submission, include_sender = TRUE, key = NULL)
```

## Arguments

- submission:

  A submission id, or one row of
  [`list_submissions()`](https://dgkeyes.github.io/datareceipt/reference/list_submissions.md).

- include_sender:

  Add `submitted_at`, `sender_name`, and `sender_email` columns. `TRUE`
  by default.

- key:

  Your API key. Defaults to the `DATARECEIPT_API_KEY` environment
  variable; see
  [`datareceipt_api_key()`](https://dgkeyes.github.io/datareceipt/reference/datareceipt_api_key.md).

## Value

A tibble in the shape of
[`get_data()`](https://dgkeyes.github.io/datareceipt/reference/get_data.md).

## Examples

``` r
if (FALSE) { # \dontrun{
get_submission(8)
} # }
```
