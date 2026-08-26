test_that("a request id comes from a number, a string, a URL, or a request row", {
  expect_identical(parse_request_id(12), 12L)
  expect_identical(parse_request_id(12L), 12L)
  expect_identical(parse_request_id("12"), 12L)
  expect_identical(parse_request_id("https://datareceipt.io/requests/12"), 12L)
  expect_identical(parse_request_id("https://datareceipt.io/requests/12/edit"), 12L)
  expect_identical(parse_request_id(tibble::tibble(id = 12L, title = "x")), 12L)
})

test_that("anything else is a clear error", {
  expect_error(parse_request_id("https://datareceipt.io/r/abc"), "request id")
  expect_error(parse_request_id(-1), "request id")
  expect_error(parse_request_id(1.5), "request id")
  expect_error(parse_request_id(NULL), "request id")
  expect_error(parse_request_id(c(1, 2)), "request id")
})

test_that("a submission id comes from a number or a submission row", {
  expect_identical(parse_submission_id(8), 8L)
  expect_identical(parse_submission_id(tibble::tibble(id = 8L)), 8L)
  expect_error(parse_submission_id("nope"), "submission id")
})
