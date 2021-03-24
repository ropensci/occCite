#' @title Summary for occCite data objects
#'
#' @description Displays a summary of relevant stats about a query
#'
#' @param object An object of class \code{\link{occCiteData}}
#'
#' @param ... Additional arguments affecting the summary produced
#'
#' @examples
#'
#' data(myOccCiteObject)
#' summary(myOccCiteObject)
#'
#' @method summary occCiteData
#' @export
#'
summary.occCiteData <- function(object, ...) {
  x <- object

  stopifnot(inherits(x, "occCiteData"))

  if(!is.null(x@occCiteSearchDate)){
    cat("\t\n",
        sprintf("OccCite query occurred on: %s\n",
                as.character(as.Date(x@occCiteSearchDate),
                             format = "%d %B, %Y")))
  }

  if(!is.null(x@userQueryType)){
    cat("\t\n",
        sprintf("User query type: %s\n", x@userQueryType))
  }

  if(!is.null(x@userSpecTaxonomy)){
    cat("\t\n",
        sprintf("Sources for taxonomic rectification: %s\n",
                paste0(x@userSpecTaxonomy, collapse = ", ")), "\t\n")
  }

  if(!is.null(x@cleanedTaxonomy)){
    cat("\t\n",
        sprintf("Taxonomic cleaning results: %s\n", "\t\n"))
    print(x@cleanedTaxonomy)
  }

  if(length(x@occResults) > 0){
    cat("\t\n",
        sprintf("Sources for occurrence data: %s\n",
                paste0(x@occSources, collapse = ", ")), "\t\n")
    #Tabulate search results
    occurrenceCountGBIF <- vector(mode = "numeric",
                                  length = length(x@occResults))
    occurrenceCountBIEN <- vector(mode = "numeric",
                                  length = length(x@occResults))
    sourceCountGBIF <- vector(mode = "numeric",
                              length = length(x@occResults))
    sourceCountBIEN <- vector(mode = "numeric",
                              length = length(x@occResults))

    for (i in 1:length(x@occResults)){
      #GBIF counts
      if (any(x@occSources == "bien",
              is.null(x@occResults[[i]]$GBIF$OccurrenceTable),
              nrow(x@occResults[[i]]$GBIF$OccurrenceTable[!is.na(x@occResults[[i]]$GBIF$OccurrenceTable$DatasetKey),]) == 0,
              na.rm = T)){
        occurrenceCountGBIF[[i]] <- 0
        sourceCountGBIF[[i]] <- 0
      }
      else{
        occurrenceCountGBIF[[i]] <- nrow(
          x@occResults[[i]]$GBIF$OccurrenceTable)
        sourceCountGBIF[[i]] <- length(
          unique(x@occResults[[i]]$GBIF$OccurrenceTable$DatasetKey))
      }
      #BIEN counts
      if (any(x@occSources == "gbif",
              is.null(x@occResults[[i]]$BIEN$OccurrenceTable),
              na.rm = T)){
        occurrenceCountBIEN[[i]] <- 0
        sourceCountBIEN[[i]] <- 0
      }
      else{
        occurrenceCountBIEN[[i]] <- nrow(
          x@occResults[[i]]$BIEN$OccurrenceTable)
        sourceCountBIEN[[i]] <- length(
          unique(x@occResults[[i]]$BIEN$OccurrenceTable$DatasetKey))
      }
    }
    sumTab <- as.data.frame(cbind(names(x@occResults),
                                  (occurrenceCountGBIF+occurrenceCountBIEN),
                                  (sourceCountGBIF + sourceCountBIEN)))
    colnames(sumTab) <- c("Species", "Occurrences",
                          "Sources")
    print(sumTab)
  }

  if("gbif" %in% x@occSources){
    cat("\t\n",
        sprintf("GBIF dataset DOIs: %s\n", "\t\n"))

    #Tabulate DOIs
    GBIFdoi <- vector(mode = "numeric", length = length(x@occResults))
    GBIFaccessDate <- vector(mode = "numeric", length = length(x@occResults))
    for (i in 1:length(x@occResults)){
      if(as.numeric(sumTab$Occurrences[[i]]) > 0){
        GBIFdoi[[i]] <- x@occResults[[i]]$GBIF$Metadata$doi
        GBIFaccessDate[[i]] <- strsplit(x@occResults[[i]]$GBIF$Metadata$modified,
                                        "T")[[1]][1]
      } else {
        GBIFdoi[[i]] <- NA
        GBIFaccessDate[[i]] <- NA
      }
    }
    doiTab <- as.data.frame(cbind(names(x@occResults), GBIFaccessDate, GBIFdoi))
    colnames(doiTab) <- c("Species", "GBIF Access Date", "GBIF DOI")
    print(doiTab)
  }
}
