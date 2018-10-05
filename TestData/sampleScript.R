library(BridgeTree);
library(ape);

#Get tree
tree <- read.nexus("~/Dropbox/BridgeTree/TestData/Fish_12Tax_time_calibrated.tre");
# try
tree <- read.nexus(system.file("extdata/Fish_12Tax_time_calibrated.tre",package='BridgeTree'))
#Query databases for names
myBridgeTreeObject <- studyTaxonList(x = tree, datasources = "NCBI");

#Query GBIF for occurrence data
login <- GBIFLoginManager(user = "******",
                          email = "*****@*****",
                          pwd = "*****");
myBridgeTreeObject <- occQuery(x = myBridgeTreeObject, GBIFLogin = login, GBIFDownloadDirectory = "~/Desktop");

#Get citations
myOccCitations <- occCitation(myBridgeTreeObject);
