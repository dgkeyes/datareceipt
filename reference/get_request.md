# Get one request

Get one request

## Usage

``` r
get_request(request, key = NULL)
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

A one-row tibble in the shape of
[`list_requests()`](https://dgkeyes.github.io/datareceipt/reference/list_requests.md).

## Examples

``` r
if (FALSE) { # \dontrun{
get_request(12)
get_request("https://datareceipt.io/requests/12")
} # }
```
