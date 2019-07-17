library(rgbif);
library(stringr);

#' @title Retreive downloaded GBIF datasets
#'
#' @description Searches for the most recent instance of a dataset that has been previously downloaded from GBIF to a local machine and imports it into occCite
#'
#' @param GBIFDownloadDirectory An optional argument that specifies either the local directory where the user would like to save new GBIF datasets, or the directory containing previously-downloaded GBIF datasets. If this is not specified, occCite will use your current working directory.
#'
#' @param taxon A single species
#'
#' @return A list of lists containing (1) a dataframe of occurrence data; (2) GBIF search metadata for every GBIF download in the specified directory.
#'
#' @examples
#' \dontrun{
#' gbifRetriever(GBIFDownloadDirectory = NULL);
#'}
#'
#' @export

gbifRetriever <- function (GBIFDownloadDirectory = NULL, taxon = NULL){
  #Error checking
  taxon_key <- rgbif::name_suggest(q= taxon)$key[1]
  if(is.null(taxon_key)){
    warning(paste(" Taxon",taxon," could not be resolved."))
    return(NULL)
  }

  startWD <- getwd();
  if(is.null(GBIFDownloadDirectory)){
    GBIFDownloadDirectory <- startWD;
  }
  if (!dir.exists(GBIFDownloadDirectory)){
    warning(paste("Input directory, '", GBIFDownloadDirectory, "', does not exist. Your current working directory is being searched instead.", sep = ""));
    GBIFDownloadDirectory <- startWD;
  }

  #Get all GBIF downloads in specified directory
  if (!stringr::str_sub(GBIFDownloadDirectory, -1) == "/"){
    GBIFDownloadDirectory <- paste0(GBIFDownloadDirectory, "/")
  }
  try(setwd(GBIFDownloadDirectory));
  paths <- list.files(GBIFDownloadDirectory, pattern = "\\d{7}-\\d{15}.zip", recursive = T);
  keys <- as.vector(stringr::str_match(paths, pattern = "\\d{7}-\\d{15}"));
  paths <- stringr::str_remove(paths, pattern = "\\d{7}-\\d{15}.zip")

  #Sort through downloads to find taxon matches
  matchIndex <- NULL;
  matchDate <- NULL;
  for (i in 1:length(paths)){
    if(paths[[i]]!=""){
      setwd(paste0(GBIFDownloadDirectory, paths[[i]]))
    }
    metadata <- rgbif::occ_download_meta(key = keys[[i]]);
    if (metadata$totalRecords > 0){
      for(j in 1:length(metadata$request$predicate$predicates)){
        if(metadata$request$predicate$predicates[[j]]$key=="TAXON_KEY" &
         metadata$request$predicate$predicates[[j]]$value==taxon_key){
          matchIndex <- append(matchIndex, i);
          matchDate <- append(matchDate, metadata$modified);
        }
      }
    }
  }
  if(length(matchIndex) == 0){
    print(paste0("There are no local drive downloads for ", taxon, "in ", GBIFDownloadDirectory, "."));
    setwd(startWD)
    return(NULL);
  }
  else{
    #Gets the downloaded data for the most recent match and returns it
    newestTaxonomicMatch <- matchIndex[order(matchDate,
                                             decreasing = T)][1]
    setwd(paste0(GBIFDownloadDirectory, paths[[newestTaxonomicMatch]]))
    res <- rgbif::as.download(key = keys[[newestTaxonomicMatch]]);
    rawOccs <- res;
    occFromGBIF <- tabGBIF(res, taxon = taxon);
    occMetadata <- rgbif::occ_download_meta(keys[[newestTaxonomicMatch]]);

    #Reset working directory to starting state.
    setwd(startWD)

    #Preparing list for return
    outlist<-list();
    outlist[[1]]<-occFromGBIF;
    outlist[[2]]<-occMetadata;
    outlist[[3]]<-rawOccs;
    names(outlist) <- c("OccurrenceTable", "Metadata", "RawOccurrences");

    return(outlist)
  }
}
