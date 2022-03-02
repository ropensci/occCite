context("Setting up GBIF Login")

library(occCite)

test_that("GBIFLoginManager error messaging behaves as expected", {
  skip_on_cran()

  test <- try(rgbif::occ_count(country = "DK"),
    silent = T
  )
  skip_if(class(test) != "numeric", "GBIF connection unsuccessful")

  expect_warning(
    GBIFLoginManager("testing", "the", "login")
  )
})

test_that("GBIFLoginManager actually picks up login information", {
  skip_if(
    nchar(Sys.getenv("GBIF_EMAIL")) < 1,
    "GBIF Login information not available"
  )

  test <- try(rgbif::occ_count(country = "DK"),
    silent = T
  )
  skip_if(class(test) != "numeric", "GBIF connection unsuccessful")

  GBIFLogin <- GBIFLoginManager()
  test <- try(rgbif::occ_download(
    user = GBIFLogin@username,
    email = GBIFLogin@email,
    pwd = GBIFLogin@pwd,
    rgbif::pred("catalogNumber", 217880)
  ),
  silent = T
  )
  skip_if(class(test) != "occ_download", "GBIF login unsuccessful")

  expect_true("username" %in% slotNames(GBIFLogin))
  expect_true(nchar(GBIFLogin@username) > 0)
  expect_true("email" %in% slotNames(GBIFLogin))
  expect_true(nchar(GBIFLogin@email) > 0)
  expect_true("pwd" %in% slotNames(GBIFLogin))
  expect_true(nchar(GBIFLogin@pwd) > 0)
})
