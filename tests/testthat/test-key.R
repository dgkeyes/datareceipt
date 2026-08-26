test_that("the key comes from the argument, then the environment", {
  withr::local_envvar(DATARECEIPT_API_KEY = "1|dr_env")

  expect_identical(dr_key(), "1|dr_env")
  expect_identical(dr_key("2|dr_arg"), "2|dr_arg")
  expect_true(datareceipt_has_key())
})

test_that("no key is an error that says what to do", {
  withr::local_envvar(DATARECEIPT_API_KEY = "")

  expect_false(datareceipt_has_key())
  expect_error(dr_key(), "datareceipt_api_key")
  expect_error(list_requests(), "API key is required")
})

test_that("datareceipt_api_key() sets the key for the session", {
  withr::local_envvar(DATARECEIPT_API_KEY = "")

  expect_message(datareceipt_api_key("3|dr_session"), "this session")
  expect_identical(Sys.getenv("DATARECEIPT_API_KEY"), "3|dr_session")
})

test_that("datareceipt_api_key(install = TRUE) writes .Renviron and refuses to overwrite", {
  home <- withr::local_tempdir()
  withr::local_envvar(HOME = home, DATARECEIPT_API_KEY = "")
  renviron <- file.path(home, ".Renviron")
  writeLines("OTHER=1", renviron)

  expect_message(datareceipt_api_key("4|dr_saved", install = TRUE), "saved")
  expect_identical(readLines(renviron), c("OTHER=1", "DATARECEIPT_API_KEY='4|dr_saved'"))
  expect_true(file.exists(paste0(renviron, "_backup")))
  expect_identical(Sys.getenv("DATARECEIPT_API_KEY"), "4|dr_saved")

  expect_error(datareceipt_api_key("5|dr_again", install = TRUE), "overwrite = TRUE")

  expect_message(datareceipt_api_key("5|dr_again", install = TRUE, overwrite = TRUE), "saved")
  expect_identical(readLines(renviron), c("OTHER=1", "DATARECEIPT_API_KEY='5|dr_again'"))
})

test_that("a key must be a non-empty string", {
  expect_error(datareceipt_api_key(""), "non-empty string")
  expect_error(datareceipt_api_key(NULL), "non-empty string")
  expect_error(datareceipt_api_key(c("a", "b")), "non-empty string")
})
