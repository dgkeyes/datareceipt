# datareceipt

[Data Receipt](https://datareceipt.io) collects validated spreadsheets
from the people you ask: you define the columns and rules, share a link,
and every upload has to pass before it is accepted. This package pulls
what they sent into R as tidy, typed tibbles, so the data you asked for
lands ready to use.

If you have used [tidycensus](https://walker-data.com/tidycensus/), it
works the same way: set a key once, look up what is available, then
`get_` the data.

## Installation

The package is not on CRAN yet. Install it from GitHub:

``` r

# install.packages("pak")
pak::pak("dgkeyes/datareceipt")
```

## Set up

Create an API token on the site under **Settings \> API tokens**, then
save it once:

``` r

library(datareceipt)

datareceipt_api_key("12|dr_...", install = TRUE)
```

That writes `DATARECEIPT_API_KEY` to your `.Renviron`, so every future
session finds it. Check it worked with
[`datareceipt_whoami()`](https://dgkeyes.github.io/datareceipt/reference/datareceipt_whoami.md).

## Get your data

``` r

# What have I asked for?
list_requests()

# What columns did request 12 ask for, and with what rules?
get_columns(12)

# Everything anyone has sent to request 12, as one tibble
hours <- get_data(12)
```

You can pass a request’s URL straight from your browser instead of its
id:

``` r

hours <- get_data("https://datareceipt.io/requests/12")
```

[`get_data()`](https://dgkeyes.github.io/datareceipt/reference/get_data.md)
returns one row per submitted row. Columns are typed from the request’s
spec (text is character, numbers are double, whole numbers are integer,
dates are `Date`, yes/no is logical), and the first few columns say
where each row came from:

``` R
#> Fetched 1,204 rows from 3 submissions for request 12.
#> # A tibble: 1,204 × 8
#>   submission_id   row submitted_at        sender_name sender_email  site   month      hours
#>           <int> <int> <dttm>              <chr>       <chr>         <chr>  <date>     <dbl>
#> 1            41     1 2026-08-13 22:20:49 Vivian Lee  vivian@ex.org North  2026-07-01  12.5
```

Pass `include_sender = FALSE` to leave the sender columns out.
[`list_submissions()`](https://dgkeyes.github.io/datareceipt/reference/list_submissions.md)
and
[`get_submission()`](https://dgkeyes.github.io/datareceipt/reference/get_submission.md)
work one submission at a time.

## Flagged cells

A column can be set to accept a value that breaks its rules and flag it,
rather than block the submission. Those cells come back from
[`get_data()`](https://dgkeyes.github.io/datareceipt/reference/get_data.md)
cast where the text allows (an out-of-range `"200"` in a whole-number
column is `200L`) and as `NA` where it does not (`"abc"` in the same
column).
[`get_flags()`](https://dgkeyes.github.io/datareceipt/reference/get_flags.md)
lists them all:

``` r

get_flags(12)
#> # A tibble: 2 × 8
#>   submission_id   row submitted_at        sender_name sender_email  column value message
#>           <int> <int> <dttm>              <chr>       <chr>         <chr>  <chr> <chr>
#> 1            41     7 2026-08-13 22:20:49 Vivian Lee  vivian@ex.org hours  -3    must be at least 0
```
