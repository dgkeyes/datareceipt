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

test_that("timestamps parse as UTC POSIXct", {
  parsed <- parse_time("2026-08-13T22:20:49.000000Z")

  expect_s3_class(parsed, "POSIXct")
  expect_identical(format(parsed, "%Y-%m-%d %H:%M:%S", tz = "UTC"), "2026-08-13 22:20:49")
  expect_true(is.na(parse_time(NA_character_)))
})
