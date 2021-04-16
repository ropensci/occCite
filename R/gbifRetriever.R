#' @title Retrieve downloaded GBIF data sets
#'
#' @description Searches for the most recent instance of a data set
#'  that has been previously downloaded from GBIF to a local machine
#'  and imports it into `occCite`. This is designed to be an internal
#'  function. It is usable on its own, but you must have already
#'  navigated to the folder that contains the download zip files
#'  from GBIF.
#'
#' @param taxon A single species
#'
#' @return A list of lists containing (1) a data frame of occurrence
#' data; (2) GBIF search metadata for every GBIF download in the
#' specified directory. (3) the raw occurrence data from GBIF.
#'
#' @keywords internal
#' @noRd

gbifRetriever <- function (taxon = NULL){
  #Error checking
  cleanTaxon <- stringr::str_extract(string = taxon,
                                     pattern = "(\\w+\\s\\w+)") # Remove problem characters, i.e. "æ"

  taxon_key <- as.numeric(rgbif::name_suggest(q= cleanTaxon,
                                              fields = "key",
                                              rank = "species")$data[1])
  if(is.null(taxon_key)){
    warning(paste0(" Taxon ", taxon," could not be resolved."))
    return(NULL)
  }

  paths <- list.files(getwd(), pattern = "\\d{7}-\\d{15}.zip", recursive = T, full.names = T)
  keys <- as.vector(stringr::str_match(paths, pattern = "\\d{7}-\\d{15}"))
  paths <- stringr::str_remove(paths, pattern = "\\d{7}-\\d{15}.zip")

  #Sort through downloads to find taxon matches
  matchIndex <- NULL
  matchDate <- NULL
  for (i in 1:length(keys)){
    metadata <- rgbif::occ_download_meta(key = keys[[i]])
    if (metadata$totalRecords > 0){
      if(!is.na(match(table = unlist(metadata$request), "TAXON_KEY")) &
         taxon_key %in% unlist(metadata$request)){
        matchIndex <- append(matchIndex, i)
        matchDate <- append(matchDate, metadata$modified)
      }
    }
  }
  if(length(matchIndex) == 0){
    print(paste0("There are no local drive downloads for ",
                 taxon, "in ", getwd(), "."))
    dataService <- "GBIF"
    occFromGBIF <- c(rep(NA,9), dataService)
    names(occFromGBIF) <- c("gbifID", "name", "longitude",
                            "latitude", "day", "month",
                            "year", "Dataset",
                            "DatasetKey", "DataService")
    occFromGBIF <- t(data.frame(occFromGBIF, stringsAsFactors = F))
    row.names(occFromGBIF) <- NULL
    occFromGBIF <- data.frame(occFromGBIF)

    outlist <- list()
    outlist[[1]]<- occFromGBIF
    outlist[[2]]<-paste0("There are no local drive downloads for ",
                         taxon, "in ", getwd(), ".")
    outlist[[3]]<-NA
    names(outlist) <- c("OccurrenceTable", "Metadata", "RawOccurrences")
    return(outlist)
  }
  else{
    #Gets the downloaded data for the most recent match and returns it
    newestTaxonomicMatch <- matchIndex[order(matchDate,
                                             decreasing = T)][1]
    res <- rgbif::as.download(paths[[newestTaxonomicMatch]],
                              key = keys[[newestTaxonomicMatch]])
    rawOccs <- res
    occFromGBIF <- tabGBIF(res, taxon = taxon)
    occMetadata <- rgbif::occ_download_meta(keys[[newestTaxonomicMatch]])

    #Preparing list for return
    outlist<-list()
    outlist[[1]]<-occFromGBIF
    outlist[[2]]<-occMetadata
    outlist[[3]]<-rawOccs
    names(outlist) <- c("OccurrenceTable", "Metadata", "RawOccurrences")

    return(outlist)
  }
}
