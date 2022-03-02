library(occCite)
library(ape)

treeFile <- system.file("extdata/Fish_12Tax_time_calibrated.tre",
                        package = "occCite")
phylogeny <- ape::read.nexus(treeFile)
tree <- ape::extract.clade(phylogeny, 22)
# Query databases for names
myPhyOccCiteObject <- studyTaxonList(
  x = tree,
  datasources = "GBIF Backbone Taxonomy"
)
# Query GBIF for occurrence data
if (!is.null(myPhyOccCiteObject)) {
  myPhyOccCiteObject <- occQuery(
    x = myPhyOccCiteObject,
    datasources = "gbif",
    GBIFDownloadDirectory = system.file("extdata/", package = "occCite"),
    loadLocalGBIFDownload = T,
    checkPreviousGBIFDownload = F
  )
  myPhyOccCitations <- occCitation(myPhyOccCiteObject)

  test_that("regular print", {
    expect_output(print(myPhyOccCitations))
  })

  test_that("print by species", {
    expect_output(print(myPhyOccCitations, bySpecies = TRUE))
  })
}
