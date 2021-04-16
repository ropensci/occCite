context("GBIF tabulation")

library(occCite)

test_that("data entered into tabGBIF is as expected", {
  skip_on_cran() # Requires GBIF login information
  skip_if(
    nchar(Sys.getenv("GBIF_EMAIL")) < 1,
    "GBIF Login information not available"
  )

  test <- try(rgbif::occ_download(
    user = GBIFLogin@username,
    email = GBIFLogin@email,
    pwd = GBIFLogin@pwd,
    rgbif::pred("catalogNumber", 217880)
  ),
  silent = T
  )
  skip_if(class(test) != "occ_download", "GBIF login unsuccessful")

  GBIFLogin <- GBIFLoginManager()

  key <- rgbif::name_suggest(q = "Protea cynaroides", rank = "species")$data$key[1]
  occD <- prevGBIFdownload(key, GBIFLogin)
  res <- rgbif::occ_download_get(
    key = occD, overwrite = TRUE,
    file.path(system.file("extdata/",
      package = "occCite"
    ))
  )

  expect_equal(class(res), "occ_download_get")
})

test_that("verify occ_download_import results have expected columns", {
  skip_on_cran() # Requires GBIF login information
  skip_if(
    nchar(Sys.getenv("GBIF_EMAIL")) < 1,
    "GBIF Login information not available"
  )

  test <- try(rgbif::occ_download(
    user = GBIFLogin@username,
    email = GBIFLogin@email,
    pwd = GBIFLogin@pwd,
    rgbif::pred("catalogNumber", 217880)
  ),
  silent = T
  )
  skip_if(class(test) != "occ_download", "GBIF login unsuccessful")

  GBIFLogin <- GBIFLoginManager()

  key <- rgbif::name_suggest(q = "Protea cynaroides", rank = "species")$data$key
  occD <- prevGBIFdownload(key, GBIFLogin)
  res <- rgbif::occ_download_get(
    key = occD, overwrite = TRUE,
    file.path(system.file("extdata/",
      package = "occCite"
    ))
  )
  occFromGBIF <- rgbif::occ_download_import(res)

  expect_true("data.frame" %in% class(occFromGBIF))
  expect_true("species" %in% colnames(occFromGBIF))
  expect_true("decimalLongitude" %in% colnames(occFromGBIF))
  expect_true("decimalLatitude" %in% colnames(occFromGBIF))
  expect_true("day" %in% colnames(occFromGBIF))
  expect_true("month" %in% colnames(occFromGBIF))
  expect_true("year" %in% colnames(occFromGBIF))
  expect_true("datasetName" %in% colnames(occFromGBIF))
  expect_true("datasetKey" %in% colnames(occFromGBIF))
})

test_that("tabGBIF results as expected", {
  skip_on_cran() # Requires GBIF login information
  skip_if(
    nchar(Sys.getenv("GBIF_EMAIL")) < 1,
    "GBIF Login information not available"
  )

  test <- try(rgbif::occ_download(
    user = GBIFLogin@username,
    email = GBIFLogin@email,
    pwd = GBIFLogin@pwd,
    rgbif::pred("catalogNumber", 217880)
  ),
  silent = T
  )
  skip_if(class(test) != "occ_download", "GBIF login unsuccessful")

  GBIFLogin <- GBIFLoginManager()

  key <- rgbif::name_suggest(q = "Protea cynaroides", rank = "species")$data$key
  occD <- prevGBIFdownload(key, GBIFLogin)
  res <- rgbif::occ_download_get(
    key = occD, overwrite = TRUE,
    file.path(system.file("extdata/", package = "occCite"))
  )
  occFromGBIF <- occCite:::tabGBIF(GBIFresults = res, "Protea cynaroides")

  expect_equal(class(occFromGBIF), "data.frame")
  expect_true("name" %in% colnames(occFromGBIF))
  expect_true("longitude" %in% colnames(occFromGBIF))
  expect_true("latitude" %in% colnames(occFromGBIF))
  expect_true("day" %in% colnames(occFromGBIF))
  expect_true("month" %in% colnames(occFromGBIF))
  expect_true("year" %in% colnames(occFromGBIF))
  expect_true("Dataset" %in% colnames(occFromGBIF))
  expect_true("DatasetKey" %in% colnames(occFromGBIF))
  expect_true("DataService" %in% colnames(occFromGBIF))
})
