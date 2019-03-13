## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, error = TRUE)

## ----login---------------------------------------------------------------
library(occCite);

#Creating a GBIF login
login <- GBIFLoginManager(user = "wallacetester",
                          email = "cmerow@yahoo.com",
                          pwd = "wallacetester");

## ----simple_search-------------------------------------------------------
##Simple search
mySimpleOccCiteObject <- occQuery(x = "Protea cynaroides",
                            datasources = c("gbif", "bien"),
                            GBIFLogin = login, 
                            GBIFDownloadDirectory = system.file("extdata", package = "occCite"));

## ----simple_search_GBIF_results------------------------------------------
#GBIF search results
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

## ----multispecies_search_with_phylogeny, eval=F, echo=T------------------
#  library(ape);
#  
#  #Get tree
#  # try
#  treeFile <- system.file("extdata/Fish_12Tax_time_calibrated.tre", package='occCite');
#  tree <- read.nexus(treeFile);
#  
#  #Query databases for names
#  myPhyOccCiteObject <- studyTaxonList(x = tree, datasources = "NCBI");
#  
#  #Query GBIF for occurrence data
#  login <- GBIFLoginManager(user = "wallacetester",
#                            email = "cmerow@yahoo.com",
#                            pwd = "wallacetester");
#  
#  myPhyOccCiteObject <- occQuery(x = myPhyOccCiteObject,
#                              GBIFLogin = login,
#                              datasources = "gbif",
#                              GBIFDownloadDirectory = "~/Desktop");

## ----getting_citations_for_a_multispecies_search, eval=F, echo=T---------
#  #Get citations
#  myPhyOccCitations <- occCitation(myPhyOccCiteObject);
#  cat(paste(myPhyOccCitations$Citation, sep = ""), sep = "\n");

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

