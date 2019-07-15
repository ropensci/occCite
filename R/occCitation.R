library(rgbif)
library(stats)
library(BIEN)

#' @title Occurrence Citations
#'
#' @description Harvests citations for occurrence data
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
    GBIFdatasetKeys <- stats::na.omit(GBIFdatasetKeys);

  ##Look up citations on GBIF based on dataset keys and removes accession date (supplied date from rGBIF is date citation was sought, not the date the data was accessed)
    for(j in GBIFdatasetKeys){
      temp <- gsub(rgbif::gbif_citation(j)$citation$text, pattern = " accessed via GBIF.org on \\d+\\-\\d+\\-\\d+.", replacement = "", useBytes = T);
      GBIFCitationList <- append(GBIFCitationList,temp);
    }
  }

  #BIEN
  if ("bien" %in% x@occSources){
    ##Pull dataset keys from occurrence table
    BIENdatasetKeys <- vector(mode = "list");
    for(k in x@occResults){
      BIENdatasetKeys <- append(BIENdatasetKeys,unlist(as.character((k$BIEN$OccurrenceTable$DatasetKey))));
    }
    BIENdatasetCount <- as.data.frame(table(unlist(BIENdatasetKeys)));
    BIENdatasetKeys <- unique(unlist(BIENdatasetKeys));

    #Handle datasets without keys
    datasetKeyNAs <- sum(is.na(BIENdatasetKeys));
    BIENdatasetKeys <- BIENdatasetKeys[!is.na(BIENdatasetKeys)];
    if (datasetKeyNAs > 0){
      print(paste0("NOTE: ", datasetKeyNAs,
                  " BIEN dataset(s) do not have dataset keys to link citations. They are: ",
                  unique(i$BIEN$OccurrenceTable$Dataset[is.na(i$BIEN$OccurrenceTable$DatasetKey)])));
    }

    ##Get data sources
    query <- paste("WITH a AS (SELECT * FROM datasource where datasource_id in (",
      paste(shQuote(BIENdatasetKeys, type = "sh"),collapse = ', '),")) SELECT * FROM datasource where datasource_id in (SELECT datasource_id FROM a);");
    BIENsources <- BIEN:::.BIEN_sql(query);
  }

  #Columns: UUID, Citation, Access date, number of records
  if("gbif" %in% x@occSources){
    GBIFaccessDate <- strsplit(x@occResults[[1]]$GBIF$Metadata$modified,"T")[[1]][1]# Assumes that all species queries occurred at the same time, which may not necessarily be the case FIX LATER
    gbifTable <- data.frame(rep("GBIF", length(GBIFdatasetKeys)),
                            GBIFdatasetKeys, unlist(GBIFCitationList),
                            rep(GBIFaccessDate, length(GBIFdatasetKeys)),
                            GBIFDatasetCount[,2], stringsAsFactors = F);
  colnames(gbifTable) <- c("occSearch", "Dataset Key", "Citation", "Accession Date", "Number of Occurrences");
  }

  if("bien" %in% x@occSources){
    BIENcitations <- BIENsources$source_citation;
    # If there is no citation available, replace it with the full name of the primary provider
    for (i in 1:length(BIENcitations)){
      if (is.na(BIENcitations[i])){
        BIENcitations[i] <- BIENsources$source_fullname[i];
      }
    }
    bienTable <- data.frame(as.character(rep("BIEN", length(BIENdatasetKeys))), as.character(BIENdatasetKeys), as.character(BIENcitations), as.character(BIENsources$date_accessed), as.numeric(BIENdatasetCount[,2]), stringsAsFactors = F);
    colnames(bienTable) <- c("occSearch", "Dataset Key", "Citation", "Accession Date", "Number of Occurrences")
  }

  if("bien" %in% x@occSources && "gbif" %in% x@occSources){
    citationTable <- rbind(gbifTable,bienTable);
  }
  else if("bien" %in% x@occSources && length(x@occSources)==1){
    citationTable <- bienTable
    citationTable <- NULL;
  }
  else{
    citationTable <- gbifTable
  }

  return(citationTable);
}
