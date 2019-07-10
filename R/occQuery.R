#' @title Query from Taxon List
#'
#' @description Takes rectified list of specimens from \code{\link{studyTaxonList}} and returns point data from \code{\link{rgbif}} with metadata.
#'
#' @param x An object of class \code{\link{occCiteData}} (the results of a \code{\link{studyTaxonList}} search) OR a vector with a list of species names. Note: If the latter, taxonomic rectfication uses EOL and NCBI taxonomies. If you want more control than this, use \code{\link{studyTaxonList}} to create a \code{\link{occCiteData}} object first.
#'
#' @param datasources A vector of occurrence datasources to search. This is currently limited to GBIF and BIEN, but may expand in the future.
#'
#' @param GBIFLogin An object of class \code{\link{GBIFLogin}} to log in to GBIF to begin the download.
#'
#' @param GBIFDownloadDirectory An optional argument that specifies the local directory where GBIF downloads will be saved. If this is not specified, the downloads will be saved to your current working directory.
#'
#' @param loadLocalGBIFDownload If \code{loadLocalGBIFDownload = T}, then occCite will load occurrences for the specified species that have been downloaded by the user and stored in the directory specified by \code{GBIFDownloadDirectory}.
#'
#' @param checkPreviousGBIFDownload If \code{loadLocalGBIFDownload = T}, occCite will check for previously-prepared GBIF downloads on the user's GBIF account.
#'
#' @param options A vector of options to pass to \code{\link{occ_download}}.
#'
#' @return The object of class \code{\link{occCiteData}} supplied by the user as an argument, with occurrence data search results, as well as metadata on the occurrence sources queried.
#'
#' @examples
#' \dontrun{
#' ##If you have already created a occCite object, and have not previously downloaded GBIF data.
#' occQuery(x = myBridgeTreeObject,
#'          datasources = c("gbif", "bien"),
#'          GBIFLogin = myLogin,
#'          GBIFDownloadDirectory = "./Desktop"
#'          loadLocalGBIFDownload = F);
#'
#' ## If you don't have a occCite object yet
#' occQuery(x = c("Buteo buteo", "Protea cynaroides"),
#'          datasources = c("gbif", "bien"),
#'          GBIFLogin = myLogin,
#'          GBIFOverwrite = T,
#'          GBIFDownloadDirectory = "./Desktop"
#'          loadLocalGBIFDownload = F);
#'
#' ## If you have previously downloaded occurrence data from GBIF
#' ## and saved it in a folder called "GBIFDownloads".
#' occQuery(x = c("Buteo buteo", "Protea cynaroides"),
#'          datasources = c("gbif", "bien"),
#'          GBIFLogin = myLogin,
#'          GBIFoverwrite = T,
#'          GBIFDownloadDirectory = "./Desktop/GBIFDownloads"
#'          loadLocalGBIFDownload = T);
#'}
#'
#' @export

occQuery <- function(x = NULL,
                     datasources = c("gbif", "bien"),
                     GBIFLogin = NULL,
                     GBIFDownloadDirectory = NULL,
                     loadLocalGBIFDownload = F,
                     checkPreviousGBIFDownload =T,
                     options = NULL) {
  #Error check input x.
  if (!class(x)=="occCiteData" && !is.vector(x)){
    warning("Input x is not of class 'occCiteData', nor is it a vector. Input x must be result of a studyTaxonList() search OR a vector with a list of taxon names.\n");
    return(NULL);
  }

  #Instantiate a occCite data object if one was not supplied
  if(class(x) != "occCiteData"){
    x <- studyTaxonList(x);
  }

  #Error check input datasources.
  if (!is.vector(datasources) && class(datasources)=="character"){
    warning("Input datasources is not of class 'vector'. Datasources object must be a vector of class 'character'.\n");
    return(NULL);
  }

  #Error check input GBIF directory.
  if ("gbif" %in% datasources && !is.null(GBIFDownloadDirectory) && class(GBIFDownloadDirectory) != "character"){
    warning("Input GBIFDownload directory is not of class 'character'.\n");
    return(NULL);
  }

  if(is.null(GBIFDownloadDirectory)){
    GBIFDownloadDirectory <- getwd();
  }

  if(!file.exists(GBIFDownloadDirectory)){
    warning("You have specified a non-existant location for your GBIF data downloads.\n");
    return(NULL);
  }

  if(!is.logical(loadLocalGBIFDownload)){
    warning(paste("You have not used a logical operator to specify whether occCite should pull already-downloaded occurrences from ", GBIFDownloadDirectory, ".", sep = ""));
    return(NULL);
  }

  if(!is.logical(checkPreviousGBIFDownload)){
    warning(paste("You have not used a logical operator to specify whether occCite should check GBIF for previously-prepared downloads for the taxa specified."));
    return(NULL);
  }

  #Check to see if the sources input are actually ones used by occQuery
  sources <- c("gbif", "bien"); #sources
  if(sum(!datasources %in% sources) > 0){
    warning(paste("The following datasources are not implemented in occQuery(): ", datasources[!datasources %in% sources], sep = ""));
    return(NULL);
  }
  else if(is.null(datasources)){#Fills in NULL
    x@occSources <- sources;
  }
  else{
    x@occSources <- datasources;
  }

  #If GBIF was selected, check to see if GBIF login information is supplied.
  if ("gbif" %in% datasources && !class(GBIFLogin) == "GBIFLogin" && !loadLocalGBIFDownload){
    warning("You have chosen GBIF as a datasource, but have not supplied GBIF login information. Please create a GBIFLogin object using GBIFLoginManager().\n");
    return(NULL);
  }

  #Get time stamp for search
  x@occurrenceSearchDate <- as.character(Sys.Date(), format = "%d %B, %Y");

  #Occurrence queries for each species
  queryResults <- x;
  searchTaxa <- as.character(queryResults@cleanedTaxonomy$`Best Match`);

  #For GBIF
  if ("gbif" %in% datasources){
    gbifResults <- vector(mode = "list", length = length(searchTaxa));
    names(gbifResults) <- searchTaxa;
    if(loadLocalGBIFDownload){
        temp <- gbifRetriever(GBIFDownloadDirectory);
        for(i in 1:length(searchTaxa)){
          #Gets *all* downloaded records
          temp2 <- temp[which(searchTaxa[[i]] == names(temp))]
          numMatch <- length(unlist(regmatches(names(temp), gregexpr(searchTaxa[[i]], names(temp)))))
          #Then parses them into the appropriate slot
          if(numMatch > 1){
            #Pulls the *most recent* record
            #and assigns it to gbifResults
            temp3<- temp2[unlist(lapply(lapply(temp2, '[[', 2), '[[', 6)) == max(unlist(lapply(lapply(temp2, '[[', 2), '[[', 6)))]
            gbifResults[[i]] <- list(temp3[[1]]$OccurrenceTable, temp3[[1]]$Metadata);
            names(gbifResults[[i]]) <- c("OccurrenceTable", "Metadata");
          }
          else{
            temp3 <- temp2[[1]];
            gbifResults[[i]] <- list(temp3[[1]]$OccurrenceTable, temp3[[1]]$Metadata);
            names(gbifResults[[i]]) <- c("OccurrenceTable", "Metadata");
          }
        }
      }
    else{
        for (i in searchTaxa){
          temp <- getGBIFpoints(taxon = i,
                                GBIFLogin = GBIFLogin,
                                GBIFDownloadDirectory = GBIFDownloadDirectory);
          gbifResults[[i]] <- temp;
        }
      }
  }

  #For BIEN
  if ("bien" %in% datasources){
    bienResults <- vector(mode = "list", length = length(searchTaxa));
    names(bienResults) <- searchTaxa;
    if("bien" %in% datasources){
      for (i in searchTaxa){
        temp <- getBIENpoints(taxon = i);
        bienResults[[i]] <- temp;
      }
    }
  }
  else{
    bienResults <- NULL;
  }

  #Merge GBIF and BIEN results
  occSearchResults <- vector(mode = "list", length = length(searchTaxa));
  names(occSearchResults) <- searchTaxa;
  for (i in searchTaxa){
    if ("bien" %in% datasources && "gbif" %in% datasources){
      bien <- bienResults[[i]];
      gbif <- gbifResults[[i]];
      occSearchResults[[i]] <- list(gbif, bien);
      names(occSearchResults[[i]]) <- c("GBIF", "BIEN");
    }
    else if("bien" %in% datasources && length(datasources)==1){
      bien <- bienResults[[i]];
      occSearchResults[[i]] <- list(bien);
      names(occSearchResults[[i]]) <- c("BIEN");
    }
    else {
      gbif <- gbifResults[[i]]
      occSearchResults[[i]] <- list(gbif);
      names(occSearchResults[[i]]) <- c("GBIF");
    }
  }

  #Putting results into occCite object
  queryResults@occResults <- occSearchResults;

  return(queryResults);
}
