test_that("each column type becomes the matching R type, with NA for null", {
  expect_identical(cast_column(list("a", NULL, "c"), "text"), c("a", NA, "c"))
  expect_identical(cast_column(list(1.5, NULL, 2L), "numeric"), c(1.5, NA, 2))
  expect_identical(cast_column(list(3L, NULL, 4), "integer"), c(3L, NA, 4L))
  expect_identical(cast_column(list("2024-01-05", NULL), "date"), as.Date(c("2024-01-05", NA)))
  expect_identical(cast_column(list(TRUE, NULL, FALSE), "boolean"), c(TRUE, NA, FALSE))
})

test_that("an all-empty column still has its declared type", {
  expect_identical(cast_column(list(NULL, NULL), "numeric"), c(NA_real_, NA_real_))
  expect_identical(cast_column(list(NULL), "date"), as.Date(NA))
  expect_identical(cast_column(list(), "integer"), integer())
})

test_that("a flagged value is cast where its text allows and NA where it does not", {
  # Flagged cells arrive as the sender's text, whatever the column's type.
  expect_identical(cast_column(list(30L, "200"), "integer"), c(30L, 200L))
  expect_identical(cast_column(list(30L, "abc"), "integer"), c(30L, NA))
  expect_identical(cast_column(list(30L, "2.5"), "integer"), c(30, 2.5))
  expect_identical(cast_column(list(0.5, "lots"), "numeric"), c(0.5, NA))
  expect_identical(cast_column(list("2024-01-05", "soon"), "date"), as.Date(c("2024-01-05", NA)))
  expect_identical(cast_column(list(TRUE, "maybe"), "boolean"), c(TRUE, NA))
})

test_that("whole numbers too big for an R integer fall back to double", {
  expect_identical(cast_column(list(1, 3e9), "integer"), c(1, 3e9))
  expect_type(cast_column(list(1, 2147483647), "integer"), "integer")
})

test_that("an unknown type is an error", {
  expect_error(cast_column(list(1), "money"), "Unknown column type")
})

test_that("rows_to_tibble types every column from the spec, in spec order", {
  columns <- list(
    list(name = "Name", type = "text"),
    list(name = "Score", type = "numeric"),
    list(name = "Count", type = "integer"),
    list(name = "When", type = "date"),
    list(name = "Ok", type = "boolean")
  )
  rows <- list(
    list(Name = "Ada", Score = 1.5, Count = 3L, When = "2024-01-05", Ok = TRUE),
    list(Name = NULL, Score = NULL, Count = NULL, When = NULL, Ok = FALSE)
  )

  out <- rows_to_tibble(rows, columns)

  expect_s3_class(out, "tbl_df")
  expect_named(out, c("Name", "Score", "Count", "When", "Ok"))
  expect_identical(out$Name, c("Ada", NA))
  expect_identical(out$Score, c(1.5, NA))
  expect_identical(out$Count, c(3L, NA))
  expect_identical(out$When, as.Date(c("2024-01-05", NA)))
  expect_identical(out$Ok, c(TRUE, FALSE))
})

test_that("rows_to_tibble with no rows is a zero-row tibble with typed columns", {
  columns <- list(list(name = "When", type = "date"), list(name = "N", type = "integer"))

  out <- rows_to_tibble(list(), columns)

  expect_identical(nrow(out), 0L)
  expect_s3_class(out$When, "Date")
  expect_type(out$N, "integer")

  expect_identical(nrow(rows_to_tibble(NULL, columns)), 0L)
})

test_that("bind_meta keeps our columns first and renames a clashing data column", {
  meta <- tibble::tibble(submission_id = 1:2, row = 1:2)
  values <- tibble::tibble(row = c("a", "b"), Age = c(1L, 2L))

  expect_message(out <- bind_meta(meta, values), "Renamed")
  expect_named(out, c("submission_id", "row", "row_value", "Age"))
  expect_identical(out$row, 1:2)
  expect_identical(out$row_value, c("a", "b"))
})

test_that("columns_to_tibble carries the wording and what a broken rule does", {
  spec <- list(
    list(name = "site_id", type = "text", require_non_empty = TRUE, min = NULL, max = NULL, allowed_values = NULL, on_break = "block", friendly_name = "Site ID", description = "The code on the door."),
    list(name = "rate", type = "numeric", require_non_empty = FALSE, min = "0", max = "1", allowed_values = NULL, on_break = "flag", friendly_name = NULL, description = NULL)
  )

  out <- columns_to_tibble(spec)

  expect_named(out, c("name", "type", "required", "min", "max", "allowed_values", "on_break", "friendly_name", "description"))
  expect_identical(out$on_break, c("block", "flag"))
  expect_identical(out$friendly_name, c("Site ID", NA))
  expect_identical(out$description, c("The code on the door.", NA))
  expect_identical(out$min, c(NA, "0"))
})

test_that("flags_to_tibble is one row per flagged cell with the sender looked up", {
  rows <- list(
    list(submission_id = 1L, row = 1L, values = list(), flags = list()),
    list(submission_id = 1L, row = 2L, values = list(), flags = list(
      list(column = "age", value = "200", message = "must be between 1 and 120"),
      list(column = "name", value = "x", message = "must be one of: a, b")
    )),
    list(submission_id = 2L, row = 1L, values = list(), flags = list())
  )
  submissions <- tibble::tibble(
    id = 1:2,
    sender_name = c("Ada", "Bob"),
    sender_email = c("ada@example.org", "bob@example.org"),
    submitted_at = parse_time(c("2026-08-13T22:20:49.000000Z", "2026-08-14T22:20:49.000000Z"))
  )

  out <- flags_to_tibble(rows, submissions)

  expect_named(out, c("submission_id", "row", "submitted_at", "sender_name", "sender_email", "column", "value", "message"))
  expect_identical(nrow(out), 2L)
  expect_identical(out$row, c(2L, 2L))
  expect_identical(out$sender_name, c("Ada", "Ada"))
  expect_identical(out$column, c("age", "name"))
  expect_identical(out$value, c("200", "x"))

  none <- flags_to_tibble(rows[c(1, 3)], submissions)
  expect_identical(nrow(none), 0L)
  expect_identical(names(none), names(out))
})

test_that("timestamps parse as UTC POSIXct", {
  parsed <- parse_time("2026-08-13T22:20:49.000000Z")

  expect_s3_class(parsed, "POSIXct")
  expect_identical(format(parsed, "%Y-%m-%d %H:%M:%S", tz = "UTC"), "2026-08-13 22:20:49")
  expect_true(is.na(parse_time(NA_character_)))
})
