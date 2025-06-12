context("Verifies performance of taxonRectification")

library(occCite)
library(httr)

url <- "https://verifier.globalnames.org/api/v1/version"
response <- try(GET(url, add_headers(`accept` = "application/json"), timeout(5)), silent = TRUE)

test_that("functions on which it depends function as necessary", {
  skip_if(!curl::has_internet(), "internet connection unsuccessful")
  skip_if(inherits(response, "try-error") || http_error(response),
          "GNverifier is unreachable or returned an error")
  skip_if(!requireNamespace("taxize", quietly = TRUE))
  sources <- taxize::gna_data_sources()

  expect_true("data.frame" %in% class(sources))
  expect_true("title" %in% colnames(sources))
  expect_true("id" %in% colnames(sources))
  expect_true("National Center for Biotechnology Information" %in% sources$title)

  datasources <- "National Center for Biotechnology Information"
  sourceIDs <- sources$id[sources$title %in% datasources]
  temp <- taxize::gna_verifier(names = "Buteo buteo", data_sources = sourceIDs)

  expect_true("data.frame" %in% class(temp))
  expect_true("submittedName" %in% colnames(temp))
  expect_true("matchedName" %in% colnames(temp))
  expect_true("dataSourceTitleShort" %in% colnames(temp))
  expect_true(nrow(temp) == 1)
  expect_true(temp$submittedName == temp$matchedName)
})

test_that("taxonRectification performs as expected", {
  skip_if(!curl::has_internet(), "internet connection unsuccessful")
  skip_if(inherits(response, "try-error") || http_error(response),
          "GNverifier is unreachable or returned an error")

  testResult <- taxonRectification(
    taxName = "Buteo buteo hartedi",
    datasources = "National Center for Biotechnology Information"
  )

  expect_true(class(testResult) == "data.frame")
  expect_true("Input Name" %in% colnames(testResult))
  expect_true("Searched Taxonomic Databases w/ Matches"
  %in% colnames(testResult))
  expect_true(nrow(testResult) == 1)
  expect_true(testResult$`Input Name`[1] == "Buteo buteo hartedi")
  expect_true(testResult$`Best Match`[1] == "Buteo buteo")
  expect_true(testResult$`Searched Taxonomic Databases w/ Matches` == "NCBI")
  expect_warning(testResult <- taxonRectification(taxName = "Buteo buteo hartedi", datasources = NULL, skipTaxize = FALSE))
  expect_warning(taxonRectification(taxName = "Buteo buteo hartedi", datasources = "cheese"))
  expect_warning(taxonRectification(taxName = "cheese", datasources = "National Center for Biotechnology Information"))
  expect_warning(taxonRectification(taxName = "Buteo buteo hartedi",
                                    datasources = "National Center for Biotechnology Information", skipTaxize = "purple"))

  testResult <- taxonRectification(
    taxName = "Buteo buteo hartedi",
    datasources = "National Center for Biotechnology Information",
    skipTaxize = TRUE
  )

  expect_true(class(testResult) == "data.frame")
  expect_true("Input Name" %in% colnames(testResult))
  expect_true("Searched Taxonomic Databases w/ Matches"
              %in% colnames(testResult))
  expect_true(nrow(testResult) == 1)
  expect_true(testResult$`Input Name`[1] == "Buteo buteo hartedi")
  expect_true(testResult$`Best Match`[1] == "Buteo buteo hartedi")
  expect_true(testResult$`Searched Taxonomic Databases w/ Matches` == "Not rectified.")
})
