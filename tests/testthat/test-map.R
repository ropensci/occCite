context("Testing mapping function")

library(occCite)

test_that("inputs to map are as expected", {
  data("myOccCiteObject")
  testResults <- myOccCiteObject@occResults
  resNames <- names(testResults)
  sp.name <- names(myOccCiteObject@occResults)[[1]]
  x <- myOccCiteObject@occResults[[1]]
  tabResults <- tabulate.occResults(x = x, sp.name = sp.name)

  expect_true(class(myOccCiteObject) == "occCiteData")
  expect_true(names(myOccCiteObject@occResults) > 0)
  expect_true(is.character(resNames))
  expect_true(all(!is.na(stringr::str_extract(
    string = resNames,
    pattern = "(\\w+\\s\\w+)"
  ))))

  expect_true(all(c("longitude", "latitude")
  %in% names(tabulate.occResults(x, sp.name))))
})

test_that("default occCiteMap settings work", {
  data("myOccCiteObject")

  expect_error(occCiteMap())

  test <- occCiteMap(myOccCiteObject)
  expect_true(all(c("leaflet", "htmlwidget") %in% class(test)))
})

test_that("occCiteMap works with species specified", {
  data("myOccCiteObject")

  expect_error(occCiteMap(myOccCiteObject, "Protea cynaroides",
                          species_colors = "red", "blue"))

  test <- occCiteMap(myOccCiteObject, "Protea cynaroides")
  expect_true(all(c("leaflet", "htmlwidget") %in% class(test)))
})

test_that("occCiteMap works with non-awesome markers color specified", {
  data("myOccCiteObject")
  test <- occCiteMap(myOccCiteObject,
    "Protea cynaroides",
    species_colors = "brown",
    awesomeMarkers = F
  )
  expect_true(all(c("leaflet", "htmlwidget") %in% class(test)))
})

test_that("occCiteMap works with awesome markers color specified", {
  data("myOccCiteObject")
  test <- occCiteMap(myOccCiteObject,
    "Protea cynaroides",
    species_colors = "lightred",
    awesomeMarkers = T
  )
  expect_true(all(c("leaflet", "htmlwidget") %in% class(test)))
})

test_that("occCiteMap works with map_limit specified", {
  data("myOccCiteObject")
  test <- occCiteMap(myOccCiteObject,
    "Protea cynaroides",
    species_colors = "lightred",
    awesomeMarkers = T,
    map_limit = 10
  )
  expect_true(all(c("leaflet", "htmlwidget") %in% class(test)))
})

test_that("occCiteMap works with cluster set to true", {
  data("myOccCiteObject")
  test <- occCiteMap(myOccCiteObject,
    "Protea cynaroides",
    species_colors = "lightred",
    awesomeMarkers = T,
    cluster = T
  )
  expect_true(all(c("leaflet", "htmlwidget") %in% class(test)))
})
