# Turning API JSON into typed R vectors.
#
# The API tells us each column's type (from the request's spec), so nothing
# here guesses. Guessing from the values, as jsonlite does, goes wrong in
# ordinary cases: a column that is empty on one page becomes logical, one
# decimal turns an integer column into double, and two pages that disagree
# refuse to bind.

# Column builders for lists of API objects (requests, submissions, specs).
field <- function(items, name) {
  lapply(items, function(item) item[[name]])
}

chr_col <- function(items, name) cast_column(field(items, name), "text")
int_col <- function(items, name) cast_column(field(items, name), "integer")
lgl_col <- function(items, name) cast_column(field(items, name), "boolean")
time_col <- function(items, name) parse_time(chr_col(items, name))

# ISO 8601 as the API sends it: 2026-08-13T22:20:49.000000Z.
parse_time <- function(x) {
  as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%OS", tz = "UTC")
}

# One typed vector from a list of scalar JSON values, where NULL is an empty
# cell. `type` is a Data Receipt column type.
cast_column <- function(values, type) {
  values <- lapply(values, function(v) if (is.null(v)) NA else v)

  switch(
    type,
    text = vapply(values, function(v) if (is.na(v)) NA_character_ else as.character(v), character(1)),
    numeric = vapply(values, function(v) if (is.na(v)) NA_real_ else as.double(v), double(1)),
    integer = cast_integer(values),
    date = as.Date(vapply(values, function(v) if (is.na(v)) NA_character_ else as.character(v), character(1))),
    boolean = vapply(values, function(v) if (is.na(v)) NA else as.logical(v), logical(1)),
    cli::cli_abort("Unknown column type {.val {type}}.")
  )
}

# Whole numbers become R integers when they fit, otherwise doubles: R's
# integer tops out at about 2.1 billion, and a column of, say, revenue in
# pence can pass that.
cast_integer <- function(values) {
  doubles <- vapply(values, function(v) if (is.na(v)) NA_real_ else as.double(v), double(1))

  if (any(abs(doubles) > .Machine$integer.max, na.rm = TRUE)) {
    return(doubles)
  }

  as.integer(doubles)
}

# The rows of a submission (a list of `values` objects keyed by column name)
# as a tibble with one typed column per spec column, in spec order.
rows_to_tibble <- function(rows, columns) {
  rows <- rows %||% list()

  cols <- lapply(columns, function(column) {
    cast_column(lapply(rows, function(row) row[[column$name]]), column$type)
  })
  names(cols) <- vapply(columns, function(column) column$name, character(1))

  tibble::as_tibble(cols, .name_repair = "minimal")
}

# The spec of a request as a tibble, one row per column.
columns_to_tibble <- function(spec) {
  tibble::tibble(
    name = chr_col(spec, "name"),
    type = chr_col(spec, "type"),
    required = lgl_col(spec, "require_non_empty"),
    min = chr_col(spec, "min"),
    max = chr_col(spec, "max"),
    allowed_values = lapply(spec, function(column) as.character(unlist(column$allowed_values)))
  )
}

# Sender and submission columns in front of the data columns. A data column
# that shares a name with one of ours is renamed, with a note, rather than
# silently shadowing it.
bind_meta <- function(meta, values) {
  clash <- names(values) %in% names(meta)

  if (any(clash)) {
    renamed <- paste0(names(values)[clash], "_value")
    cli::cli_inform(c(
      "i" = "Renamed {.val {names(values)[clash]}} to {.val {renamed}} to keep {.val {names(values)[clash]}} for the submission column."
    ))
    names(values)[clash] <- renamed
  }

  out <- c(as.list(meta), as.list(values))
  names(out) <- vctrs::vec_as_names(names(out), repair = "unique", quiet = TRUE)

  tibble::as_tibble(out, .name_repair = "minimal")
}
