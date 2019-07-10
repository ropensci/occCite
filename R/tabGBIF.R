library(rgbif);

#' @title GBIF Table
#'
#' @description Internal function--imports results from `occ_download_get()` and processes them into a table for an `occCiteData` object.
#'
#' @param GBIFresults The results of a GBIF search that will be tabulated into a common format for an occCite object.
#'
#' @param taxon A single species
#'
#' @return A list of lists containing (1) a dataframe of occurrence data; (2) GBIF search metadata for every GBIF download in the specified directory.
#'
#' @examples
#' \dontrun{
#' res <- rgbif::occ_download_get(key=downloadKey, overwrite=TRUE, file.path(getwd(), taxon));
#' tG <- rgbif::occ_download_import(res);
#' tabGBIF(GBIFresults = tG);
#'}
#'
#' @export

tabGBIF <- function(GBIFresults, taxon){
  occFromGBIF <- rgbif::occ_download_import(GBIFresults);

  if(nrow(occFromGBIF)==0){
    print(paste("Note: there are no GBIF points for ", taxon, ".", sep = ""));
    return(NULL);
  }

  occFromGBIF <- data.frame(occFromGBIF$gbifID, occFromGBIF$species,
                            occFromGBIF$decimalLongitude,
                            occFromGBIF$decimalLatitude,
                            occFromGBIF$day, occFromGBIF$month,
                            occFromGBIF$year, occFromGBIF$datasetID,
                            as.character(occFromGBIF$datasetKey))
  dataService <- rep("GBIF", nrow(occFromGBIF));
  occFromGBIF <- cbind(occFromGBIF, dataService);
  occFromGBIF <- occFromGBIF[stats::complete.cases(occFromGBIF[,-8]),]# "Dataset" column excluded because it is not always filled out, but is useful for quick human checks

  colnames(occFromGBIF) <- c("gbifID", "name", "longitude",
                             "latitude", "day", "month",
                             "year", "Dataset",
                             "DatasetKey", "DataService");
  return(occFromGBIF)
}
