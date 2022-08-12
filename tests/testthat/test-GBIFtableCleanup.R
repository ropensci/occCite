context("Testing GBIFtableCleanup")

library(occCite)

test_that("behaves as expected when given a stored GBIF table", {
  skip_on_cran()
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

  testResult1 <- occCite::GBIFtableCleanup(testResult)
  expect_equal(class(testResult1$gbifID), "integer64")
  expect_equal(class(testResult1$name), "character")
  expect_equal(class(testResult1$longitude), "numeric")
  expect_equal(class(testResult1$latitude), "numeric")
  expect_equal(class(testResult1$coordinateUncertaintyInMeters), "numeric")
  expect_equal(class(testResult1$day), "integer")
  expect_equal(class(testResult1$month), "integer")
  expect_equal(class(testResult1$year), "integer")
  expect_equal(class(testResult1$Dataset), "character")
  expect_equal(class(testResult1$DatasetKey), "character")
  expect_equal(class(testResult1$DataService), "character")
})

test_that("behaves as expected when given an empty GBIF table", {
  expect_equal(nrow(occCite:::GBIFtableCleanup(NULL)), 1)
  expect_equal(ncol(occCite:::GBIFtableCleanup(NULL)), 10)
  expect_true(all(is.na(occCite:::GBIFtableCleanup(NULL))))

  expect_equal(nrow(occCite:::GBIFtableCleanup(NA)), 1)
  expect_equal(ncol(occCite:::GBIFtableCleanup(NA)), 10)
  expect_true(all(is.na(occCite:::GBIFtableCleanup(NA))))
})
