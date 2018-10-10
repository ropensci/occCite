library(rgbif)

#' @title Occurrence Citations
#'
#' @description Harvests citations from GBIF for occurrence data
#'
#' @param x An object of class \code{\link{occCiteData}}
#'
#' @return A dataframe with citations information for occurrences
#'
#' @examples
#'
#' \dontrun{
#' myCitations <- occCitation(x = myoccCiteObject);
#'}
#'
#' @export

occCitation <-function(x = NULL){
  #Error check input x.
  if (!class(x)=="occCiteData"){
    warning("Input x is not of class 'occCiteData'. Input x must be result of a studyTaxonList() search.\n");
    return(NULL);
  }

  #Initializing citation lists
  GBIFCitationList <- vector(mode = "list");
  GBIFDatasetCount <- NULL;
  #TempComm:BIENCitationList <- vector(mode = "list");
  #TempComm:BIENDatasetCount <- NULL;

  #GBIF
  if ("gbif" %in% x@occSources){
  ##Pull dataset keys from occurrence table
    datasetKeys <- vector(mode = "list");
    for(i in x@occResults){
      datasetKeys <- append(datasetKeys,
                            unlist(as.character(i$GBIF$OccurrenceTable$DatasetKey)));
    }
    GBIFDatasetCount <- as.data.frame(table(unlist(datasetKeys)));
    GBIFdatasetKeys <- unique(unlist(datasetKeys));

  ##Look up citations on GBIF based on dataset keys
    for(i in GBIFdatasetKeys){
      GBIFCitationList <- append(GBIFCitationList,
                             rgbif::gbif_citation(i)$citation$text);
    }
  }

  #BIEN
  #TempComm:if ("bien" %in% x@occSources){
    ##Pull dataset keys from occurrence table
  #TempComm:BIENdatasetKeys <- vector(mode = "list");
  #TempComm:for(i in x@occResults){
  #TempComm:BIENdatasetKeys <- append(BIENdatasetKeys,unlist(as.character((i$BIEN$OccurrenceTable$DatasetKey))));
  #TempComm:}
  #TempComm:BIENDatasetCount <- as.data.frame(table(unlist(BIENdatasetKeys)));
  #TempComm:BIENdatasetKeys <- unique(unlist(BIENdatasetKeys));

    #Handle datasets without keys
  #TempComm:datasetKeyNAs <- sum(is.na(BIENdatasetKeys));
  #TempComm:BIENdatasetKeys <- BIENdatasetKeys[!is.na(BIENdatasetKeys)];
  #TempComm:if (datasetKeyNAs > 0){
  #TempComm:print(paste("NOTE: ", datasetKeyNAs, " BIEN dataset(s) do not have dataset keys to link citations. They are: ", unique(i$BIEN$OccurrenceTable$Dataset[is.na(i$BIEN$OccurrenceTable$DatasetKey)]), sep = ""));
  #TempComm:}

    ##Get data sources
  #TempComm:query<-paste("WITH a AS (SELECT * FROM datasource where datasource_id in (",
  #TempComm:paste(shQuote(BIENdatasetKeys, type = "sh"),collapse = ', '),"))
  #TempComm:SELECT * FROM datasource where datasource_id in (SELECT datasource_id FROM a);");
  #TempComm:BIENsources <- BIEN:::.BIEN_sql(query);
  #TempComm:}

  #Columns: UUID, Citation, Access date, number of records
  if("gbif" %in% x@occSources){
    gbifTable <- data.frame(rep("GBIF", length(GBIFdatasetKeys)), GBIFdatasetKeys, unlist(GBIFCitationList), rep(x@occurrenceSearchDate, length(GBIFdatasetKeys)), GBIFDatasetCount[,2]);
  colnames(gbifTable) <- c("occSearch", "Dataset Key", "Citation", "Search Date", "Number of Occurrences");
  }

  #TempComm:if("bien" %in% x@occSources){
  #TempComm:bienTable <- data.frame(rep("BIEN", length(BIENdatasetKeys)), BIENdatasetKeys, BIENsources$source_citation, rep(x@occurrenceSearchDate, length(BIENdatasetKeys)), BIENDatasetCount[,2]);
  #TempComm:colnames(bienTable) <- c("occSearch", "Dataset Key", "Citation", "Search Date", "Number of Occurrences")
  #TempComm:}

  if("bien" %in% x@occSources && "gbif" %in% x@occSources){
    #TempComm:citationTable <- rbind(gbifTable,bienTable);
    citationTable <- gbifTable
    print("BIEN citation not yet supported, but is coming soon.")
  }
  else if("bien" %in% x@occSources && length(x@occSources)==1){
    #TempComm:citationTable <- bienTable
    citationTable <- NULL;
    print("BIEN citation not yet supported, but is coming soon.")
  }
  else{
    citationTable <- gbifTable
  }

  return(citationTable);
}
