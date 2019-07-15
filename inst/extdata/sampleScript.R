library(occCite);
library(ape);

##Simple search
#Query GBIF for occurrence data
GBIFLogin <- GBIFLoginManager(user = "userName", email = "userName@awesome.pizza", pwd = "12345");

#From the beginning
myOccCiteObject <- occQuery(x = "Protea cynaroides", GBIFLogin = GBIFLogin, datasources = c("gbif", "bien"), GBIFDownloadDirectory = "~/Desktop", loadLocalGBIFDownload = F, checkPreviousGBIFDownload = F);

#Faster, if a download was previously prepared
myOccCiteObject <- occQuery(x = "Protea cynaroides", GBIFLogin = GBIFLogin, GBIFDownloadDirectory = "~/Desktop", loadLocalGBIFDownload = F, checkPreviousGBIFDownload = T);

#What does it look like?
summary(myOccCiteObject)

#Get citations
myOccCitations <- occCitation(myOccCiteObject);
cat(paste0(myOccCitations$Citation, " Accessed via ", myOccCitations$occSearch, " on ", myOccCitations$`Accession Date`, "."), sep = "\n");

##Taxonomic rectification
#Query databases for names and rectify
myOccCiteObject <- studyTaxonList(x = "Protea cynaroides", datasources = c("FishBase", "EOL", "ARKive"));

summary(myOccCiteObject)

myOccCiteObject <- occQuery(x = myOccCiteObject, GBIFLogin = GBIFLogin, GBIFDownloadDirectory = "~/Desktop", loadLocalGBIFDownload = F, checkPreviousGBIFDownload = T);

##With a tree
#Get tree
tree <- read.nexus(system.file("extdata/Fish_12Tax_time_calibrated.tre", package='occCite'));
plot(tree);

#Query databases for names
myOccCiteObject <- studyTaxonList(x = tree, datasources = "NCBI");

summary(myOccCiteObject)

#Query GBIF for occurrence data
myOccCiteObject <- occQuery(x = myOccCiteObject, datasources = "gbif", GBIFLogin = GBIFLogin, GBIFDownloadDirectory = system.file("extdata/", package = 'occCite'), loadLocalGBIFDownload = F, checkPreviousGBIFDownload = T);

#Get citations
myOccCitations <- occCitation(myOccCiteObject);
cat(paste0(myOccCitations$Citation, " Accessed via ", myOccCitations$occSearch, " on ", myOccCitations$`Accession Date`, "."), sep = "\n");
