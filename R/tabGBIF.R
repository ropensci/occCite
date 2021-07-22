#' @title GBIF Table
#'
#' @description Internal function--imports results from `occ_download_get()`
#' and processes them into a table for an `occCiteData` object.
#'
#' @param GBIFresults The results of a GBIF search that will be tabulated
#' into a common format for an occCite object.
#'
#' @param taxon A single species name, for tracing/error checking purposes
#' only.
#'
#' @return A list of lists containing \enumerate{ \item a data frame of
#' occurrence data  \item GBIF search metadata for every GBIF download in
#' the specified directory.}
#'
#' @keywords internal
#'
#' @noRd

tabGBIF <- function(GBIFresults, taxon) {
  occFromGBIF <- rgbif::occ_download_import(GBIFresults)

  if (nrow(occFromGBIF) == 0) {
    print(paste("Note: there are no GBIF points for ", taxon, ".", sep = ""))
    return(NULL)
  }

  occFromGBIF <- data.frame(
    occFromGBIF$gbifID, occFromGBIF$species,
    occFromGBIF$decimalLongitude,
    occFromGBIF$decimalLatitude,
    occFromGBIF$day, occFromGBIF$month,
    occFromGBIF$year, occFromGBIF$datasetName,
    as.character(occFromGBIF$datasetKey)
  )
  dataService <- rep("GBIF", nrow(occFromGBIF))
  occFromGBIF <- cbind(occFromGBIF, dataService)

  colnames(occFromGBIF) <- c(
    "gbifID", "name", "longitude",
    "latitude", "day", "month",
    "year", "Dataset",
    "DatasetKey", "DataService"
  )

  occFromGBIF$Dataset <- unlist(lapply(occFromGBIF$DatasetKey,
                                       FUN = function(y)
                                         rgbif::gbif_citation(y)$citation$title))

  # Remove entries with NA values in long, lat, and year
  occFromGBIF <- occFromGBIF[complete.cases(occFromGBIF[,c("longitude", "latitude", "year")]),]

  return(occFromGBIF)
}
