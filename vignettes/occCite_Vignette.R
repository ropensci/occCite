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

