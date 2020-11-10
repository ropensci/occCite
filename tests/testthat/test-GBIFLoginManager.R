context("Setting up GBIF Login")

library(occCite)

test_that("GBIFLoginManager behaves as expected", {
  skip_on_cran()

  expect_warning(GBIFLoginManager("testing", "the", "login"), "GBIF user login data incorrect.")

  testResult <- GBIFLoginManager()
  expect_true("username" %in% slotNames(testResult))
  expect_true("email" %in% slotNames(testResult))
  expect_true("pwd" %in% slotNames(testResult))
})
