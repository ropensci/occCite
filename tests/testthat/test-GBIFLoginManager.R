context("Setting up GBIF Login")

library(occCite)

test_that("GBIFLoginManager error warning checks", {
  skip_if(!curl::has_internet(), "internet connection unsuccessful")

  test <- try(rgbif::occ_count(country = "DK"),
              silent = T
  )
  skip_if(class(test) != "numeric", "GBIF connection unsuccessful")

  test <- try(nchar(occCite:::check_user(NULL)),
              silent = T
  )
  skip_if( class(test) != "integer" || test < 1, "GBIF login available")

  expect_warning(GBIFLoginManager(user = "test"))
  expect_warning(GBIFLoginManager(user = "test", email = "also@test.com"))
  expect_warning(GBIFLoginManager(user = "test", email = "also@test.com", pwd = "anotherTest"))
})

test_that("GBIFLoginManager actually picks up login information", {
  skip_on_cran()

  test <- try(rgbif::occ_count(country = "DK"),
    silent = T
  )
  skip_if(class(test) != "numeric", "GBIF connection unsuccessful")

  GBIFLogin <- try(GBIFLoginManager(), silent = T)
  skip_if(is(GBIFLogin, "try-error"),
          message = "GBIF login unsuccessful")

  test <- try(rgbif::occ_download_list(
    user = GBIFLogin@username,
    pwd = GBIFLogin@pwd, limit = 1,
  ),
  silent = T
  )
  skip_if(class(test) != "list", "GBIF login unsuccessful")

  expect_true("username" %in% slotNames(GBIFLogin))
  expect_true(nchar(GBIFLogin@username) > 0)
  expect_true("email" %in% slotNames(GBIFLogin))
  expect_true(nchar(GBIFLogin@email) > 0)
  expect_true("pwd" %in% slotNames(GBIFLogin))
  expect_true(nchar(GBIFLogin@pwd) > 0)
})
