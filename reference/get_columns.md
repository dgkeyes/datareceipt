# Get a request's columns

The spec a request was built with: each column's name, type, and rules.
This is what the data you get back from
[`get_data()`](https://dgkeyes.github.io/datareceipt/reference/get_data.md)
is typed by, so it is the place to look before deciding what to do with
the data.

## Usage

``` r
get_columns(request, key = NULL)
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

A tibble with one row per column: `name` (the variable name the data is
keyed by), `type` (one of `"text"`, `"numeric"`, `"integer"`, `"date"`,
`"boolean"`), `required` (no empty cells allowed), `min`, `max`,
`allowed_values` (a list column of the permitted values, empty when
there is no such rule), `on_break` (`"block"` if a value breaking a rule
stops the submission, `"flag"` if it is accepted and flagged; see
[`get_flags()`](https://dgkeyes.github.io/datareceipt/reference/get_flags.md)).

## Examples

``` r
if (FALSE) { # \dontrun{
get_columns(12)
} # }
```
