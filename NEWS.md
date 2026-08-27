# datareceipt 0.0.0.9000

* `source` in `list_submissions()` and `get_submission()` is `"xlsx"` or
  `"csv"` for new submissions. The one-entry form was taken off the site on
  2026-08-26 (kept on the app's `bring-back-sender-form` branch); `"form"`,
  `"paste"`, and `"typed"` remain on submissions from before then. Docs
  wording follows.
* `get_flags()` lists every cell that broke a rule but was accepted, with the
  text as sent and the rule it broke. `get_data()` says how many there are.
  A flagged value that still fits its column's type is cast like any other;
  one that does not is `NA`.
* `get_columns()` gains `on_break`, `friendly_name`, and `description`.
* `list_submissions()` and `get_submission()` gain `source`, `flag_count`,
  and `revised_at`.

* First version. `datareceipt_api_key()` stores your token, `list_requests()`
  and `get_columns()` show what you have asked for, and `get_data()` pulls
  every accepted row of a request into one typed tibble. Also
  `get_request()`, `list_submissions()`, `get_submission()`, and
  `datareceipt_whoami()`.
