#' @title Occurrence Citations
#'
#' @description Harvests citations for occurrence data
#'
#' @param x An object of class \code{\link{occCiteData}}
#'
#' @return An object of class \code{\link{occCiteCitation}}. It is
#' a named list of the same length as the number of species
#' included in your \code{\link{occCiteData}} object. Each item
#' in the list has citation information for occurrences.
#'
#' @importFrom stats na.omit
#' @import RPostgreSQL
#'
#' @examples
#' \donttest{
#' data(myOccCiteObject)
#' myCitations <- occCitation(x = myOccCiteObject)
#' }
#' @export

occCitation <-function(x = NULL){
  #Error check input x.
  if (!class(x)=="occCiteData"){
    warning("Input x is not of class 'occCiteData'. Input x must be result of a studyTaxonList() search.\n")
    return(NULL)
  }

  citationTables <- list()

  for(sp in names(x@occResults)) {
    #Initializing citation lists
    GBIFCitationList <- vector(mode = "list")
    GBIFDatasetCount <- NULL
    BIENCitationList <- vector(mode = "list")
    BIENDatasetCount <- NULL

    occResults <- x@occResults[[sp]]

    #GBIF
    if(!is.null(occResults$GBIF)){
      ##Pull dataset keys from occurrence table
      datasetKeys <- unlist(as.character(occResults$GBIF$OccurrenceTable$DatasetKey))
      GBIFDatasetCount <- as.data.frame(table(unlist(datasetKeys)))
      GBIFdatasetKeys <- unique(unlist(datasetKeys))
      GBIFdatasetKeys <- stats::na.omit(GBIFdatasetKeys)
      ##Look up citations on GBIF based on dataset keys and removes accession date (supplied date from rgbif is date citation was sought, not the date the data was accessed)
      for(j in GBIFdatasetKeys){
        temp <- gsub(rgbif::gbif_citation(j)$citation$text,
                     pattern = " accessed via GBIF.org on \\d+\\-\\d+\\-\\d+.", replacement = "",
                     useBytes = T)
        temp <- gsub(temp, pattern = "Occurrence dataset ", replacement = "")
        temp <- paste0(temp, ".")
        GBIFCitationList <- append(GBIFCitationList,temp)
      }
    }

    #BIEN
    if (!is.null(occResults$BIEN)){
      ##Pull dataset keys from occurrence table
      BIENdatasetKeys <- vector(mode = "list")
      BIENKeysNAs <- vector(mode = "list")
      if (anyNA(occResults$BIEN$OccurrenceTable$DatasetKey)){
        BIENKeysNAs <- occResults$BIEN$OccurrenceTable$Dataset[is.na(occResults$BIEN$OccurrenceTable$DatasetKey)]
        BIENKeysNAs <- unique(BIENKeysNAs)
      }
      BIENdatasetKeys <- append(BIENdatasetKeys,unlist(as.character((occResults$BIEN$OccurrenceTable$DatasetKey))))
      BIENdatasetKeys <- BIENdatasetKeys[!is.na(BIENdatasetKeys)]

      BIENdatasetCount <- as.data.frame(table(unlist(BIENdatasetKeys)))
      BIENdatasetKeys <- unique(unlist(BIENdatasetKeys))

      #Handle datasets without keys
      if (length(BIENKeysNAs) > 0){
        print(paste0("NOTE: ", length(BIENKeysNAs),
                     " BIEN dataset(s) for ", sp, " do not have dataset keys to link citations. They are: ",
                     paste(as.character(unlist(BIENKeysNAs)), collapse = ", ")))
      }

      ##Get data sources
      query <- paste("WITH a AS (SELECT * FROM datasource where datasource_id in (",
                     paste(shQuote(BIENdatasetKeys, type = "sh"),
                           collapse = ', '),")) SELECT * FROM datasource where datasource_id in (SELECT datasource_id FROM a);")

      host='vegbiendev.nceas.ucsb.edu'
      dbname='public_vegbien'
      user='public_bien'
      password='bien_public'
      # Name the database type that will be used
      drv <- DBI::dbDriver('PostgreSQL')
      # establish connection with database
      con <- DBI::dbConnect(drv, host=host, dbname=dbname, user=user, password = password)


      BIENsources <- DBI::dbGetQuery(con, statement = query);

      DBI::dbDisconnect(con)

      #bien sql replacement

    }

    #Columns: UUID, Citation, Access date, number of records
    if(!is.null(occResults$GBIF)){
      GBIFaccessDate <- strsplit(occResults$GBIF$Metadata$modified,"T")[[1]][1]# Assumes that all species queries occurred at the same time, which may not necessarily be the case FIX LATER
      gbifTable <- data.frame(rep("GBIF", length(GBIFdatasetKeys)),
                              GBIFdatasetKeys, unlist(GBIFCitationList),
                              rep(GBIFaccessDate, length(GBIFdatasetKeys)),
                              GBIFDatasetCount[,2], stringsAsFactors = F)
      colnames(gbifTable) <- c("occSearch", "Dataset Key", "Citation", "Accession Date", "Number of Occurrences");
    }

    if(!is.null(occResults$BIEN)){
      BIENcitations <- BIENsources$source_citation
      # If there is no citation available, replace it with the full name of the primary provider
      for (i in 1:length(BIENcitations)){
        if (is.na(BIENcitations[i])){
          BIENcitations[i] <- BIENsources$source_fullname[i]
        }
      }
      # Failing that, replace it with the shortened name of the primary provider
      for (i in 1:length(BIENcitations)){
        if (is.na(BIENcitations[i])){
          BIENcitations[i] <- BIENsources$source_name[i]
        }
      }
      # Replacing NA values for doi with "" for formatting purposes
      for (i in 1:length(BIENsources$doi)){
        if (is.na(BIENsources$doi[i])){
          BIENsources$doi[i] <- ""
        }
      }
      BIENcitations <- paste(as.character(BIENcitations), as.character(BIENsources$doi), sep = ". ")

      for (i in 1:length(BIENcitations)){
        if (grepl("\\.\\s$", BIENcitations[[i]])){
          BIENcitations[[i]] <- gsub(BIENcitations[[i]], pattern = "\\.\\s", replacement = ".")
        } else{
          BIENcitations[[i]] <- paste0(BIENcitations[[i]], ".")
        }
      }

      bienTable <- data.frame(as.character(rep("BIEN", length(BIENdatasetKeys))),
                              as.character(BIENdatasetKeys),
                              BIENcitations,
                              as.character(BIENsources$date_accessed), as.numeric(BIENdatasetCount[,2]),
                              stringsAsFactors = F)
      colnames(bienTable) <- c("occSearch", "Dataset Key", "Citation", "Accession Date", "Number of Occurrences")
    }

    if(!is.null(occResults$GBIF) & !is.null(occResults$BIEN)){
      citationTable <- rbind(gbifTable,bienTable)
    }
    else if(!is.null(occResults$BIEN)){
      citationTable <- bienTable
    }
    else{
      citationTable <- gbifTable
    }

    citationTables[[sp]] <- citationTable[order(citationTable$Citation),]
  }

  occCiteCitationInstance <- methods::new("occCiteCitation", occCitationResults = citationTables)

  return(occCiteCitationInstance)
}
