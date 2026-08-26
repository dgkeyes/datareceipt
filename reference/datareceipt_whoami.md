# Which account does my key belong to?

The cheapest way to check that a key works.

## Usage

``` r
datareceipt_whoami(key = NULL)
```

## Arguments

- key:

  Your API key. Defaults to the `DATARECEIPT_API_KEY` environment
  variable; see
  [`datareceipt_api_key()`](https://dgkeyes.github.io/datareceipt/reference/datareceipt_api_key.md).

## Value

A one-row tibble: `id`, `name`, `email`.

## Examples

``` r
if (FALSE) { # \dontrun{
datareceipt_whoami()
} # }
```
