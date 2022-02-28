#' @title Taxon Rectification
#'
#' @description An function that takes an input taxonomic name, checks against
#' taxonomic database, returns vector for use in database queries, as well as
#' warnings if the name is invalid.
#'
#' @param taxName A string that, ideally, is a taxonomic name
#'
#' @param datasources A vector of taxonomic data sources implemented in
#' \code{\link{gnr_resolve}}. See the
#' \href{http://gni.globalnames.org/}{Global Names List} for more information.
#'
#' @return A string with the closest match according to
#' \code{\link{gnr_resolve}}, and a list of taxonomic data sources that contain
#' the matching name.
#'
#' @examples
#' # Inputting taxonomic name and specifying what taxonomic sources to search
#' taxonRectification(
#'   taxName = "Buteo buteo hartedi",
#'   datasources = "National Center for Biotechnology Information"
#' )
#' @export
#'
taxonRectification <- function(taxName = NULL, datasources = NULL) {

  # Checks for source connectivity
  tryCatch(expr = sources <- taxize::gnr_datasources(),
    error = function(e) {
      message(paste("GNR server unreachable; please try again later. \n"))
    })

  if(!exists("sources")){
    return(invisible(NULL))
  }

  # Are user-input databases included in data sources for Global Names Resolver?
  if (!is.null(datasources)) {
    for (db in datasources) {
      notInDB <- character()
      if (!(db %in% sources$title)) {
        notInDB <- append(notInDB, db)
      }
    }
    if (length(notInDB) != 0) {
      warning(paste0("Following sources not found in\n",
                     "Global Names Index source list: ",
                     paste(notInDB, collapse = ", ")
      ))
    }
    # Remove invalid sources from datasources
    datasources <- datasources[!datasources %in% notInDB]
  }

  # Populating vector of data sources if no valid sources are supplied
  if (length(datasources) == 0) {
    warning(paste0("No valid taxonomic data sources supplied.\n",
                   "Populating default list from all available sources."))
    datasources <- sources$title
  }

  # Resolving the user-input taxonomic names
  sourceIDs <- sources$id[sources$title %in% datasources]
  # Protects against error thrown when giving gnr_resolve a complete list of data sources
  if (nrow(sources) == length(sourceIDs)) {
    sourceIDs <- NULL
  }
  taxonomicDatabaseMatches <- vector("list")
  temp <- taxize::gnr_resolve(sci = taxName, data_source_ids = sourceIDs)
  if (nrow(temp) == 0) {
    bestMatch <- "No match"
    taxonomicDatabaseMatches <- "No match"
    warning(paste(taxName,
      " is not found in any of the taxonomic data sources specified.",
      sep = ""
    ))
  }
  else {
    bestMatch <- temp[order(temp$score), ]$matched_name[1]
    matchingSources <- temp$data_source_title[temp$matched_name == bestMatch]
    taxonomicDatabaseMatches <- paste(matchingSources, collapse = "; ")
  }

  # Building the results table
  resolvedNames <- data.frame(taxName, bestMatch, taxonomicDatabaseMatches)
  colnames(resolvedNames) <- c(
    "Input Name",
    "Best Match",
    "Searched Taxonomic Databases w/ Matches"
  )
  resolvedNames <- as.data.frame(resolvedNames)

  return(resolvedNames)
}
