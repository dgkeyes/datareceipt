# Changelog

## datareceipt 0.0.0.9000

- `source` in
  [`list_submissions()`](https://dgkeyes.github.io/datareceipt/reference/list_submissions.md)
  and
  [`get_submission()`](https://dgkeyes.github.io/datareceipt/reference/get_submission.md)
  is `"xlsx"` or `"csv"` for new submissions. The one-entry form was
  taken off the site on 2026-08-26 (kept on the app’s
  `bring-back-sender-form` branch); `"form"`, `"paste"`, and `"typed"`
  remain on submissions from before then. Docs wording follows.

- [`get_columns()`](https://dgkeyes.github.io/datareceipt/reference/get_columns.md)
  no longer returns `friendly_name` or `description`; the site set those
  column settings aside on the same day and the API stopped sending
  them.

- [`get_flags()`](https://dgkeyes.github.io/datareceipt/reference/get_flags.md)
  lists every cell that broke a rule but was accepted, with the text as
  sent and the rule it broke.
  [`get_data()`](https://dgkeyes.github.io/datareceipt/reference/get_data.md)
  says how many there are. A flagged value that still fits its column’s
  type is cast like any other; one that does not is `NA`.

- [`get_columns()`](https://dgkeyes.github.io/datareceipt/reference/get_columns.md)
  gains `on_break`, `friendly_name`, and `description`.

- [`list_submissions()`](https://dgkeyes.github.io/datareceipt/reference/list_submissions.md)
  and
  [`get_submission()`](https://dgkeyes.github.io/datareceipt/reference/get_submission.md)
  gain `source`, `flag_count`, and `revised_at`.

- First version.
  [`datareceipt_api_key()`](https://dgkeyes.github.io/datareceipt/reference/datareceipt_api_key.md)
  stores your token,
  [`list_requests()`](https://dgkeyes.github.io/datareceipt/reference/list_requests.md)
  and
  [`get_columns()`](https://dgkeyes.github.io/datareceipt/reference/get_columns.md)
  show what you have asked for, and
  [`get_data()`](https://dgkeyes.github.io/datareceipt/reference/get_data.md)
  pulls every accepted row of a request into one typed tibble. Also
  [`get_request()`](https://dgkeyes.github.io/datareceipt/reference/get_request.md),
  [`list_submissions()`](https://dgkeyes.github.io/datareceipt/reference/list_submissions.md),
  [`get_submission()`](https://dgkeyes.github.io/datareceipt/reference/get_submission.md),
  and
  [`datareceipt_whoami()`](https://dgkeyes.github.io/datareceipt/reference/datareceipt_whoami.md).
