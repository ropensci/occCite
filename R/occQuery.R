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
#' @param GBIFOverwrite FEATURE IN DEVELOPMENT. Eventually, if false, retrieves previously-downloaded data from the GBIFDownloadDirectory specified (note that directory names must match species names for this to work).
#'
#' @param limit An optional argument that limits the number of records from EACH data aggregator returned to n. Note: This will return the FIRST n records, and will likely be a very biased sample.
#'
#' @param options A vector of options to pass to \code{\link{occ_download}}.
#'
#' @return The object of class \code{\link{occCiteData}} supplied by the user as an argument, with occurrence data search results, as well as metadata on the occurrence sources queried.
#'
#' @examples
#' ## If you have already created a occCite object
#' \dontrun{
#' occQuery(x = myBridgeTreeObject,
#'          datasources = c("gbif", "bien"),
#'          GBIFLogin = myLogin,
#'          limit = NULL,
#'          GBIFOverwrite = T,
#'          GBIFDownloadDirectory = "./Desktop");
#'}
#'
#'\dontrun{
#' ## If you don't have a occCite object yet
#' occQuery(x = c("Buteo buteo", "Protea cynaroides"),
#'          datasources = c("gbif", "bien"),
#'          GBIFLogin = myLogin,
#'          limit = NULL,
#'          GBIFOverwrite = T,
#'          GBIFDownloadDirectory = "./Desktop");
#'}
#'
#' @export

occQuery <- function(x = NULL, datasources = c("gbif", "bien"), GBIFLogin = NULL, GBIFDownloadDirectory = NULL, limit = NULL, GBIFOverwrite = T, options = NULL) {
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

  #Error check input datasources.
  if (!is.numeric(limit) && !is.null(limit)){
    warning("Input limit is not numeric.\n");
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
  if ("gbif" %in% datasources && !class(GBIFLogin)=="GBIFLogin"){
    warning("You have chosen GBIF as a datasource, but have not supplied GBIF login information. Please create a GBIFLogin object using GBIFLoginManager().\n");
    return(NULL);
  }

  #Get time stamp for search
  x@occurrenceSearchDate <- as.character(Sys.Date(), format = "%d %B, %Y");

  #Occurrence queries for each species
  queryResults <- x;
  searchTaxa <- as.character(queryResults@cleanedTaxonomy$`Best Match`);

  #For GBIF
  gbifResults <- NULL;
  if ("gbif" %in% datasources){
    gbifResults <- vector(mode = "list", length = length(searchTaxa));
    names(gbifResults) <- searchTaxa;
    if("gbif" %in% datasources){
      for (i in searchTaxa){
        temp <- getGBIFpoints(taxon = i, GBIFLogin = GBIFLogin,
                              GBIFDownloadDirectory = GBIFDownloadDirectory, limit = limit);
        gbifResults[[i]] <- temp;
      }
    }
    if (is.null(limit)){
      limit = "No limit"
    }
  }

  #For BIEN
  bienResults <- NULL;
  if ("bien" %in% datasources){
    bienResults <- vector(mode = "list", length = length(searchTaxa));
    names(bienResults) <- searchTaxa;
    if("bien" %in% datasources){
      for (i in searchTaxa){
        temp <- getBIENpoints(taxon = i, limit = limit);
        bienResults[[i]] <- temp;
      }
    }
  }

  #Merge GBIF and BIEN results
  occSearchResults <- vector(mode = "list", length = length(searchTaxa));
  for (i in searchTaxa){
    if ("bien" %in% datasources && "gbif" %in% datasources){
      bien <- bienResults[[i]];
      gbif <- gbifResults[[i]]
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
  queryResults@occNLimit <- limit;

  return(queryResults);
}
