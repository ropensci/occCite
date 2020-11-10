context("Testing gbifRetriever")

library(occCite)

test_that("inputs to gbifRetriever are as expected", {
  expect_equal(class(rgbif::name_suggest(q= "Protea cynaroides", fields = "key", rank = "species")),
               "gbif")
  expect_equal(class(as.numeric(rgbif::name_suggest(q= "Protea cynaroides", fields = "key", rank = "species")$data[1])),
               "numeric")
})

test_that("gbifRetriever behaves as expected", {
  oldwd <- getwd()
  on.exit(setwd(oldwd))
  setwd(dir = system.file('extdata/', package='occCite'))
  taxon = "Protea cynaroides"
  testResult = occCite:::gbifRetriever(taxon)

  expect_equal(class(testResult), "list")
  expect_equal(class(testResult[[1]]), "data.frame")
  expect_equal(names(testResult)[[1]], "OccurrenceTable")
  expect_equal(class(testResult[[2]]), "occ_download_meta")
  expect_equal(names(testResult)[[2]], "Metadata")
  expect_equal(class(testResult[[3]]), "occ_download_get")
  expect_equal(names(testResult)[[3]], "RawOccurrences")
})
