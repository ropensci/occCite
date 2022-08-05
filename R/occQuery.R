#' @title Query from Taxon List
#'
#' @description Takes rectified list of specimens from
#' \code{\link{studyTaxonList}} and returns point data from
#' \code{\link{rgbif}} with metadata.
#'
#' @param x An object of class \code{\link{occCiteData}} (the results of
#' a \code{\link{studyTaxonList}} search) OR a vector with a list of species
#' names. Note: If the latter, taxonomic rectification uses NCBI
#' taxonomies. If you want more control than this, use
#' \code{\link{studyTaxonList}} to create a \code{\link{occCiteData}} object
#' first.
#'
#' @param datasources A vector of occurrence data sources to search. This is
#' currently limited to GBIF and BIEN, but may expand in the future.
#'
#' @param GBIFLogin An object of class \code{\link{GBIFLogin}} to log in to
#' GBIF to begin the download.
#'
#' @param GBIFDownloadDirectory An optional argument that specifies the local
#' directory where GBIF downloads will be saved. If this is not specified,
#' the downloads will be saved to your current working directory.
#'
#' @param loadLocalGBIFDownload If \code{loadLocalGBIFDownload = T}, then
#' occCite will load occurrences for the specified species that have been
#' downloaded by the user and stored in the directory specified by
#' \code{GBIFDownloadDirectory}.
#'
#' @param checkPreviousGBIFDownload If \code{loadLocalGBIFDownload = T},
#' occCite will check for previously-prepared GBIF downloads on the user's
#' GBIF account. Setting this option to `TRUE` can significantly speed up
#' query time if the user has previously queried GBIF for the same taxa.
#'
#' @param options A vector of options to pass to \code{\link{occ_download}}.
#'
#' @return The object of class \code{\link{occCiteData}} supplied by the user
#' as an argument, with occurrence data search results, as well as metadata
#' on the occurrence sources queried.
#'
#' @details If you are querying GBIF, note that `occQuery()` only returns
#' records from GBIF that have coordinates, aren't flagged as having
#' geospatial issues, and have an occurrence status flagged as "PRESENT".
#'
#' @examples
#' \dontrun{
#' ## If you have already created a occCite object, and have not previously
#' ## downloaded GBIF data.
#' occQuery(
#'   x = myOccCiteObject,
#'   datasources = c("gbif", "bien"),
#'   GBIFLogin = myLogin,
#'   GBIFDownloadDirectory = "./Desktop",
#'   loadLocalGBIFDownload = F
#' )
#'
#' ## If you don't have a occCite object yet
#' occQuery(
#'   x = c("Buteo buteo", "Protea cynaroides"),
#'   datasources = c("gbif", "bien"),
#'   GBIFLogin = myLogin,
#'   GBIFOverwrite = T,
#'   GBIFDownloadDirectory = "./Desktop",
#'   loadLocalGBIFDownload = F
#' )
#'
#' ## If you have previously downloaded occurrence data from GBIF
#' ## and saved it in a folder called "GBIFDownloads".
#' occQuery(
#'   x = c("Buteo buteo", "Protea cynaroides"),
#'   datasources = c("gbif", "bien"),
#'   GBIFLogin = myLogin,
#'   GBIFoverwrite = T,
#'   GBIFDownloadDirectory = "./Desktop/GBIFDownloads",
#'   loadLocalGBIFDownload = T
#' )
#' }
#'
#' @export

occQuery <- function(x = NULL,
                     datasources = c("gbif", "bien"),
                     GBIFLogin = NULL,
                     GBIFDownloadDirectory = NULL,
                     loadLocalGBIFDownload = F,
                     checkPreviousGBIFDownload = T,
                     options = NULL) {

  # File hygene
  oldwd <- getwd()
  on.exit(setwd(oldwd))

  # Error check input x.
  if (!is(x, "occCiteData") & !is.vector(x)) {
    warning(paste0(
      "Input x is not of class 'occCiteData', nor is it a vector.\n",
      "Input x must be result of a studyTaxonList() search OR a\n",
      "vector with a list of taxon names.\n"
    ))
    return(NULL)
  }

  # Instantiate a occCite data object if one was not supplied
  if (!is(x, "occCiteData")) {
    x <- studyTaxonList(x)
  }

  # Error check input datasources.
  if (!is.vector(datasources) && is(datasources, "character")) {
    warning(paste0(
      "Input datasources is not of class 'vector'.\n",
      "Datasources object must be a vector of class 'character'.\n"
    ))
    return(NULL)
  }

  # Error check input GBIF directory.
  if ("gbif" %in% datasources &&
    !is.null(GBIFDownloadDirectory) &&
    !is(GBIFDownloadDirectory, "character")) {
    warning("Input GBIFDownload directory is not of class 'character'.\n")
    return(NULL)
  }

  if (is.null(GBIFDownloadDirectory)) {
    GBIFDownloadDirectory <- getwd()
  }

  if (!dir.exists(GBIFDownloadDirectory)) {
    warning(paste0(
      "You have specified a non-existant location\n",
      "for your GBIF data downloads.\n"
    ))
    return(NULL)
  }

  if (!is.logical(loadLocalGBIFDownload)) {
    warning(paste0(
      "You have not used a logical operator to specify\n",
      "whether occCite should pull already-downloaded \n",
      "occurrences from", GBIFDownloadDirectory, "."
    ))
    return(NULL)
  }

  if (!is.logical(checkPreviousGBIFDownload)) {
    warning(paste0(
      "You have not used a logical operator to\n",
      "specify whether occCite should check GBIF\n",
      "for previously-prepared downloads for the\n",
      "taxa specified."
    ))
    return(NULL)
  }

  # Check to see if the sources input are actually ones used by occQuery
  sources <- c("gbif", "bien") # sources
  datasources <- tolower(datasources)
  if (sum(!datasources %in% sources) > 0) {
    warning(paste0(
      "The following datasources are ",
      "not implemented in occQuery(): ",
      datasources[!datasources %in% sources],
    ))
    return(NULL)
  } else if (is.null(datasources)) { # Fills in NULL
    x@occSources <- sources
  } else {
    x@occSources <- datasources
  }

  # If GBIF was selected, check to see if GBIF login information is supplied.
  if ("gbif" %in% datasources &&
    !is(GBIFLogin, "GBIFLogin") &&
    !loadLocalGBIFDownload) {
    warning(paste0(
      "You have chosen GBIF as a datasource,\n",
      "but have not supplied GBIF login information.\n",
      "Please create a GBIFLogin object using GBIFLoginManager().\n"
    ))
    return(NULL)
  }

  # Get time stamp for search
  x@occCiteSearchDate <- as.character(Sys.Date(), format = "%Y-%m-%d")

  # Occurrence queries for each species
  queryResults <- x
  searchTaxa <- as.character(queryResults@cleanedTaxonomy$`Best Match`)

  # Check to make sure there was a taxon match
  if (grepl(
    pattern = "No match",
    x = paste0(searchTaxa, collapse = "")
  ) | is.null(searchTaxa)) {
    warning(paste0(
      "There was no taxonomic match for ",
      queryResults@cleanedTaxonomy[queryResults@cleanedTaxonomy$`Best Match` ==
                                     "No match", 1],
      ". This/these species have been removed from your search.\n"
    ))
    searchTaxa <- searchTaxa[searchTaxa != "No match"]
    if (length(searchTaxa) == 0) {
      warning(paste0(
        "No names provided had taxonomic matches.\n",
        "The search has been cancelled."
      ))
      return(NULL)
    }
  }

  # For GBIF
  if ("gbif" %in% datasources) {
    gbifResults <- vector(mode = "list", length = length(searchTaxa))
    names(gbifResults) <- searchTaxa
    if (loadLocalGBIFDownload) {
      currentWD <- getwd()
      setwd(GBIFDownloadDirectory)
      for (i in 1:length(searchTaxa)) {
        # Gets *all* downloaded records
        temp <- gbifRetriever(searchTaxa[[i]])
        temp$OccurrenceTable <- GBIFtableCleanup(temp$OccurrenceTable)
        gbifResults[[i]] <- temp
      }
      setwd(currentWD)
    } else {
      for (i in searchTaxa) {
        temp <- getGBIFpoints(
          taxon = i,
          GBIFLogin = GBIFLogin,
          GBIFDownloadDirectory = GBIFDownloadDirectory,
          checkPreviousGBIFDownload = checkPreviousGBIFDownload
        )
        temp$OccurrenceTable <- GBIFtableCleanup(temp$OccurrenceTable)
        gbifResults[[i]] <- temp
      }
    }
  }

  # For BIEN
  if ("bien" %in% datasources) {
    bienResults <- vector(mode = "list", length = length(searchTaxa))
    names(bienResults) <- searchTaxa
    if ("bien" %in% datasources) {
      for (i in searchTaxa) {
        bienResults[[i]] <- getBIENpoints(taxon = i)
      }
    }
  } else {
    bienResults <- NULL
  }

  # Merge GBIF and BIEN results
  occSearchResults <- vector(mode = "list", length = length(searchTaxa))
  names(occSearchResults) <- searchTaxa
  for (i in searchTaxa) {
    if ("bien" %in% datasources && "gbif" %in% datasources) {
      bien <- bienResults[[i]]
      gbif <- gbifResults[[i]]
      occSearchResults[[i]] <- list(gbif, bien)
      names(occSearchResults[[i]]) <- c("GBIF", "BIEN")
    } else if ("bien" %in% datasources && length(datasources) == 1) {
      bien <- bienResults[[i]]
      occSearchResults[[i]] <- list(bien)
      names(occSearchResults[[i]]) <- c("BIEN")
    } else {
      gbif <- gbifResults[[i]]
      occSearchResults[[i]] <- list(gbif)
      names(occSearchResults[[i]]) <- c("GBIF")
    }
  }

  # Putting results into occCite object
  queryResults@occResults <- occSearchResults

  return(queryResults)
}
