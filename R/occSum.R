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
#' myOcciteObject <- occQuery(x = myBridgeTreeObject,
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

  if(!is.null(x@occurrenceSearchDate)){
    cat("\t\n",
        sprintf("Query occurred on: %s\n", x@occurrenceSearchDate))
  }

  if(!is.null(x@userQueryType)){
    cat("\t\n",
        sprintf("User query type: %s\n", x@userQueryType))
  }

  if(!is.null(x@userSpecTaxonomicSources)){
    cat("\t\n",
        sprintf("Sources for taxonomic recticfication: %s\n", x@userSpecTaxonomicSources))
  }

  if(!is.null(x@occResults)){
    cat("\t\n",
        sprintf("Sources for occurrence data: %s\n", x@occSources), "\t\n")
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
      if (is.null(x@occResults[[i]]$GBIF)){
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
      if (is.null(x@occResults[[i]]$BIEN)){
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
    cat("\t\n")
    #Tabulate DOIs
    GBIFdoi <- vector(mode = "numeric", length = length(x@occResults))
    for (i in 1:length(x@occResults)){
      GBIFdoi[[i]] <- x@occResults[[i]]$GBIF$Metadata$doi
    }
    doiTab <- as.data.frame(cbind(names(x@occResults),GBIFdoi))
    colnames(doiTab) <- c("Species", "DOI")
    print(doiTab)
  }
}
