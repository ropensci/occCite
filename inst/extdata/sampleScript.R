library(occCite);

# Simple search -----
## Login information for GBIF ----
GBIFLogin <- GBIFLoginManager(user = "userName",
                              email = "userName@awesome.pizza",
                              pwd = "12345");

#From the beginning
myOccCiteObject <- occQuery(x = "Protea cynaroides",
                            GBIFLogin = GBIFLogin,
                            datasources = c("gbif", "bien"),
                            loadLocalGBIFDownload = F,
                            checkPreviousGBIFDownload = F);

#What does it look like?
summary(myOccCiteObject)

#Get citations
myOccCitations <- occCitation(myOccCiteObject);

#Formatting a citation document
cat(paste0(myOccCitations$Citation,
           " Accessed via ", myOccCitations$occSearch,
           " on ", myOccCitations$`Accession Date`, "."),
    sep = "\n");

#===============================================
# Advanced features -----
## Speeding up downloads ----
# If a download was previously prepared
myOccCiteObject <- occQuery(x = "Protea cynaroides",
                            GBIFLogin = GBIFLogin,
                            GBIFDownloadDirectory = "~/Desktop",
                            loadLocalGBIFDownload = F,
                            checkPreviousGBIFDownload = T);
summary(myOccCiteObject)

# If you have a download on your local machine
myOccCiteObject <- occQuery(x = "Protea cynaroides",
                            GBIFDownloadDirectory = "~/Desktop",
                            loadLocalGBIFDownload = T,
                            checkPreviousGBIFDownload = F);
summary(myOccCiteObject)

#===============================================
## Taxonomic rectification ------
#Query databases for names and rectify
taxRectObj <- studyTaxonList(x = "Prota cynarides",
                             datasources = c("FishBase", "EOL", "ARKive"));
summary(taxRectObj)

#Pass occCite object to query
taxRectObj <- occQuery(x = taxRectObj,
                       GBIFLogin = GBIFLogin,
                       GBIFDownloadDirectory = "~/Desktop",
                       loadLocalGBIFDownload = F,
                       checkPreviousGBIFDownload = T);

#===============================================
# With a tree -----
library(ape);
#Get tree
tree <- read.nexus(system.file("extdata/Fish_12Tax_time_calibrated.tre",
                               package='occCite'));
plot(tree);

#Query databases for names
myOccCiteObject <- studyTaxonList(x = tree,
                                  datasources = "NCBI");
summary(myOccCiteObject)

#Query GBIF for occurrence data
myOccCiteObject <- occQuery(x = myOccCiteObject,
                            datasources = "gbif",
                            GBIFLogin = GBIFLogin,
                            GBIFDownloadDirectory = system.file("extdata/",
                                                                package = 'occCite'),
                            loadLocalGBIFDownload = F,
                            checkPreviousGBIFDownload = T);

#Get citations
myOccCitations <- occCitation(myOccCiteObject);
cat(paste0(myOccCitations$Citation,
           " Accessed via ", myOccCitations$occSearch,
           " on ", myOccCitations$`Accession Date`, "."),
    sep = "\n");
