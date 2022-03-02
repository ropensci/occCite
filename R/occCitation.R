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
#' @importFrom curl has_internet
#' @import RPostgreSQL
#'
#' @examples
#' \dontrun{
#' data(myOccCiteObject)
#' myCitations <- occCitation(x = myOccCiteObject)
#' }
#' @export

occCitation <- function(x = NULL) {
  # Error check input x.
  if (!class(x) == "occCiteData") {
    warning(paste0(
      "Input x is not of class 'occCiteData'.\n",
      "Input x must be result of a studyTaxonList() search.\n"
    ))
    return(NULL)
  }

  citationTables <- list()

  for (sp in names(x@occResults)) {
    # Initializing citation lists
    GBIFCitationList <- vector(mode = "list")
    GBIFDatasetCount <- NULL
    BIENCitationList <- vector(mode = "list")
    BIENDatasetCount <- NULL

    occResults <- x@occResults[[sp]]

    # GBIF
    if (!is.null(occResults$GBIF)) {
      test <- try(rgbif::occ_count(country = "DK"),
        silent = T
      )
      if (class(test) != "numeric") {
        warning("GBIF connection unsuccessful")
        return(NULL)
      }
      ## Pull dataset keys from occurrence table
      datasetKeys <- stats::na.exclude(unlist(as.character(occResults$GBIF$OccurrenceTable$DatasetKey)))
      if (length(datasetKeys) > 0) {
        GBIFDatasetCount <- as.data.frame(table(unlist(datasetKeys)))
        GBIFdatasetKeys <- unique(unlist(datasetKeys))
        GBIFdatasetKeys <- stats::na.omit(GBIFdatasetKeys)
        ## Look up citations on GBIF based on dataset keys
        ## removes accession date
        ### supplied date from rgbif is date citation was sought
        ### not the date the data was accessed
        for (j in GBIFdatasetKeys) {
          tryCatch(
            expr = temp <- gsub(rgbif::gbif_citation(j)$citation$text,
              pattern = " accessed via GBIF.org on \\d+\\-\\d+\\-\\d+.",
              replacement = "",
              useBytes = T
            ),
            error = function(e) {
              message(paste("GBIF unreachable; please try again later. \n"))
            }
          )

          if (!exists("temp")) {
            return(invisible(NULL))
          }

          temp <- gsub(temp, pattern = "Occurrence dataset ", replacement = "")
          temp <- paste0(temp, ".")
          GBIFCitationList <- append(GBIFCitationList, temp)
        }
      } else {
        GBIFCitationList <- NA
      }
    }

    # BIEN
    if (!is.null(occResults$BIEN)) {
      ## Pull dataset keys from occurrence table
      BIENdatasetKeys <- vector(mode = "list")
      BIENKeysNAs <- vector(mode = "list")
      if (anyNA(occResults$BIEN$OccurrenceTable$DatasetKey)) {
        BIENKeysNAs <- occResults$BIEN$OccurrenceTable$Dataset[is.na(occResults$BIEN$OccurrenceTable$DatasetKey)]
        BIENKeysNAs <- unique(BIENKeysNAs)
      }
      BIENdatasetKeys <- append(
        BIENdatasetKeys,
        unlist(as.character((occResults$BIEN$OccurrenceTable$DatasetKey)))
      )
      BIENdatasetKeys <- BIENdatasetKeys[!is.na(BIENdatasetKeys)]

      BIENdatasetCount <- as.data.frame(table(unlist(BIENdatasetKeys)))
      BIENdatasetKeys <- unique(unlist(BIENdatasetKeys))

      # Handle datasets without keys
      if (length(BIENKeysNAs) > 0) {
        print(paste0(
          "NOTE: ", length(BIENKeysNAs),
          " BIEN dataset(s) for ", sp,
          " do not have dataset keys to link citations. They are: ",
          paste(as.character(unlist(BIENKeysNAs)), collapse = ", ")
        ))
      }

      ## Get data sources
      query <- paste(
        "WITH a AS (SELECT * FROM datasource where datasource_id in (",
        paste(shQuote(BIENdatasetKeys, type = "sh"),
          collapse = ", "
        ),
        ")) SELECT * FROM datasource where datasource_id in (SELECT datasource_id FROM a);"
      )

      host <- "vegbiendev.nceas.ucsb.edu"
      dbname <- "public_vegbien"
      user <- "public_bien"
      password <- "bien_public"
      # Name the database type that will be used
      drv <- DBI::dbDriver("PostgreSQL")

      # Test internet connection
      if (!curl::has_internet()) {
        warning("No internet connection available, please try again later. \n")
        return(NULL)
      }
      # establish connection with database
      tryCatch(
        expr = con <- DBI::dbConnect(drv,
          host = host,
          dbname = dbname,
          user = user,
          password = password
        ),
        error = function(e) {
          message(paste("BIEN unreachable; please try again later. \n"))
        }
      )

      if (!exists("con")) {
        return(invisible(NULL))
      }

      BIENsources <- DBI::dbGetQuery(con, statement = query)
      DBI::dbDisconnect(con)
      rm(con)

      # bien sql replacement

      # Handle keys without citations
      if (nrow(BIENsources) < length(BIENdatasetKeys)) {
        noNameKeys <- unlist(BIENdatasetKeys[!BIENdatasetKeys %in%
          BIENsources$datasource_id]) # Gets keys missing names
        datasetLookupTable <- unique(occResults$BIEN$OccurrenceTable[,
                                                                     c("DatasetKey",
                                                                       "Dataset")])
        datasetLookupTable[] <- lapply(datasetLookupTable, as.character)
        missingNames <- datasetLookupTable$Dataset[datasetLookupTable$DatasetKey %in%
          noNameKeys] # Pulls missing names

        print(paste0(
          "NOTE: ", length(BIENdatasetKeys) - nrow(BIENsources),
          " BIEN dataset(s) for ", sp,
          " is/are missing citation data. Key(s) missing citations are: ",
          paste(as.character(noNameKeys), collapse = ", "), ". ",
          "Source(s) are identified as: ",
          paste(as.character(unlist(missingNames)), collapse = ", "), "."
        ))
        # TO FIX: INSERT NA ROW(s) FOR MISSING CITATION DATA
        BIENsources[nrow(BIENsources) +
          (length(BIENdatasetKeys) - nrow(BIENsources)), ] <- NA
        BIENsources$source_name[which(BIENsources$datasource_id %in%
          noNameKeys)] <- missingNames
      }
    }

    # Columns: UUID, Citation, Access date, number of records
    if (!is.null(occResults$GBIF)) {
      # Assumes all species queries occurred at same time (may not be)
      # FIX LATER
      GBIFaccessDate <- strsplit(
        occResults$GBIF$Metadata$modified,
        "T"
      )[[1]][1]
      if (length(stats::na.exclude(GBIFCitationList)) > 0) {
        gbifTable <- data.frame(rep("GBIF", length(GBIFdatasetKeys)),
          GBIFdatasetKeys, unlist(GBIFCitationList),
          rep(GBIFaccessDate, length(GBIFdatasetKeys)),
          GBIFDatasetCount[, 2],
          stringsAsFactors = F
        )
      } else {
        gbifTable <- data.frame(as.list(c("GBIF", rep(NA, times = 4))))
      }

      colnames(gbifTable) <- c(
        "occSearch", "Dataset Key", "Citation",
        "Accession Date", "Number of Occurrences"
      )
    }

    if (!is.null(occResults$BIEN)) {
      BIENcitations <- BIENsources$source_citation
      # If no citation available, replace it with full name of primary provider
      for (i in 1:length(BIENcitations)) {
        if (is.na(BIENcitations[i])) {
          BIENcitations[i] <- BIENsources$source_fullname[i]
        }
      }
      # Failing that, replace it with shortened name of primary provider
      for (i in 1:length(BIENcitations)) {
        if (is.na(BIENcitations[i])) {
          BIENcitations[i] <- BIENsources$source_name[i]
        }
      }
      # Replacing NA values for doi with "" for formatting purposes
      for (i in 1:length(BIENsources$doi)) {
        if (is.na(BIENsources$doi[i])) {
          BIENsources$doi[i] <- ""
        }
      }
      BIENcitations <- paste(as.character(BIENcitations),
        as.character(BIENsources$doi),
        sep = ". "
      )

      for (i in 1:length(BIENcitations)) {
        if (grepl("\\.\\s$", BIENcitations[[i]])) {
          BIENcitations[[i]] <- gsub(BIENcitations[[i]],
            pattern = "\\.\\s",
            replacement = "."
          )
        } else {
          BIENcitations[[i]] <- paste0(BIENcitations[[i]], ".")
        }
      }

      bienTable <- data.frame(as.character(rep(
        "BIEN",
        length(BIENdatasetKeys)
      )),
      as.character(BIENdatasetKeys),
      BIENcitations,
      as.character(BIENsources$date_accessed),
      as.numeric(BIENdatasetCount[, 2]),
      stringsAsFactors = F
      )
      colnames(bienTable) <- c(
        "occSearch", "Dataset Key", "Citation",
        "Accession Date", "Number of Occurrences"
      )
    }

    if (!is.null(occResults$GBIF) & !is.null(occResults$BIEN)) {
      citationTable <- rbind(gbifTable, bienTable)
    } else if (!is.null(occResults$BIEN)) {
      citationTable <- bienTable
    } else {
      citationTable <- gbifTable
    }

    citationTables[[sp]] <- citationTable[order(citationTable$Citation), ]
  }

  occCiteCitationInstance <- methods::new("occCiteCitation",
    occCitationResults = citationTables
  )

  return(occCiteCitationInstance)
}
