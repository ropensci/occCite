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
#' @noRd

GBIFtableCleanup <- function(GBIFtable) {
  isnothing <- function(x) {
    any(is.null(x)) | any(is.na(x) | sum(apply(x, 2, is.nan)) > 0)
  }

  if (is.null(nrow(GBIFtable))) {
    GBIFtable <- NULL
    GBIFtable["name"] <- NA
    GBIFtable["longitude"] <- NA
    GBIFtable["latitude"] <- NA
    GBIFtable["day"] <- NA
    GBIFtable["month"] <- NA
    GBIFtable["year"] <- NA
    GBIFtable["Dataset"] <- NA
    GBIFtable["DatasetKey"] <- NA
    GBIFtable["DataService"] <- NA
    GBIFtable <- as.data.frame(as.list(GBIFtable))
    return(GBIFtable)
  } else if (nrow(GBIFtable) == 0) {
    GBIFtable <- NULL
    GBIFtable["name"] <- NA
    GBIFtable["longitude"] <- NA
    GBIFtable["latitude"] <- NA
    GBIFtable["day"] <- NA
    GBIFtable["month"] <- NA
    GBIFtable["year"] <- NA
    GBIFtable["Dataset"] <- NA
    GBIFtable["DatasetKey"] <- NA
    GBIFtable["DataService"] <- NA
    GBIFtable <- as.data.frame(as.list(GBIFtable))
    return(GBIFtable)
  } else {
    if (!isnothing(GBIFtable)) {
      GBIFtable <- GBIFtable[, -1]
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
    } else {
      GBIFtable <- NULL
      GBIFtable["name"] <- NA
      GBIFtable["longitude"] <- NA
      GBIFtable["latitude"] <- NA
      GBIFtable["day"] <- NA
      GBIFtable["month"] <- NA
      GBIFtable["year"] <- NA
      GBIFtable["Dataset"] <- NA
      GBIFtable["DatasetKey"] <- NA
      GBIFtable["DataService"] <- NA
      GBIFtable <- as.data.frame(as.list(GBIFtable))
      return(GBIFtable)
    }
  }
}
