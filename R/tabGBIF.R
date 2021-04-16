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
  # "Dataset" column excluded because not always filled out
  ## but useful for quick human checks
  occFromGBIF <- occFromGBIF[stats::complete.cases(occFromGBIF[, -8]), ]

  colnames(occFromGBIF) <- c(
    "gbifID", "name", "longitude",
    "latitude", "day", "month",
    "year", "Dataset",
    "DatasetKey", "DataService"
  )
  return(occFromGBIF)
}
