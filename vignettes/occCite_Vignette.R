## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, error = TRUE)
library(occCite)
library(ape)

## ----login, eval=FALSE---------------------------------------------------
#  library(occCite);
#  
#  #Creating a GBIF login
#  GBIFLogin <- GBIFLoginManager(user = "occCiteTester",
#                            email = "****@yahoo.com",
#                            pwd = "12345");

## ----simple_search, eval=FALSE-------------------------------------------
#  # Simple search
#  mySimpleOccCiteObject <- occQuery(x = "Protea cynaroides",
#                              datasources = c("gbif", "bien"),
#                              GBIFLogin = GBIFLogin,
#                              GBIFDownloadDirectory = system.file("extdata", package = "occCite"),
#                              checkPreviousGBIFDownload = T);

## ----simple_load---------------------------------------------------------
# Simple load
mySimpleOccCiteObject <- occQuery(x = "Protea cynaroides", datasources = c("gbif", "bien"), 
                                  GBIFLogin = NULL, 
                                  GBIFDownloadDirectory = system.file("extdata", package = "occCite"),
                                  loadLocalGBIFDownload = T,
                                  checkPreviousGBIFDownload = F);

## ----simple_search_GBIF_results------------------------------------------
# GBIF search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);

## ----simple_search_BIEN_results------------------------------------------
#BIEN search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$BIEN$OccurrenceTable);

## ----summary of simple search--------------------------------------------
summary(mySimpleOccCiteObject)

## ----simple_citation-----------------------------------------------------
#Get citations
mySimpleOccCitations <- occCitation(mySimpleOccCiteObject);

## ----show_simple_citations-----------------------------------------------
cat(paste(mySimpleOccCitations$Citation, sep = ""), sep = "\n");

## ----taxonomic_rectification---------------------------------------------
#Rectify taxonomy
myTROccCiteObject <- studyTaxonList(x = "Protea cynaroides", 
                                  datasources = c("NCBI", "EOL", "ITIS"));
myTROccCiteObject@cleanedTaxonomy

## ----search_using_previously-downloaded_GBIF_data------------------------
#Query databases for names
myOldOccCiteObject <- studyTaxonList(x = "Protea cynaroides", datasources = "NCBI");

#Access GBIF data from a specified download directory
##Note: you do not need a login for this.
myOldOccCiteObject <- occQuery(x = myOldOccCiteObject, 
                            datasources = "gbif",
                            GBIFDownloadDirectory = system.file("extdata/", package = "occCite"),
                            loadLocalGBIFDownload = T);

## ----simple_search_loaded_GBIF_results-----------------------------------
#GBIF search results
head(myOldOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);

#The full summary
summary(myOldOccCiteObject)

## ----getting_citations_from_already-downloaded_GBIF_data-----------------
#Get citations
myOldOccCitations <- occCitation(myOldOccCiteObject);
cat(paste(myOldOccCitations$Citation, sep = ""), sep = "\n");

## ----multispecies_search_with_phylogeny, eval=T, echo=T------------------
library(ape);

#Get tree
treeFile <- system.file("extdata/Fish_12Tax_time_calibrated.tre", package='occCite');
tree <- ape::read.nexus(treeFile);

#Query databases for names
myPhyOccCiteObject <- studyTaxonList(x = tree, datasources = "NCBI");

#Query GBIF for occurrence data
myPhyOccCiteObject <- occQuery(x = myPhyOccCiteObject, 
                            datasources = "gbif",
                            GBIFDownloadDirectory = system.file("extdata/", package = 'occCite'), 
                            loadLocalGBIFDownload = T,
                            checkPreviousGBIFDownload = F);


## ----getting_citations_for_a_multispecies_search, echo=T-----------------
# What does a multispecies query look like?
summary(myPhyOccCiteObject)

#Get citations
myPhyOccCitations <- occCitation(myPhyOccCiteObject);
cat(paste(myPhyOccCitations$Citation, sep = ""), sep = "\n");

