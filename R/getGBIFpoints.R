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
#' @return A list containing (1) a dataframe of occurrence data; (2) GBIF search metadata; (3) a dataframe containing the raw results of a query to `rgbif::occ_download_get()`.
#'
#' @examples
#' \dontrun{
#' getGBIFpoints(taxon="Gadus morhua",
#'               GBIFLogin = myGBIFLogin,
#'               GBIFDownloadDirectory = NULL);
#'}
#'
#' @export

getGBIFpoints<-function(taxon, GBIFLogin = GBIFLogin, GBIFDownloadDirectory = GBIFDownloadDirectory){

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
  fileTax <- gsub(pattern = " ", replacement = "_", x = taxon)
  dir.create(file.path(GBIFDownloadDirectory, fileTax),
               showWarnings = FALSE);
  presWD <- getwd()
  setwd(GBIFDownloadDirectory);

  #Getting the download from GBIF and loading it into R
  res <- rgbif::occ_download_get(key=occD[1], overwrite=TRUE,
                                 file.path(getwd(), fileTax));
  rawOccs <- res
  occFromGBIF <- tabGBIF(GBIFresults = res, taxon);

  occMetadata <- rgbif::occ_download_meta(occD[1]);

  #Preparing list for return
  outlist<-list();
  outlist[[1]]<-occFromGBIF;
  outlist[[2]]<-occMetadata;
  outlist[[3]]<-rawOccs;
  names(outlist) <- c("OccurrenceTable", "Metadata", "RawOccurrences");

  setwd(presWD);
  return(outlist);
}
