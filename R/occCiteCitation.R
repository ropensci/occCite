#' @title occCite Citation Class
#'
#' @description A class for managing citations generated from occCite
#' queries.
#'
#' @field occCitationResults The results of performing
#' \code{\link{occCitation}} on a \code{\link{occCiteData}} object,
#' stored as a named list, each of the items named after a searched
#' taxon and containing a data frame with occurrence information.
#'
#' @importFrom methods new
#'
#' @export
occCiteCitation <- methods::setRefClass(
  Class = "occCiteCitation",
  fields = list(occCitationResults = "list")
)
