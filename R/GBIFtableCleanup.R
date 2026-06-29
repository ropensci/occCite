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
  col_types <- list(
    name = as.factor, longitude = as.numeric, latitude = as.numeric,
    coordinateUncertaintyInMeters = as.numeric, day = as.integer,
    month = as.integer, year = as.integer, datasetName = as.factor,
    datasetKey = as.factor, dataService = as.factor
  )

  # Helper to check if a table is functionally empty
  isnothing <- function(x) {
    any(is.null(x)) || any(all(is.na(x)) || sum(apply(x, 2, is.nan)) > 0)
  }

  if (is.null(nrow(GBIFtable)) || nrow(GBIFtable) == 0 || isnothing(GBIFtable)) {
    empty_list <- lapply(col_types, function(f) f(NA))
    return(as.data.frame(empty_list, stringsAsFactors = FALSE))
  }

  GBIFtable <- GBIFtable[, -1, drop = FALSE]

  for (col in names(col_types)) {
    if (col %in% names(GBIFtable)) {
      GBIFtable[[col]] <- col_types[[col]](GBIFtable[[col]])
    }
  }

  return(GBIFtable)
}
