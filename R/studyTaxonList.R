#' @title Study Taxon List
#'
#' @description Takes input phylogenies or vectors of taxon names, checks
#' against taxonomic database, returns vector of cleaned taxonomic names
#' (using \code{taxize::gnr_resolve()}) for use in spocc queries, as
#' well as warnings if there are invalid names.
#'
#' @param x A phylogeny of class 'phylo' or a vector of class 'character'
#' containing the names of taxa of interest
#'
#' @param datasources A vector of taxonomic data sources implemented in
#' \code{taxize::gnr_resolve}. You can see the list using
#' \code{taxize::gnr_datasources()}.
#'
#' @return An object of class \code{\link{occCiteData}} containing the type
#' of inquiry the user has made --a phylogeny or a vector of names-- and a
#' data frame containing input taxa names, the closest match according to
#' \code{taxize::gnr_resolve}, and a list of taxonomic data sources that
#' contain the matching name.
#'
#' @examples
#' ## Inputting a vector of taxon names
#' studyTaxonList(
#'   x = c(
#'     "Buteo buteo",
#'     "Buteo buteo hartedi",
#'     "Buteo japonicus"
#'   ),
#'   datasources = c("National Center for Biotechnology Information")
#' )
#'
#'\donttest{
#' ## Inputting a phylogeny
#' phylogeny <- ape::read.nexus(
#'   system.file("extdata/Fish_12Tax_time_calibrated.tre",
#'     package = "occCite"
#'   )
#' )
#' phylogeny <- ape::extract.clade(phylogeny, 18)
#' studyTaxonList(
#'   x = phylogeny,
#'   datasources = c("GBIF Backbone Taxonomy")
#' )
#' }
#'
#' @export
studyTaxonList <- function(x = NULL,
                           datasources = "GBIF Backbone Taxonomy") {
  # Error check inputs (x).
  if (!is(x, "phylo") &
    !(is.vector(class(x)) &&
      is(x, "character"))) {
    warning(message(
      "Target input invalid. Input must be of class\n",
      "'phylo' or a vector of class 'character'.\n"
    ))
    return(NULL)
  } else if (is.vector(class(x)) && is(x, "character")) {
    targets <- x
    dataFrom <- "User-supplied list of taxa." # Keeping track of metadata
  } else if (is(x, "phylo")) {
    targets <- x$tip.label
    dataFrom <- "User-supplied phylogeny." # Keeping track of metadata
  }

  # Building the results table
  resolvedNames <- data.frame()
  for (i in seq(to = length(targets))) {
    tryCatch(
      expr = newResName <- withCallingHandlers(
        {
          taxonRectification(
            taxName = targets[[i]],
            datasources = datasources
          )
        },
        warning = function(w) {
          message("handled warning: ", conditionMessage(w))
          invokeRestart("muffleWarning")
        }
      ),
      error = function(e) {
        message(paste("GNR server unreachable; please try again later. \n"))
      }
    )

    if (!exists("newResName")) {
      return(invisible(NULL))
    }
    resolvedNames <- rbind(resolvedNames, newResName)
  }

  if (ncol(resolvedNames == 3)) {
    colnames(resolvedNames) <- c(
      "Input Name",
      "Best Match",
      "Taxonomic Databases w/ Matches"
    )
    resolvedNames <- as.data.frame(resolvedNames)

    # Populating an instance of class occCiteData
    occCiteInstance <- methods::new("occCiteData",
      userQueryType = dataFrom,
      userSpecTaxonomy = datasources,
      cleanedTaxonomy = resolvedNames
    )
    return(occCiteInstance)
  } else {
    (
      return(invisible(NULL))
    )
  }
}
