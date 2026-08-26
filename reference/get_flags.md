# List the flagged cells of a request

A request's owner can set a column to accept a value that breaks its
rules and flag it, rather than block the whole submission. This returns
every such cell across every submission: where it is, what the sender
typed, and which rule it broke. The same cells appear in
[`get_data()`](https://dgkeyes.github.io/datareceipt/reference/get_data.md)
cast to the column's type where the text allows it, and as `NA` where it
does not.

## Usage

``` r
get_flags(request, key = NULL)
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

A tibble with one row per flagged cell: `submission_id`, `row` (the
row's position within its submission), `submitted_at`, `sender_name`,
`sender_email`, `column`, `value` (the text as sent), and `message` (the
rule it broke). Zero rows when nothing is flagged.

## Examples

``` r
if (FALSE) { # \dontrun{
get_flags(12)
} # }
```
