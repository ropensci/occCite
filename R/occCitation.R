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
#' myCitations <- occCitation(x = myoccCiteObject);
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
  BIENCitationList <- vector(mode = "list");
  BIENDatasetCount <- NULL;

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
  if ("bien" %in% x@occSources){
    ##Pull dataset keys from occurrence table
    BIENdatasetKeys <- vector(mode = "list");
    for(i in x@occResults){
      BIENdatasetKeys <- append(BIENdatasetKeys,
                            unlist(as.character((i$BIEN$OccurrenceTable$datasource_id))));
    }
    BIENDatasetCount <- as.data.frame(table(unlist(BIENdatasetKeys)));
    BIENdatasetKeys <- unique(unlist(BIENdatasetKeys));

    ##Get data sources
    query<-paste("WITH a AS (SELECT * FROM datasource where datasource_id in (",
                 paste(shQuote(BIENdatasetKeys, type = "sh"),collapse = ', '),"))
                 SELECT * FROM datasource where datasource_id in (SELECT datasource_id FROM a);");
    BIENsources <- BIEN:::.BIEN_sql(query);
  }

  #Columns: UUID, Citation, Access date, number of records
  if("gbif" %in% x@occSources){
    gbifTable <- data.frame(rep("GBIF", length(GBIFdatasetKeys)), GBIFdatasetKeys, unlist(GBIFCitationList), rep(x@occurrenceSearchDate, length(GBIFdatasetKeys)), GBIFDatasetCount[,2]);
  colnames(gbifTable) <- c("occSearch", "Dataset Key", "Citation", "Search Date", "Number of Occurrences");
  }

  if("bien" %in% x@occSources){
    bienTable <- data.frame(rep("BIEN", length(BIENdatasetKeys)), BIENdatasetKeys, BIENsources$source_citation, rep(x@occurrenceSearchDate, length(BIENdatasetKeys)), BIENDatasetCount[,2]);
    colnames(bienTable) <- c("occSearch", "Dataset Key", "Citation", "Search Date", "Number of Occurrences")
  }

  if("bien" %in% x@occSources && "gbif" && x@occSources){
    citationTable <- rbind(gbifTable,bienTable);
  }
  else if("bien" %in% x@occSources){
    citationTable <- bienTable
  }
  else if("gbif" %in% x@occSources){
    citationTable <- gbifTable
  }

  return(citationTable);
}
