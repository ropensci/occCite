## ----setup, include=FALSE-----------------------------------------------------
library(ape)
library(occCite)
knitr::opts_chunk$set(echo = TRUE, error = TRUE)
knitr::opts_knit$set(root.dir = system.file('extdata/', package='occCite'))

## ----simple_load--------------------------------------------------------------
# Simple load
myOldOccCiteObject <- occQuery(x = "Protea cynaroides", 
                                  datasources = c("gbif", "bien"), 
                                  GBIFLogin = NULL, 
                                  GBIFDownloadDirectory = system.file('extdata/', package='occCite'),
                                  loadLocalGBIFDownload = T,
                                  checkPreviousGBIFDownload = F)

## ----simple_search_loaded_GBIF_results----------------------------------------
#GBIF search results
head(myOldOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);
#The full summary
summary(myOldOccCiteObject)

## ----getting_citations_from_already-downloaded_GBIF_data----------------------
#Get citations
myOldOccCitations <- occCitation(myOldOccCiteObject)
print(myOldOccCitations)

## ----multispecies_search_with_phylogeny, eval=T, echo=T-----------------------
library(ape)
#Get tree
treeFile <- system.file("extdata/Fish_12Tax_time_calibrated.tre", package='occCite')
phylogeny <- ape::read.nexus(treeFile)
tree <- ape::extract.clade(phylogeny, 18)
#Query databases for names
myPhyOccCiteObject <- studyTaxonList(x = tree, 
                                     datasources = "National Center for Biotechnology Information")
#Query GBIF for occurrence data
myPhyOccCiteObject <- occQuery(x = myPhyOccCiteObject, 
                            datasources = "gbif",
                            GBIFDownloadDirectory = system.file('extdata/', package='occCite'),
                            loadLocalGBIFDownload = T,
                            checkPreviousGBIFDownload = F)
# What does a multispecies query look like?
summary(myPhyOccCiteObject)

## ----plotting all species, eval=T, message=FALSE, warning=FALSE, paged.print=FALSE, results='hide', fig.hold='hold', out.width="33%"----
plot(myPhyOccCiteObject)

## ----plotting phylogenetic search by species, eval=T, message=FALSE, warning=FALSE, paged.print=FALSE, results='hide', fig.hold='hold', out.width="33%"----
plot(myPhyOccCiteObject, bySpecies = T)

## ----getting_citations_for_a_multispecies_search, echo=T----------------------
#Get citations
myPhyOccCitations <- occCitation(myPhyOccCiteObject)

#Print citations as text with accession dates.
print(myPhyOccCitations, bySpecies = T)

