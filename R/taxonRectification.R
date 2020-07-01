#' @title Taxon Rectification
#'
#' @description An function that takes an input taxonomic name, checks against
#' taxonomic database, returns vector for use in database queries, as well as
#' warnings if the name is invalid.
#'
#' @param taxName A string that, ideally, is a taxonomic name
#'
#' @param datasources A vector of taxonomic datasources implemented in
#' \code{\link{gnr_resolve}}. See the
#' \href{http://gni.globalnames.org/}{Global Names List} for more information.
#'
#' @return A string with the closeset match according to
#' \code{\link{gnr_resolve}}, and a list of taxonomic datasources that contain
#' the matching name.
#'
#' @examples
#' #Inputting a taxonomic name and specifying what taxonomic sources you want to search
#' taxonRectification(taxName = "Buteo buteo hartedi", datasources = 'NCBI');
#'
#' @export
taxonRectification <- function(taxName = NULL, datasources = NULL) {
  sources <- taxize::gnr_datasources();#Populates the list of datasources
  #Are user-input databases included in the list of data sources for Global Names Resolver?
  if(!is.null(datasources)){
    for (db in datasources){
      notInDB <- character()
      if (!(db %in% sources$title)) {
        notInDB <- append(notInDB, db)
      }
    }
    if (length(notInDB) != 0){
      warning(paste("The following sources were not found in Global Names Index source list: ",
                    paste(notInDB, collapse = ', '), sep=""));
    }
    #Remove invalid sources from datasources
    datasources <- datasources[!datasources %in% notInDB];
  }

  #Populating vector of data sources if no valid sources are supplied
  if (length(datasources) == 0){
    warning("No valid taxonomic data sources supplied. Populating default list from all available sources.");
    datasources <- sources$title;
  }

  #Resolving the user-input taxonomic names
  sourceIDs <- sources$id[sources$title %in% datasources]
  #Protects against an error thrown when giving gnr_resolve a complete list of data sources
  if (nrow(sources) == length(sourceIDs)){
    sourceIDs <- NULL;
  }
  taxonomicDatabaseMatches <- vector("list");
  temp <- taxize::gnr_resolve(sci = taxName, data_source_ids = sourceIDs);
  if (length(temp) == 0){
    bestNameMatch <- "No match"
    taxonomicDatabaseMatches <- taxonomicDatabaseMatches
    warning(paste(taxName, " is not found in any of the taxonomic data sources specified.", sep = ""));
  }
  else {
    bestMatch <- temp[order(temp$score),]$matched_name[1]
    matchingSources <- temp$data_source_title[temp$matched_name == bestMatch]
    taxonomicDatabaseMatches <- paste(matchingSources, collapse = "; ")
  }

  #Building the results table
  resolvedNames <- data.frame(taxName, bestMatch, taxonomicDatabaseMatches);
  colnames(resolvedNames) <- c("Input Name", "Best Match", "Searched Taxonomic Databases w/ Matches");
  resolvedNames <- as.data.frame(resolvedNames);

  return(resolvedNames);
}
