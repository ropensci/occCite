library(rgbif);
library(stringr);

#' @title Retreive downloaded GBIF datasets
#'
#' @description Imports datasets downloaded from GBIF into occCite
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
  startWD <- getwd();
  if(is.null(GBIFDownloadDirectory)){
    GBIFDownloadDirectory <- startWD;
  }
  if (!dir.exists(GBIFDownloadDirectory)){
    warning(paste("Input directory, '", GBIFDownloadDirectory, "', does not exist. Your current working directory is being searched instead.", sep = ""));
    GBIFDownloadDirectory <- startWD;
  }

  #Get all GBIF downloads in specified directory
  try(setwd(GBIFDownloadDirectory));
  paths <- list.files(GBIFDownloadDirectory, pattern = "\\d{7}-\\d{15}.zip", recursive = T);
  keys <- as.vector(stringr::str_match(paths, pattern = "\\d{7}-\\d{15}"));
  paths <- stringr::str_remove(paths, pattern = "\\d{7}-\\d{15}.zip");

  gbifDownloads <- vector("list", length = length(paths));
  for (i in 1:length(paths)){
    setwd(paths[[i]])
    occs <- tabGBIF(rgbif::as.download(key = keys[[i]]), taxon = taxon);
    metadata <- rgbif::occ_download_meta(key = keys[[i]]);
    gbifDownloads[[i]] <- list(occs, metadata);
    names(gbifDownloads[[i]]) <- c("OccurrenceTable", "Metadata");
    setwd(GBIFDownloadDirectory);
  }

  names(gbifDownloads) <- as.character(unlist(lapply(lapply(gbifDownloads, `[[`, 1), function(x) x[1,2])));

  #Reset working directory to starting state.
  setwd(startWD)

  return(gbifDownloads)
}
