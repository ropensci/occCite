#' @title Taxon Rectification
#'
#' @description An function that takes an input taxonomic name, checks against
#' taxonomic database, returns vector for use in database queries, as well as
#' warnings if the name is invalid.
#'
#' @param taxName A string that, ideally, is a taxonomic name
#'
#' @param datasources A vector of taxonomic data sources implemented in
#' \code{taxize::gna_verifier()}. See the
#' \href{http://verifier.globalnames.org/data_sources}{Global Names Verifier} for more information.
#'
#' @param skipTaxize If \code{skipTaxize = TRUE}, occCite will skip taxonomic
#'  rectification using taxize. Setting this option to `TRUE` will result in a check for the
#'  \code{taxize} package before taxonomic rectification is attempted.
#'
#' @return A string with the closest match according to
#' \code{taxize::gna_verifier()}, and a list of taxonomic data sources that
#' contain the matching name.
#'
#' @examples
#' # Inputting taxonomic name and specifying what taxonomic sources to search
#' taxonRectification(
#'   taxName = "Buteo buteo hartedi",
#'   datasources = "National Center for Biotechnology Information",
#'   skipTaxize = TRUE
#' )
#' @export
#'

taxonRectification <- function(taxName = NULL, datasources = NULL,
                               skipTaxize = FALSE) {

  if (!is.logical(skipTaxize)) {
    warning(paste0(
      "You have not used a logical operator to\n",
      "specify whether occCite should skip taxize-\n",
      "based taxonomic rectification."
    ))
    return(NULL)
  }

  if(!skipTaxize){
    if(!requireNamespace("taxize", quietly = TRUE)){
      warning(paste0("Package taxize unavailable. Skipping taxonomic rectification."))
      skipTaxize <- TRUE
    }
  }

  if(skipTaxize){
    resolvedNames <- data.frame(taxName, taxName, "Not rectified.")
    colnames(resolvedNames) <- c(
      "Input Name",
      "Best Match",
      "Searched Taxonomic Databases w/ Matches"
    )
    resolvedNames <- as.data.frame(resolvedNames)
    return(resolvedNames)
  }
  else{
    # Checks for source connectivity
    if(requireNamespace("taxize")){
      tryCatch(
        expr = sources <- taxize::gna_data_sources(),
        error = function(e) {
          message(paste("GNA server unreachable; please try again later. \n"))
        }
      )}

    if (!exists("sources")) {
      return(invisible(NULL))
    }

    # Are user-input databases included in data sources for Global Names Architecture?
    if (!is.null(datasources)) {
      for (db in datasources) {
        notInDB <- character()
        if (!(db %in% sources$title)) {
          notInDB <- append(notInDB, db)
        }
      }
      if (length(notInDB) != 0) {
        warning(paste0(
          "Following sources not found in\n",
          "Global Names Index source list: ",
          paste(notInDB, collapse = ", ")
        ))
      }
      # Remove invalid sources from datasources
      datasources <- datasources[!datasources %in% notInDB]
    }

    # Populating vector of data sources if no valid sources are supplied
    if (length(datasources) == 0) {
      warning(paste0(
        "No valid taxonomic data sources supplied.\n",
        "Populating default list from all available sources."
      ))
      datasources <- sources$title
    }

    # Resolving the user-input taxonomic names
    sourceIDs <- sources$id[sources$title %in% datasources]
    taxonomicDatabaseMatches <- vector("list")
    if(requireNamespace("taxize")){
      temp <- taxize::gna_verifier(names = taxName, data_sources = sourceIDs, all_matches = F)
    }
    if (is.na(temp$matchedName)) {
      bestMatch <- "No match"
      taxonomicDatabaseMatches <- "No match"
      warning(paste(taxName,
                    " is not found in any of the taxonomic data sources specified.",
                    sep = ""
      ))
    } else {
      bestMatch <- temp[order(temp$sortScore), ]$matchedName[1]
      matchingSources <- temp$dataSourceTitleShort[temp$matchedName == bestMatch]
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
}
