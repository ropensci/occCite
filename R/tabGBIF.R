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
#' @importFrom dplyr inner_join join_by %>%
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
    occFromGBIF$coordinateUncertaintyInMeters,
    occFromGBIF$day, occFromGBIF$month,
    occFromGBIF$year,
    as.character(occFromGBIF$datasetKey)
  )
  colnames(occFromGBIF) <- c(
    "gbifID", "name", "longitude",
    "latitude", "coordinateUncertaintyInMeters", "day", "month",
    "year",
    "datasetKey"
  )

  occFromGBIF$dataService <- "GBIF"

  datasetTitles <- data.frame(do.call(rbind,lapply(unique(occFromGBIF$datasetKey),
                                                      FUN = function(y) {
                                                        c(y, rgbif::dataset_get(y)$title)
                                                      }
  )))
  colnames(datasetTitles) <- c("datasetKey","datasetName")

  datasetKey <- NULL # Cheat to silence R check
  occFromGBIF <- occFromGBIF %>%
    inner_join(datasetTitles, by = join_by(datasetKey))

  # Remove entries with NA values in long, lat, and year
  occFromGBIF <- occFromGBIF[complete.cases(occFromGBIF[, c(
    "longitude",
    "latitude",
    "year"
  )]), ]

  return(occFromGBIF)
}
