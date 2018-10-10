library(taxize);

#' @title Taxon Rectification
#'
#' @description An internal helper function that takes an input taxonomic name, checks against taxonomic database, returns vector for use in database queries, as well as warnings if the name is invalid.
#'
#' @param taxName A string that, ideally, is a taxonomic name
#'
#' @param datasources A vector of taxonomic datasources implemented in \code{\link{gnr_resolve}}. See the \href{http://gni.globalnames.org/}{Global Names List} for more information.
#'
#' @return A string with the closeset match according to \code{\link{gnr_resolve}}, and a list of taxonomic datasources that contain the matching name.
#'
#' @examples
#' #Inputting a taxonomic name and specifying what taxonomic sources you want to search
#' studyTaxonList(x = "Buteo buteo hartedi", datasources = c('NCBI', 'EOL'));
#'
#' @export

taxonRectification <- function(taxName = NULL, datasources = NULL) {
  #Are user-input databases included in the list of data sources for Global Names Resolver?
  sourceList <- taxize::gnr_datasources(todf = T)$title #Populates the list of datasources
  if(!is.null(datasources)){
    for (db in datasources){
      notInDB <- character()
      if (!(db %in% sourceList)) {
        notInDB <- append(notInDB, db)
      }
    }
    if (length(notInDB) != 0){
      warning(paste("The following sources were not found in Global Names Index source list: ", paste(notInDB, collapse = ', '), sep=""));
    }
    #Remove invalid sources from datasources
    datasources <- datasources[!datasources %in% notInDB];
  }

  #Populating vector of data sources if no valid sources are supplied
  if (length(datasources) == 0){
    warning("No valid taxonomic data sources supplied. Populating default list from all available sources.");
    datasources = taxize::gnr_datasources(todf = T)$title;
  }


  #Resolving the user-input taxonomic names
  sources <- taxize::gnr_datasources();
  sourceIDs <- sources$id[sources$title %in% datasources]
  #Protects against an error thrown when giving gnr_resolve a complete list of data sources
  if (nrow(sources) == length(sourceIDs)){
    sourceIDs <- NULL;
  }
  bestNameMatch <- character();
  taxonomicDatabaseMatches <- vector("list");
  temp <- taxize::gnr_resolve(names = taxName, data_source_ids = sourceIDs);
  if (length(temp) == 0){
    bestNameMatch <- append(bestNameMatch, "No match");
    taxonomicDatabaseMatches <- append(taxonomicDatabaseMatches, NA);
    warning(paste(taxName, " is not found in any of the taxonomic data sources specified.", sep = ""));
  }
  else {
    bestMatch <- temp[order(temp$score),]$matched_name[1];
    bestNameMatch <- append(bestNameMatch, bestMatch);
    matchingSources <- temp$data_source_title[temp$matched_name == bestMatch];
    taxonomicDatabaseMatches[[length(bestNameMatch)]] <- paste(matchingSources, collapse = "; ");
  }

  #Building the results table
  resolvedNames <- data.frame(taxName, bestNameMatch, taxonomicDatabaseMatches);
  colnames(resolvedNames) <- c("Input Name", "Best Match", "Searched Taxonomic Databases w/ Matches");
  resolvedNames <- as.data.frame(resolvedNames);

  return(resolvedNames);
}
