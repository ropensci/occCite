## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, error = TRUE)
library(occCite)
library(ape)

## ----login, eval=FALSE--------------------------------------------------------
#  library(occCite);
#  #Creating a GBIF login
#  GBIFLogin <- GBIFLoginManager(user = "occCiteTester",
#                            email = "****@yahoo.com",
#                            pwd = "12345");

## ----simple_search, eval=F----------------------------------------------------
#  # Simple search
#  mySimpleOccCiteObject <- occQuery(x = "Protea cynaroides",
#                              datasources = c("gbif", "bien"),
#                              GBIFLogin = GBIFLogin,
#                              GBIFDownloadDirectory = paste0(path.package("occCite"), "/extdata/"),
#                              checkPreviousGBIFDownload = T);

## ----simple_search sssssecret cooking show, eval=T, echo = F------------------
# Simple search
mySimpleOccCiteObject <- occQuery(x = "Protea cynaroides",
                            datasources = c("gbif", "bien"),
                            GBIFDownloadDirectory = paste0(path.package("occCite"), "/extdata/"),
                            loadLocalGBIFDownload = T);

## ----simple_search_GBIF_results-----------------------------------------------
# GBIF search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);

## ----simple_search_BIEN_results-----------------------------------------------
#BIEN search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$BIEN$OccurrenceTable);

## ----summary of simple search-------------------------------------------------
summary(mySimpleOccCiteObject)

## ----simple_citation----------------------------------------------------------
#Get citations
mySimpleOccCitations <- occCitation(mySimpleOccCiteObject);

## ----show_simple_citations----------------------------------------------------
cat(paste(mySimpleOccCitations$Citation, 
          " Accessed via ", mySimpleOccCitations$occSearch, 
          " on ", mySimpleOccCitations$`Accession Date`, "."), 
    sep = "\n");

## ----taxonomic_rectification--------------------------------------------------
#Rectify taxonomy
myTROccCiteObject <- studyTaxonList(x = "Protea cynaroides", 
                                  datasources = c("NCBI", "EOL", "ITIS"));
myTROccCiteObject@cleanedTaxonomy

## ----simple_load--------------------------------------------------------------
# Simple load
myOldOccCiteObject <- occQuery(x = "Protea cynaroides", 
                                  datasources = c("gbif", "bien"), 
                                  GBIFLogin = NULL, 
                                  GBIFDownloadDirectory = paste0(path.package("occCite"), "/extdata/"),
                                  loadLocalGBIFDownload = T,
                                  checkPreviousGBIFDownload = F);

## ----simple_search_loaded_GBIF_results----------------------------------------
#GBIF search results
head(myOldOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);
#The full summary
summary(myOldOccCiteObject)

## ----getting_citations_from_already-downloaded_GBIF_data----------------------
#Get citations
myOldOccCitations <- occCitation(myOldOccCiteObject);
cat(paste0(mySimpleOccCitations$Citation, " Accessed via ", mySimpleOccCitations$occSearch, " on ", mySimpleOccCitations$`Accession Date`, "."), sep = "\n");

## ----multispecies_search_with_phylogeny, eval=T, echo=T-----------------------
library(ape);
#Get tree
treeFile <- system.file("extdata/Fish_12Tax_time_calibrated.tre", package='occCite');
tree <- ape::read.nexus(treeFile);
#Query databases for names
myPhyOccCiteObject <- studyTaxonList(x = tree, datasources = "NCBI");
#Query GBIF for occurrence data
myPhyOccCiteObject <- occQuery(x = myPhyOccCiteObject, 
                            datasources = "gbif",
                            GBIFDownloadDirectory = paste0(path.package("occCite"), "/extdata/"), 
                            loadLocalGBIFDownload = T,
                            checkPreviousGBIFDownload = F);

## ----getting_citations_for_a_multispecies_search, echo=T----------------------
# What does a multispecies query look like?
summary(myPhyOccCiteObject)
#Get citations
myPhyOccCitations <- occCitation(myPhyOccCiteObject);

#Print citations as text with accession dates.
cat(paste(myPhyOccCitations$Citation, 
           " Accessed via ", myPhyOccCitations$occSearch, 
           " on ", myPhyOccCitations$`Accession Date`, "."), sep = "\n");

