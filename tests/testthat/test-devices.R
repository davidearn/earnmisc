test_that("device helpers return scalar logical values", {
  expect_type(dev_is_tikz(), "logical")
  expect_length(dev_is_tikz(), 1)

  expect_type(dev_is_pdf(), "logical")
  expect_length(dev_is_pdf(), 1)
})

test_that("device helpers return FALSE on the null device", {
  while (!identical(names(grDevices::dev.cur()), "null device")) {
    grDevices::dev.off()
  }

  expect_false(dev_is_tikz())
  expect_false(dev_is_pdf())
})

test_that("dev_is_pdf detects a PDF device", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  expect_true(dev_is_pdf())
  expect_false(dev_is_tikz())
})

test_that("dev_is_tikz detects a tikzDevice device", {
  skip_if_not_installed("tikzDevice")

  tex.file <- tempfile(fileext = ".tex")
  tikzDevice::tikz(file = tex.file, standAlone = TRUE)
  on.exit(grDevices::dev.off(), add = TRUE)

  expect_true(dev_is_tikz())
  expect_false(dev_is_pdf())
})

test_that("dev_is_tikz can use stored tikz_open metadata", {
  pdf.file <- tempfile(fileext = ".pdf")
  grDevices::pdf(pdf.file)
  on.exit(grDevices::dev.off(), add = TRUE)

  current.device <- unname(grDevices::dev.cur())
  info <- build_tikz_info(
    arguments = list(file = "stored.tex", filename = "stored.tex", width = 1, height = 1),
    device = current.device,
    device.name = "pdf",
    opened_at = Sys.time(),
    working_directory = getwd()
  )

  old.info <- tikz_info(current.device)
  on.exit({
    if (is.null(old.info)) {
      rm(list = as.character(current.device), envir = tikz_info_store$by_device)
    } else {
      assign(as.character(current.device), old.info, envir = tikz_info_store$by_device)
    }
  }, add = TRUE)

  assign(as.character(current.device), info, envir = tikz_info_store$by_device)

  expect_true(dev_is_tikz())
})
