#' @title Download occurrence points from BIEN
#'
#' @description Downloads occurrence points and useful related
#' information for processing within other occCite functions
#'
#' @param taxon A single plant species or vector of plant species
#'
#' @details `getBIENpoints` only returns all BIEN records, including non-
#' native and cultivated occurrences.
#'
#' @return A list containing \enumerate{ \item a data frame of occurrence data;
#' \item a list containing: i notes on usage, ii bibtex citations,
#' and iii acknowledgment information; \item a data frame containing
#' the raw results of a query to `BIEN::BIEN_occurrence_species()`.}
#'
#' @examples
#' \dontrun{
#' getBIENpoints(taxon = "Protea cynaroides")
#' }
#'
#' @import lubridate
#'
#' @export
getBIENpoints <- function(taxon) {
  # BIEN can't handle taxonomic authority in the search string.
  taxon <- stringr::str_extract(
    string = taxon,
    pattern = "(\\w+\\s\\w+)"
  )

  if (!curl::has_internet()) {
    warning("No internet connection available; please try again later. \n")
    return(NULL)
  }

  tryCatch(
    expr = try(occs <- BIEN::BIEN_occurrence_species(
      species = taxon,
      cultivated = T,
      new.world = F,
      native.status = F,
      collection.info = T,
      natives.only = F
    ),
    silent = T
    ),
    error = function(e) {
      message(paste("BIEN unreachable; please try again later. \n"))
    }
  )

  if (!exists("occs")) {
    return(invisible(NULL))
  }

  if (nrow(occs) == 0) {
    print(paste("There are no BIEN points for ",
      taxon, ". Are you sure it's a plant?",
      sep = ""
    ))
    return(NULL)
  }

  rawOccs <- occs
  occs <- occs[which(!is.na(occs$latitude) & !is.na(occs$longitude)), ]

  if (nrow(occs) == 0) {
    print(paste("There are no BIEN points with coordinates for ",
      taxon, ".",
      sep = ""
    ))
    return(NULL)
  }

  # Fixing dates
  occs <- occs[which(!is.na(occs$date_collected)), ]
  if (nrow(occs) == 0) {
    print(paste("There are no BIEN points that contain collection dates for ",
      taxon, ".",
      sep = ""
    ))
    return(NULL)
  }
  occs$date_collected <- lubridate::ymd(occs$date_collected)
  yearCollected <- as.numeric(format(occs$date_collected, format = "%Y"))
  monthCollected <- as.numeric(format(occs$date_collected, format = "%m"))
  dayCollected <- as.numeric(format(occs$date_collected, format = "%d"))
  occs <- cbind(occs, dayCollected, monthCollected, yearCollected)

  # Tidying up data table
  outdata <- cbind(occs[c(
    "scrubbed_species_binomial",
    "longitude", "latitude")], NA, occs[c("dayCollected", "monthCollected",
    "yearCollected", "dataset", "datasource_id"
  )])
  colnames(outdata) <- c(
    "name", "longitude", "latitude",
    "coordinateUncertaintyInMeters",
    "day", "month", "year",
    "datasetName", "datasetKey"
  )
  outdata$dataService <- "BIEN"

  outdata["name"] <- as.factor(unlist(outdata["name"]))
  outdata["longitude"] <- as.numeric(unlist(outdata["longitude"]))
  outdata["latitude"] <- as.numeric(unlist(outdata["latitude"]))
  outdata["day"] <- as.integer(unlist(outdata["day"]))
  outdata["month"] <- as.integer(unlist(outdata["month"]))
  outdata["year"] <- as.integer(unlist(outdata["year"]))
  outdata["datasetName"] <- as.factor(unlist(outdata["datasetName"]))
  outdata["datasetKey"] <- as.factor(unlist(outdata["datasetKey"]))
  outdata["dataService"] <- as.factor(unlist(outdata["dataService"]))

  # Get metadata
  occMetadata <- BIEN::BIEN_metadata_citation()
  occMetadata$license <- "CC BY-NC-ND"

  # Package it all up
  outlist <- list()
  outlist[[1]] <- outdata
  outlist[[2]] <- occMetadata
  outlist[[3]] <- rawOccs
  names(outlist) <- c("OccurrenceTable", "Metadata", "RawOccurrences")

  return(outlist)
}
