context("Testing GBIFtableCleanup")

library(occCite)

test_that("behaves as expected when given a stored GBIF table", {
  oldwd <- getwd()
  on.exit(setwd(oldwd))

  test <- try(rgbif::occ_count(country = "DK"),
              silent = T
  )
  skip_if(class(test) != "numeric", "GBIF connection unsuccessful")

  setwd(dir = system.file("extdata/", package = "occCite"))
  taxon <- "Protea cynaroides"
  testResult <- occCite:::gbifRetriever(taxon)[[1]]

  expect_equal(class(testResult), "data.frame")
  expect_true("gbifID" %in% colnames(testResult))
  expect_true("name" %in% colnames(testResult))
  expect_true("longitude" %in% colnames(testResult))
  expect_true("latitude" %in% colnames(testResult))
  expect_true("day" %in% colnames(testResult))
  expect_true("month" %in% colnames(testResult))
  expect_true("year" %in% colnames(testResult))
  expect_true("Dataset" %in% colnames(testResult))
  expect_true("DatasetKey" %in% colnames(testResult))
  expect_true("DataService" %in% colnames(testResult))
})

test_that("behaves as expected when given an empty GBIF table", {
  expect_equal(nrow(occCite:::GBIFtableCleanup(NULL)), 1)
  expect_equal(ncol(occCite:::GBIFtableCleanup(NULL)), 9)
  expect_true(all(is.na(occCite:::GBIFtableCleanup(NULL))))

  expect_equal(nrow(occCite:::GBIFtableCleanup(NA)), 1)
  expect_equal(ncol(occCite:::GBIFtableCleanup(NA)), 9)
  expect_true(all(is.na(occCite:::GBIFtableCleanup(NA))))
})
