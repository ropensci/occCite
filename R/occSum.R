#' @title Summary for occCite data objects
#'
#' @description Displays a summary of relevant stats about a query
#'
#' @param object An object of class \code{\link{occCiteData}}
#'
#' @param ... Additional arguments affecting the summary produced
#'
#' @return A dataframe with citations information for occurrences
#'
#' @examples
#'
#' \dontrun{
#' myOcciteObject <- occQuery(x = myOccCiteObject,
#'          datasources = c("gbif", "bien"),
#'          GBIFLogin = myLogin,
#'          limit = NULL,
#'          GBIFDownloadDirectory = "./Desktop"
#'          loadLocalGBIFDownload = F);
#' summary(myOcciteObject);
#'}
#'
#' @export
#'
summary.occCiteData <- function(object, ...) {
  x <- object

  stopifnot(inherits(x, "occCiteData"))

  if(!is.null(x@occCiteSearchDate)){
    cat("\t\n",
        sprintf("OccCite query occurred on: %s\n", x@occCiteSearchDate))
  }

  if(!is.null(x@userQueryType)){
    cat("\t\n",
        sprintf("User query type: %s\n", x@userQueryType))
  }

  if(!is.null(x@userSpecTaxonomicSources)){
    cat("\t\n",
        sprintf("Sources for taxonomic rectification: %s\n",
                paste0(x@userSpecTaxonomicSources, collapse = ", ")), "\t\n")
  }

  if(!is.null(x@cleanedTaxonomy)){
    cat("\t\n",
        sprintf("Taxonomic cleaning results: %s\n", "\t\n"))
    print(x@cleanedTaxonomy);
  }

  if(length(x@occResults) > 0){
    cat("\t\n",
        sprintf("Sources for occurrence data: %s\n", paste0(x@occSources, collapse = ", ")), "\t\n")
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
      if (is.null(x@occResults[[i]]$GBIF$OccurrenceTable)){
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
      if (is.null(x@occResults[[i]]$BIEN$OccurrenceTable)){
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

  if("gbif" %in% x@occSources && !is.null(x@occResults[[i]]$GBIF$Metadata$doi)){
    cat("\t\n",
        sprintf("GBIF dataset DOIs: %s\n", "\t\n"))

    #Tabulate DOIs
    GBIFdoi <- vector(mode = "numeric", length = length(x@occResults))
    for (i in 1:length(x@occResults)){
      GBIFdoi[[i]] <- x@occResults[[i]]$GBIF$Metadata$doi
    }
    #Tabulate access dates
    GBIFaccessDate <- vector(mode = "numeric", length = length(x@occResults))
    for (i in x@occResults){
      GBIFaccessDate <- strsplit(i$GBIF$Metadata$modified, "T")[[1]][1]
    }
    doiTab <- as.data.frame(cbind(names(x@occResults), GBIFaccessDate, GBIFdoi))
    colnames(doiTab) <- c("Species", "GBIF Access Date", "GBIF DOI")
    print(doiTab)
  }
}
