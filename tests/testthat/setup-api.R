# The HTTP tests replay fixtures recorded with httptest2 against a local copy
# of the site, so they run without a network or a real key. To re-record,
# delete tests/testthat/api/ and run the tests with a real
# DATARECEIPT_API_KEY set for the account that owns requests 1, 3, and 24.
# Set R_ENVIRON_USER=/dev/null for that run if ~/.Renviron holds a key for
# the real site: R reads it at startup and it wins over the shell's value,
# which records nothing but 401s.
fixtures_key <- Sys.getenv("DATARECEIPT_API_KEY")
if (!nzchar(fixtures_key)) fixtures_key <- "1|dr_fixtures"

withr::local_envvar(
  DATARECEIPT_API_URL = "https://read-api.test/api/v1",
  DATARECEIPT_API_KEY = fixtures_key,
  .local_envir = teardown_env()
)
