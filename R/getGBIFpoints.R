library(rgbif);
library(stats);

#' @title Download occurrence points from GBIF
#'
#' @description Downloads occurrence points and useful related information for processing within other occCite functions
#'
#' @param taxon A single species
#'
#' @param GBIFLogin An object of class \code{\link{GBIFLogin}} to log in to GBIF to begin the download.
#'
#' @param GBIFDownloadDirectory An optional argument that specifies the local directory where GBIF downloads will be saved. If this is not specified, the downloads will be saved to your current working directory.
#'
#' @param limit An optional argument that limits the number of records returned to n. Note: This will return the FIRST n records, and will likely be a very biased sample.
#'
#' @return A list containing (1) a dataframe of occurrence data; (2) GBIF search metadata
#'
#' @examples
#' \dontrun{
#' getGBIFpoints(taxon="Gadus morhua",
#'               GBIFLogin = myGBIFLogin,
#'               GBIFDownloadDirectory = NULL,
#'               limit = NULL);
#'}
#'
#' @export

getGBIFpoints<-function(taxon, GBIFLogin = GBIFLogin, GBIFDownloadDirectory = GBIFDownloadDirectory, limit = NULL){

  key <- rgbif::name_suggest(q=taxon, rank='species')$key[1]


  occD <- rgbif::occ_download(paste("taxonKey = ", key, sep = ""),
                       "hasCoordinate = true", "hasGeospatialIssue = false",
                       user = GBIFLogin@username, email = GBIFLogin@email,
                       pwd = GBIFLogin@pwd);

  print(paste("Please be patient while GBIF prepares your download for ", taxon, ". This can take some time.", sep = ""));
  while (rgbif::occ_download_meta(occD[1])$status != "SUCCEEDED"){
    Sys.sleep(60);
    print(paste("Still waiting for", taxon, "download preparation to be completed."))
  }

  #Create folders for each species at the designated location
  dir.create(file.path(GBIFDownloadDirectory, taxon),
               showWarnings = FALSE);
  presWD <- getwd()
  setwd(GBIFDownloadDirectory);

  #Getting the download from GBIF and loading it into R
  res <- rgbif::occ_download_get(key=occD[1], overwrite=TRUE,
                                 file.path(getwd(), taxon));
  occFromGBIF <- rgbif::occ_download_import(res);
  occFromGBIF <- data.frame(occFromGBIF$gbifID, occFromGBIF$species,
                            occFromGBIF$decimalLongitude,
                            occFromGBIF$decimalLatitude,
                            occFromGBIF$day, occFromGBIF$month,
                            occFromGBIF$year, occFromGBIF$datasetID,
                            occFromGBIF$datasetKey)
  dataService <- rep("GBIF", nrow(occFromGBIF));
  occFromGBIF <- cbind(occFromGBIF, dataService);
  occFromGBIF <- occFromGBIF[stats::complete.cases(occFromGBIF),]
  if (is.null(limit)){
    limit <- nrow(occFromGBIF);
  }

  occFromGBIF <- as.data.frame(occFromGBIF)[1:min(limit,nrow(occFromGBIF)),];
  colnames(occFromGBIF) <- c("gbifID", "name", "longitude",
                             "latitude", "day", "month",
                             "year", "Dataset",
                             "DatasetKey", "DataService");
  occMetadata <- rgbif::occ_download_meta(occD[1]);

  #Preparing list for return
  outlist<-list();
  outlist[[1]]<-occFromGBIF;
  outlist[[2]]<-occMetadata;
  names(outlist) <- c("OccurrenceTable", "Metadata")

  setwd(presWD);
  return(outlist);
}
