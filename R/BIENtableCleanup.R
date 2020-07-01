#' @title BIEN Table Cleanup
#'
#' @description Forces occurrence table columns to a uniform
#' format. This is an internal function for use by \code{\link{occQuery}}.
#'
#' @param BIENtable A data.frame resulting from \code{\link{getBIENpoints}}.
#'
#' @return A data.frame tidied for compatibility with
#' \code{\link{getGBIFpoints}} results.
#'
#' @examples
#' \dontrun{
#' temp <- getBIENpoints(taxon="Protea cynaroides", limit = NULL)
#' fitForUseTable <- BIENtableCleanup(temp$OccurrenceTable)
#'}
#'
#' @export
BIENtableCleanup <- function(BIENtable){
  BIENtable["name"] <- as.factor(unlist(BIENtable["name"]))
  BIENtable["longitude"] <- as.numeric(unlist(BIENtable["longitude"]))
  BIENtable["latitude"] <- as.numeric(unlist(BIENtable["latitude"]))
  BIENtable["day"] <- as.integer(unlist(BIENtable["day"]))
  BIENtable["month"] <- as.integer(unlist(BIENtable["month"]))
  BIENtable["year"] <- as.integer(unlist(BIENtable["year"]))
  BIENtable["Dataset"] <- as.factor(unlist(BIENtable["Dataset"]))
  BIENtable["DatasetKey"] <- as.factor(unlist(BIENtable["DatasetKey"]))
  BIENtable["DataService"] <- as.factor(unlist(BIENtable["DataService"]))

  return(BIENtable)
}
