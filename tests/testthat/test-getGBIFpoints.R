context("Getting GBIF points")

library(occCite)

test_that("GBIF retrieval from server behaves as expected", {
  skip_on_cran()
  skip_if(nchar(Sys.getenv("GBIF_EMAIL")) < 1, "GBIF Login information not available")

  test <- try(rgbif::occ_download(user=GBIFLogin@username,
                                  email = GBIFLogin@email,
                                  pwd = GBIFLogin@pwd,
                                  rgbif::pred("catalogNumber", 217880)), silent = T)
  skip_if(class(test) != 'occ_download', "GBIF login unsuccessful")

  GBIFLogin <- GBIFLoginManager()

  cleanTaxon <- stringr::str_extract(string = "Protea cynaroides",
                                     pattern = "(\\w+\\s\\w+)")
  key <- rgbif::name_suggest(q=cleanTaxon, rank='species')$data$key[1]
  occD <- prevGBIFdownload(key, GBIFLogin=GBIFLogin)
  res <- rgbif::occ_download_get(key=occD, overwrite=TRUE,
                                 file.path(system.file('extdata/',
                                                       package='occCite')))

  expect_equal(class(res), "occ_download_get")
})

test_that("new GBIF search behaves as expected", {
  skip_on_cran()
  skip_if(nchar(Sys.getenv("GBIF_EMAIL")) < 1, "GBIF Login information not available")

  test <- try(rgbif::occ_download(user=GBIFLogin@username,
                                  email = GBIFLogin@email,
                                  pwd = GBIFLogin@pwd,
                                  rgbif::pred("catalogNumber", 217880)), silent = T)
  skip_if(class(test) != 'occ_download', "GBIF login unsuccessful")

  GBIFLogin <- GBIFLoginManager()

  cleanTaxon <- stringr::str_extract(string = "Protea cynaroides",
                                     pattern = "(\\w+\\s\\w+)")
  key <- rgbif::name_suggest(q=cleanTaxon, rank='species')$data$key[1]
  occD <- rgbif::occ_download(rgbif::pred("taxonKey", value = key),
                              rgbif::pred("hasCoordinate", TRUE), rgbif::pred("hasGeospatialIssue", FALSE),
                              user = GBIFLogin@username, email = GBIFLogin@email,
                              pwd = GBIFLogin@pwd)
  while (rgbif::occ_download_meta(occD[1])$status != "SUCCEEDED"){
    Sys.sleep(60)
    print(paste("Still waiting for Protea cynaroides test download preparation to be completed. Time: ",
                format(Sys.time(), format = "%H:%M:%S")))
  }
  res <- rgbif::occ_download_get(key=occD, overwrite=TRUE,
                                 file.path(system.file('extdata/',
                                                       package='occCite')))
  expect_equal(class(res), "occ_download_get")
})

test_that("getGBIFpoints behaves as expected", {
  skip_on_cran()
  skip_if(nchar(Sys.getenv("GBIF_EMAIL")) < 1, "GBIF Login information not available")

  test <- try(rgbif::occ_download(user=GBIFLogin@username,
                                  email = GBIFLogin@email,
                                  pwd = GBIFLogin@pwd,
                                  rgbif::pred("catalogNumber", 217880)), silent = T)
  skip_if(class(test) != 'occ_download', "GBIF login unsuccessful")

  GBIFLogin <- GBIFLoginManager()

  testResult <- getGBIFpoints(taxon="Protea cynaroides", GBIFLogin,
                              file.path(system.file('extdata/', package='occCite')))
  expect_equal(class(testResult), "list")
  expect_equal(length(testResult), 3)

  expect_true("OccurrenceTable" %in% names(testResult))
  expect_true("Metadata" %in% names(testResult))
  expect_true("RawOccurrences" %in% names(testResult))

  expect_equal(class(testResult$OccurrenceTable), "data.frame")
  expect_equal(class(testResult$Metadata), "occ_download_meta")
  expect_equal(class(testResult$RawOccurrences), "occ_download_get")

  expect_true("name" %in% colnames(testResult$OccurrenceTable))
  expect_true("longitude" %in% colnames(testResult$OccurrenceTable))
  expect_true("latitude" %in% colnames(testResult$OccurrenceTable))
  expect_true("day" %in% colnames(testResult$OccurrenceTable))
  expect_true("month" %in% colnames(testResult$OccurrenceTable))
  expect_true("year" %in% colnames(testResult$OccurrenceTable))
  expect_true("Dataset" %in% colnames(testResult$OccurrenceTable))
  expect_true("DatasetKey" %in% colnames(testResult$OccurrenceTable))
  expect_true("DataService" %in% colnames(testResult$OccurrenceTable))
})
