context("Testing summary plot function")

library(occCite)

test_that("inputs to sumFig are as expected", {
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

  expect_true(all(c(
    "name",
    "year",
    "DataService",
    "Dataset"
  )
  %in% names(tabulate.occResults(x, sp.name))))
})

test_that("default sumFig settings work", {
  data("myOccCiteObject")
  test <- plot(myOccCiteObject)
  expect_true("yearHistogram" %in% names(test))
  expect_equal(class(test[[1]]), "ggplot_built")
  expect_true("source" %in% names(test))
  expect_equal(class(test[[2]]), "ggplot_built")
  expect_true("aggregator" %in% names(test))
  expect_equal(class(test[[3]]), "ggplot_built")
})

test_that("sumFig works when plotting by species", {
  data("myOccCiteObject")
  test <- plot(myOccCiteObject, bySpecies = T)
  expect_true(names(test) == "Protea cynaroides")
  expect_true("yearHistogram" %in% names(test[[1]]))
  expect_equal(class(test[[1]][[1]]), "ggplot_built")
  expect_true("source" %in% names(test[[1]]))
  expect_equal(class(test[[1]][[2]]), "ggplot_built")
  expect_true("aggregator" %in% names(test[[1]]))
  expect_equal(class(test[[1]][[3]]), "ggplot_built")
})

test_that("sumFig works when plotting only year histogram by species", {
  data("myOccCiteObject")
  test <- plot(myOccCiteObject, bySpecies = T, plotTypes = "yearHistogram")
  expect_true(names(test) == "Protea cynaroides")
  expect_true("yearHistogram" %in% names(test[[1]]))
  expect_equal(class(test[[1]][[1]]), "ggplot_built")
})

test_that("sumFig works when plotting only source by species", {
  data("myOccCiteObject")
  test <- plot(myOccCiteObject, bySpecies = T, plotTypes = "source")
  expect_true(names(test) == "Protea cynaroides")
  expect_true("source" %in% names(test[[1]]))
  expect_equal(class(test[[1]][[1]]), "ggplot_built")
})

test_that("sumFig works when plotting only aggregator by species", {
  data("myOccCiteObject")
  test <- plot(x = myOccCiteObject, bySpecies = T, plotTypes = "aggregator")
  expect_true(names(test) == "Protea cynaroides")
  expect_true("aggregator" %in% names(test[[1]]))
  expect_equal(class(test[[1]][[1]]), "ggplot_built")
})
