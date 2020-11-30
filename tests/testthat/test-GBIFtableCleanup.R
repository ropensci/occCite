context("Testing GBIFtableCleanup")

library(occCite)

test_that("inputs to GBIFtableCleanup from gbifRetriever as expected", {
  oldwd <- getwd()
  on.exit(setwd(oldwd))

  setwd(dir = system.file('extdata/', package='occCite'))
  taxon <- "Protea cynaroides"
  testResult <- occCite:::gbifRetriever(taxon)

  expect_equal(class(testResult[[1]]), "data.frame")
  expect_equal(names(testResult)[[1]], "OccurrenceTable")
})

test_that("inputs to GBIFtableCleanup from getGBIFpoints as expected", {
  skip_on_cran()

  test <- try(rgbif::occ_download(user=GBIFLogin@username,
                            email = GBIFLogin@email,
                            pwd = GBIFLogin@pwd,
                            rgbif::pred("catalogNumber", 217880)),
              silent = T)
  skip_if(class(test) != 'occ_download', "GBIF login unsuccessful")

  oldwd <- getwd()
  on.exit(setwd(oldwd))

  setwd(dir = system.file('extdata/', package='occCite'))
  taxon <- "Protea cynaroides"
  if(!dir.exists("temp/")) dir.create("temp/")
  testResult <- occCite:::getGBIFpoints(taxon = taxon,
                        GBIFLogin = occCite:::GBIFLoginManager(),
                        GBIFDownloadDirectory = "temp/",
                        checkPreviousGBIFDownload = T)

  expect_equal(class(testResult[[1]]), "data.frame")
  expect_equal(names(testResult)[[1]], "OccurrenceTable")

  unlink("temp/", recursive = T)
})

test_that("GBIFtableCleanup behaves as expected when given a stored GBIF table", {
  oldwd <- getwd()
  on.exit(setwd(oldwd))

  setwd(dir = system.file('extdata/', package='occCite'))
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

test_that("GBIFtableCleanup behaves as expected when given a downloaded GBIF table", {
  skip_on_cran()
  skip_if(nchar(Sys.getenv("GBIF_EMAIL")) < 1,
          "GBIF Login information not available")

  test <- try(rgbif::occ_download(user=GBIFLogin@username,
                                  email = GBIFLogin@email,
                                  pwd = GBIFLogin@pwd,
                                  rgbif::pred("catalogNumber", 217880)),
              silent = T)
  skip_if(class(test) != 'occ_download', "GBIF login unsuccessful")

  oldwd <- getwd()
  on.exit(setwd(oldwd))

  setwd(dir = system.file('extdata/', package='occCite'))
  taxon <- "Protea cynaroides"
  if(!dir.exists("temp/")) dir.create("temp/")
  testResult <- occCite:::getGBIFpoints(taxon = taxon,
                                GBIFLogin = occCite:::GBIFLoginManager(),
                                GBIFDownloadDirectory = "temp/",
                                checkPreviousGBIFDownload = T)[[1]]

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

test_that("GBIFtableCleanup behaves as expected when given a GBIF table that is empty", {
  expect_equal(nrow(occCite:::GBIFtableCleanup(NULL)), 1)
  expect_equal(ncol(occCite:::GBIFtableCleanup(NULL)), 9)
  expect_true(all(is.na(occCite:::GBIFtableCleanup(NULL))))

  expect_equal(nrow(occCite:::GBIFtableCleanup(NA)), 1)
  expect_equal(ncol(occCite:::GBIFtableCleanup(NA)), 9)
  expect_true(all(is.na(occCite:::GBIFtableCleanup(NA))))
})
