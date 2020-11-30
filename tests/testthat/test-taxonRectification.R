context("Verifies performance of taxonRectification")

library(occCite)

test_that("functions on which it depends function as necessary", {
  sources <- taxize::gnr_datasources()

  expect_true("data.frame" %in% class(sources))
  expect_true("title" %in% colnames(sources))
  expect_true("id" %in% colnames(sources))
  expect_true("NCBI" %in% sources$title)

  datasources <- "NCBI"
  sourceIDs <- sources$id[sources$title %in% datasources]
  temp <- taxize::gnr_resolve(sci = "Buteo buteo", data_source_ids = sourceIDs)

  expect_true("data.frame" %in% class(temp))
  expect_true("user_supplied_name" %in% colnames(temp))
  expect_true("matched_name" %in% colnames(temp))
  expect_true("data_source_title" %in% colnames(temp))
  expect_true(nrow(temp) == 1)
  expect_true(temp$user_supplied_name == temp$matched_name)
  expect_true(temp$data_source_title == datasources)
})

test_that("taxonRectification performs as expected", {
  testResult <- taxonRectification(taxName = "Buteo buteo hartedi",
                                   datasources = 'NCBI')

  expect_true(class(testResult) == "data.frame")
  expect_true("Input Name" %in% colnames(testResult))
  expect_true("Input Name" %in% colnames(testResult))
  expect_true("Searched Taxonomic Databases w/ Matches"
              %in% colnames(testResult))
  expect_true(nrow(testResult) == 1)
  expect_true(testResult$`Input Name`[1] == "Buteo buteo hartedi")
  expect_true(testResult$`Best Match`[1] == "Buteo buteo harterti")
  expect_true(testResult$`Searched Taxonomic Databases w/ Matches` == "NCBI")
})
