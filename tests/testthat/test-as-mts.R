test_that("as_mts is an exported S3 generic", {
  expect_true("as_mts" %in% getNamespaceExports("earnmisc"))
  expect_true(utils::isS3stdGeneric("as_mts"))
  expect_identical(names(formals(as_mts)), c("x", "..."))
})

test_that("as_mts dispatches to class methods", {
  method <- function(x, ...) {
    list(x = x, dots = list(...))
  }
  registerS3method(
    "as_mts",
    "test_as_mts",
    method,
    envir = asNamespace("earnmisc")
  )

  object <- structure(1, class = "test_as_mts")
  out <- as_mts(object, variable = "y")

  expect_identical(out$x, object)
  expect_identical(out$dots, list(variable = "y"))
})
