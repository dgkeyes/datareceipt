# Set your Data Receipt API key

Data Receipt identifies you by an API token, which you create on the
site under Settings \> API tokens. Every function in this package looks
for it in the `DATARECEIPT_API_KEY` environment variable, or takes it
directly as a `key` argument.

## Usage

``` r
datareceipt_api_key(key, install = FALSE, overwrite = FALSE)
```

## Arguments

- key:

  Your token, as shown once when you created it. It looks like
  `"12|dr_..."`.

- install:

  If `TRUE`, save the key to `.Renviron` for future sessions. If `FALSE`
  (the default), set it for the current session only.

- overwrite:

  If `TRUE`, replace a key already saved in `.Renviron`.

## Value

The key, invisibly.

## Details

With `install = TRUE` the key is written to your `.Renviron` file so it
is picked up in every future R session, the same way
`tidycensus::census_api_key()` works. Any existing `.Renviron` is backed
up to `.Renviron_backup` first.

## Examples

``` r
if (FALSE) { # \dontrun{
# Once, on each computer you use:
datareceipt_api_key("12|dr_...", install = TRUE)

# Or for this session only:
datareceipt_api_key("12|dr_...")
} # }
```
