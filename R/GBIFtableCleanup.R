#' @title GBIF Table Cleanup
#'
#' @description Forces occurrence table columns to a uniform
#' format. This is an internal function for use by \code{\link{occQuery}}.
#'
#' @param GBIFtable A data.frame resulting from \code{\link{getGBIFpoints}} OR
#' \code{\link{gbifRetriever}}.
#'
#' @return A data.frame tidied for compatibility with
#' \code{\link{getBIENpoints}} results.
#'
#' @keywords internal

GBIFtableCleanup <- function(GBIFtable){
  GBIFtable <- GBIFtable[,-1]
  GBIFtable["name"] <- as.factor(unlist(GBIFtable["name"]))
  GBIFtable["longitude"] <- as.numeric(unlist(GBIFtable["longitude"]))
  GBIFtable["latitude"] <- as.numeric(unlist(GBIFtable["latitude"]))
  GBIFtable["day"] <- as.integer(unlist(GBIFtable["day"]))
  GBIFtable["month"] <- as.integer(unlist(GBIFtable["month"]))
  GBIFtable["year"] <- as.integer(unlist(GBIFtable["year"]))
  GBIFtable["Dataset"] <- as.factor(unlist(GBIFtable["Dataset"]))
  GBIFtable["DatasetKey"] <- as.factor(unlist(GBIFtable["DatasetKey"]))
  GBIFtable["DataService"] <- as.factor(unlist(GBIFtable["DataService"]))

  return(GBIFtable)
}
