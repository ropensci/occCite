library(occCite);
library(ape);

##Simple search
#Query databases for names
myOccCiteObject <- studyTaxonList(x = "Tahina spectabilis");

#Query GBIF for occurrence data
GBIFLogin <- GBIFLoginManager(user = "hannah0wens", email = "hannah.owens@gmail.com", pwd = "Llab7a3m!");

myOccCiteObject <- occQuery(x = myOccCiteObject, GBIFLogin = GBIFLogin, GBIFDownloadDirectory = "~/Desktop", loadLocalGBIFDownload = F, checkPreviousGBIFDownload = T);

#Get citations
myOccCitations <- occCitation(myOccCiteObject);

##With a tree
#Get tree
# the next one should work now CM(12/6)
#tree <- read.nexus("~/Dropbox/occCite/TestData/Fish_12Tax_time_calibrated.tre");
# try
tree <- read.nexus(system.file("extdata/Fish_12Tax_time_calibrated.tre", package='occCite'))
#Query databases for names
myOccCiteObject <- studyTaxonList(x = tree, datasources = "NCBI");

#Query GBIF for occurrence data
myOccCiteObject <- occQuery(x = myOccCiteObject, datasources = "gbif", GBIFLogin = GBIFLogin, GBIFDownloadDirectory = system.file("extdata/", package = 'occCite'), loadLocalGBIFDownload = F, checkPreviousGBIFDownload = T);

#Get citations
myOccCitations <- occCitation(myOccCiteObject);
