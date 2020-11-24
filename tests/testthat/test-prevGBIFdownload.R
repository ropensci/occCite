context("Get information for a previously-prepared GBIF download")

library(occCite)

test_that("download list retrievable from GBIF.org", {
  skip_on_cran()
  skip_if(nchar(Sys.getenv("GBIF_EMAIL")) < 1, "GBIF Login information not available")

  test <- try(rgbif::occ_download(user=GBIFLogin@username,
                                  email = GBIFLogin@email,
                                  pwd = GBIFLogin@pwd,
                                  rgbif::pred("catalogNumber", 217880)), silent = T)
  skip_if(class(test) != 'occ_download', "GBIF login unsuccessful")

  GBIFLogin <- GBIFLoginManager()
  dl <- rgbif::occ_download_list(user= GBIFLogin@username, pwd = GBIFLogin@pwd, limit = 1000)

  expect_true("results" %in% names(dl))
})

test_that("download list parseable by prevGBIFdownload", {
  skip_on_cran()
  skip_if(nchar(Sys.getenv("GBIF_EMAIL")) < 1, "GBIF Login information not available")

  test <- try(rgbif::occ_download(user=GBIFLogin@username,
                                  email = GBIFLogin@email,
                                  pwd = GBIFLogin@pwd,
                                  rgbif::pred("catalogNumber", 217880)), silent = T)
  skip_if(class(test) != 'occ_download', "GBIF login unsuccessful")

  GBIFLogin <- GBIFLoginManager()
  dl <- rgbif::occ_download_list(user= GBIFLogin@username,
                                 pwd = GBIFLogin@pwd,
                                 limit = 1000)

  expect_true("request.predicate.key" %in% colnames(dl$results))
  expect_true("request.predicate.value" %in% colnames(dl$results))
  expect_true("request.predicate.predicates" %in% colnames(dl$results))
  expect_true(class(dl$results$request.predicate.predicates)=="list")
  expect_true(any(unlist(lapply(dl$results$request.predicate.predicates,
                                FUN = function(x) {class(x)=="data.frame"}))))
})

