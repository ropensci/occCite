## ----setup, include=FALSE-----------------------------------------------------
library(ape)
library(occCite)
knitr::opts_chunk$set(echo = TRUE, error = TRUE)
knitr::opts_knit$set(root.dir = system.file('extdata/', package='occCite'))

## ----login, eval=FALSE--------------------------------------------------------
#  library(occCite);
#  #Creating a GBIF login
#  GBIFLogin <- GBIFLoginManager(user = "occCiteTester",
#                                email = "****@yahoo.com",
#                                pwd = "12345")

## ----simple_search, eval=F----------------------------------------------------
#  # Simple search
#  mySimpleOccCiteObject <- occQuery(x = "Protea cynaroides",
#                                    datasources = c("gbif", "bien"),
#                                    GBIFLogin = GBIFLogin,
#                                    GBIFDownloadDirectory =
#                                      system.file('extdata/', package='occCite'),
#                                    checkPreviousGBIFDownload = T)

## ----simple_search sssssecret cooking show, eval=T, echo = F------------------
# Simple search
data(myOccCiteObject)
mySimpleOccCiteObject <- myOccCiteObject

## ----simple_search_GBIF_results-----------------------------------------------
# GBIF search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable)

## ----simple_search_BIEN_results-----------------------------------------------
#BIEN search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$BIEN$OccurrenceTable)

## ----summary of simple search-------------------------------------------------
summary(mySimpleOccCiteObject)

## ----plotting a simple search, eval=T, message=FALSE, warning=FALSE, paged.print=FALSE, results='hide', fig.hold='hold', out.width="33%"----
plot(mySimpleOccCiteObject)

## ----simple_citation----------------------------------------------------------
#Get citations
mySimpleOccCitations <- occCitation(mySimpleOccCiteObject)

## ----show_simple_citations----------------------------------------------------
print(mySimpleOccCitations)

## ----taxonomic_rectification--------------------------------------------------
#Rectify taxonomy
myTROccCiteObject <- studyTaxonList(x = "Protea cynaroides", 
                                  datasources = c("National Center for Biotechnology Information",
                                                  "Encyclopedia of Life", 
                                                  "Integrated Taxonomic Information SystemITIS"))
myTROccCiteObject@cleanedTaxonomy

