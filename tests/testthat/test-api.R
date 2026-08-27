# Recorded against a local copy of the site whose demo account owns request 1
# (three submissions, nothing flagged), request 3 (none), and request 24 (two
# submissions with flagged cells). See setup-api.R.

httptest2::with_mock_dir("api", {
  test_that("datareceipt_whoami() names the account", {
    who <- datareceipt_whoami()

    expect_s3_class(who, "tbl_df")
    expect_named(who, c("id", "name", "email"))
    expect_type(who$id, "integer")
    expect_identical(nrow(who), 1L)
  })

  test_that("list_requests() is a typed tibble with the spec in a list column", {
    requests <- list_requests()

    expect_s3_class(requests, "tbl_df")
    expect_named(requests, c(
      "id", "title", "description", "is_open", "closed_at", "submission_count",
      "row_count", "share_url", "created_at", "updated_at", "columns"
    ))
    expect_type(requests$id, "integer")
    expect_type(requests$is_open, "logical")
    expect_s3_class(requests$created_at, "POSIXct")
    expect_true(1L %in% requests$id)
    expect_s3_class(requests$columns[[1]], "tbl_df")
    expect_identical(requests$submission_count[requests$id == 1L], 3L)
  })

  test_that("get_request() and get_columns() describe one request", {
    request <- get_request(1)

    expect_identical(nrow(request), 1L)
    expect_identical(request$id, 1L)

    columns <- get_columns(request)

    expect_named(columns, c("name", "type", "required", "min", "max", "allowed_values", "on_break", "friendly_name", "description"))
    expect_true(all(columns$on_break %in% c("block", "flag")))
    expect_true(all(columns$type %in% c("text", "numeric", "integer", "date", "boolean")))
    expect_type(columns$required, "logical")
    expect_type(columns$allowed_values, "list")
    expect_identical(get_columns("https://read-api.test/requests/1"), columns)
  })

  test_that("get_data() follows every page and types the columns from the spec", {
    withr::local_options(datareceipt.per_page = 1)

    expect_message(data <- get_data(1), "Fetched 11 rows from 3 submissions")

    columns <- get_columns(1)

    expect_s3_class(data, "tbl_df")
    expect_identical(nrow(data), 11L)
    expect_identical(
      names(data),
      c("submission_id", "row", "submitted_at", "sender_name", "sender_email", columns$name)
    )
    expect_identical(length(unique(data$submission_id)), 3L)
    expect_type(data$row, "integer")
    expect_s3_class(data$submitted_at, "POSIXct")
    expect_false(anyNA(data$sender_name))

    for (i in seq_len(nrow(columns))) {
      column <- data[[columns$name[[i]]]]
      switch(
        columns$type[[i]],
        text = expect_type(column, "character"),
        numeric = expect_type(column, "double"),
        integer = expect_type(column, "integer"),
        date = expect_s3_class(column, "Date"),
        boolean = expect_type(column, "logical")
      )
    }
  })

  test_that("get_data(include_sender = FALSE) leaves the sender columns out", {
    withr::local_options(datareceipt.per_page = 1)

    expect_message(data <- get_data(1, include_sender = FALSE))

    expect_identical(names(data)[1:2], c("submission_id", "row"))
    expect_false(any(c("sender_name", "sender_email", "submitted_at") %in% names(data)))
  })

  test_that("a request with no submissions gives a zero-row tibble with the right columns", {
    expect_message(data <- get_data(3), "Fetched 0 rows from 0 submissions")

    expect_identical(nrow(data), 0L)
    expect_identical(names(data), c("submission_id", "row", "submitted_at", "sender_name", "sender_email", get_columns(3)$name))
  })

  test_that("list_submissions() and get_submission() work one submission at a time", {
    submissions <- list_submissions(1)

    expect_named(submissions, c("id", "request_id", "sender_name", "sender_email", "source", "row_count", "flag_count", "original_filename", "submitted_at", "revised_at"))
    expect_type(submissions$source, "character")
    expect_identical(submissions$flag_count, c(0L, 0L, 0L))
    expect_s3_class(submissions$revised_at, "POSIXct")
    expect_identical(nrow(submissions), 3L)
    expect_identical(unique(submissions$request_id), 1L)
    expect_true(!is.unsorted(submissions$id))

    one <- get_submission(submissions[1, ])

    expect_identical(nrow(one), submissions$row_count[[1]])
    expect_identical(unique(one$submission_id), submissions$id[[1]])
    expect_identical(one$row, seq_len(nrow(one)))
    expect_identical(unique(one$sender_name), submissions$sender_name[[1]])
    expect_identical(names(one), names(get_data(1)))
  })

  test_that("get_flags() lists flagged cells, and get_data() casts them where it can", {
    flags <- get_flags(24)

    expect_s3_class(flags, "tbl_df")
    expect_named(flags, c("submission_id", "row", "submitted_at", "sender_name", "sender_email", "column", "value", "message"))
    expect_gt(nrow(flags), 0L)
    expect_false(anyNA(flags$sender_name))
    expect_type(flags$value, "character")

    expect_message(data <- get_data(24), "flagged")

    expect_identical(sum(list_submissions(24)$flag_count), nrow(flags))

    # A flagged whole number out of range is still a number; text in a number column is NA.
    columns <- get_columns(24)
    for (i in seq_len(nrow(flags))) {
      cell <- data[[flags$column[[i]]]][data$submission_id == flags$submission_id[[i]] & data$row == flags$row[[i]]]
      type <- columns$type[columns$name == flags$column[[i]]]
      parsed <- suppressWarnings(as.double(flags$value[[i]]))
      if (type %in% c("integer", "numeric") && !is.na(parsed)) {
        expect_equal(as.double(cell), parsed)
      }
    }

    expect_identical(nrow(get_flags(3)), 0L)
  })

  test_that("an unknown id is a 404 with a hint", {
    expect_error(get_request(999999), "Nothing with that id")
  })
})
