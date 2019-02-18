library(occCite);
library(ape);

##Simple search
#Query databases for names
myOccCiteObject <- studyTaxonList(x = "Protea cynaroides");

#Query GBIF for occurrence data
login <- GBIFLoginManager(user = "wallacetester",
                          email = "cmerow@yahoo.com",
                          pwd = "wallacetester");
myOccCiteObject <- occQuery(x = myOccCiteObject, GBIFLogin = login, GBIFDownloadDirectory = "~/Desktop", loadLocalGBIFDownload = T);

#Get citations
myOccCitations <- occCitation(myOccCiteObject);

##With a tree
#Get tree
# the next one should work now CM(12/6)
#tree <- read.nexus("~/Dropbox/occCite/TestData/Fish_12Tax_time_calibrated.tre");
# try
tree <- read.nexus(system.file("extdata/Fish_12Tax_time_calibrated.tre",package='occCite'))
#Query databases for names
myOccCiteObject <- studyTaxonList(x = tree, datasources = "NCBI");

#Query GBIF for occurrence data
login <- GBIFLoginManager(user = "wallacetester",
                          email = "cmerow@yahoo.com",
                          pwd = "wallacetester");
myOccCiteObject <- occQuery(x = myOccCiteObject, datasources = "gbif", GBIFLogin = login, GBIFDownloadDirectory = "~/Desktop", loadLocalGBIFDownload = T);

#Get citations
myOccCitations <- occCitation(myOccCiteObject);
