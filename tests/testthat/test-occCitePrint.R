library(occCite)
library(ape)

data(myOccCiteObject)
mySimpleOccCiteObject <- myOccCiteObject
myOccCitations <- occCitation(mySimpleOccCiteObject)

test_that("regular print", {
  output <- capture.output(print(myOccCitations))
  expect_equal(class(output), "character")
})

test_that("print by species", {
  output <- capture.output(print(myOccCitations, bySpecies = TRUE))
  expect_equal(class(output), "character")
})
