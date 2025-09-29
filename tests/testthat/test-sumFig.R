context("Testing summary plot function")

library(occCite)
library(ggplot2)
data("myOccCiteObject")

print(paste0("Checking ggplot version...", packageVersion("ggplot2")))

test_that("default sumFig settings work", {
  test <- plot(myOccCiteObject)
  expect_true("yearHistogram" %in% names(test))
  expect_true(is_ggplot(test[[1]]))
  if(requireNamespace("waffle")){
    expect_true("source" %in% names(test))
    expect_true(is_ggplot(test[[2]]))
    expect_true("aggregator" %in% names(test))
    expect_true(is_ggplot(test[[3]]))
  }
})

test_that("sumFig works when plotting by species", {
  test <- plot(myOccCiteObject, bySpecies = T)
  expect_true(names(test) == "Protea cynaroides")
  expect_true("yearHistogram" %in% names(test[[1]]))
  if(requireNamespace("waffle")){
    expect_true(is_ggplot(test[[1]][[1]]))
    expect_true("source" %in% names(test[[1]]))
    expect_true(is_ggplot(test[[1]][[2]]))
    expect_true("aggregator" %in% names(test[[1]]))
    expect_true(is_ggplot(test[[1]][[3]]))
  }
})

test_that("sumFig works when plotting only year histogram by species", {
  data("myOccCiteObject")
  test <- plot(myOccCiteObject, bySpecies = T, plotTypes = "yearHistogram")
  expect_true(names(test) == "Protea cynaroides")
  expect_true("yearHistogram" %in% names(test[[1]]))
  expect_true(is_ggplot(test[[1]][[1]]))
})

test_that("sumFig works when plotting only source by species", {
  skip_if_not_installed("waffle")
  data("myOccCiteObject")
  test <- plot(myOccCiteObject, bySpecies = T, plotTypes = "source")
  expect_true(names(test) == "Protea cynaroides")
  expect_true("source" %in% names(test[[1]]))
  expect_true(is_ggplot(test[[1]][[1]]))
})

test_that("sumFig works when plotting only aggregator by species", {
  skip_if_not_installed("waffle")
  data("myOccCiteObject")
  test <- plot(x = myOccCiteObject, bySpecies = T, plotTypes = "aggregator")
  expect_true(names(test) == "Protea cynaroides")
  expect_true("aggregator" %in% names(test[[1]]))
  expect_true(is_ggplot(test[[1]][[1]]))
})
