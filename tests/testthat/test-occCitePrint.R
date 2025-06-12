library(occCite)
library(ape)

data(myOccCiteObject)
mySimpleOccCiteObject <- myOccCiteObject
myOccCitations <- occCitation(mySimpleOccCiteObject)

test_that("is occCitePrint working?", {
  output <- capture.output(print(myOccCitations))
  test_that("regular print", {
    expect_equal(length(output), 23)
  })
  output <- capture.output(print(myOccCitations, bySpecies = TRUE))
  test_that("print by species", {
    expect_equal(length(output), 27)
  })
})
