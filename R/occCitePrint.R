#' @title Print occCite citation object
#'
#' @description Prints formatted citations for occurrences
#'
#' @param object An object of class \code{\link{occCiteCitation}}
#'
#' @param bySpecies Logical; If `TRUE`, formatted citations will
#' be returned in chunks headed by the species name. If `FALSE`,
#' a single citation string for all species is returned.
#'
#' @param ... Additional arguments affecting how the formatted
#' citation document is produced
#'
#' @return A text string with formatted citatations
#'
#' @examples
#'
#' # Print citations for all species together
#' data(myOccCiteObject)
#' print(myOccCiteObject, bySpecies = F)
#'
#' # Print citations for each species individually
#' data(myOccCiteObject)
#' print(myOccCiteObject, bySpecies = T)
#'
#' @export
#'
print.occCiteCitation <- function(object, bySpecies = F, ...) {
  x <- object

  stopifnot(inherits(x, "occCiteCitation"))

  if(bySpecies){
    for (i in 1:length(x@occResults)){
      cat(paste("Species:", names(x@occResults)[[i]], "\n\n"))
      singleSpRecord <- x@occResults[[i]]
      singleSpRecord <- singleSpRecord[order(singleSpRecord$Citation),]
      cat(paste0(singleSpRecord$Citation,
                " Accessed via ", singleSpRecord$occSearch,
                " on ", singleSpRecord$`Accession Date`, "."),
          sep = "\n")
      cat(paste("\n"))
    }
  } else {
    allCitations <- do.call(rbind, x@occResults)
    allCitations <- allCitations[order(allCitations$Citation),]
    allCitations <- unique(allCitations[,c("occSearch", "Citation", "Accession Date")])
    cat(paste0(allCitations$Citation,
              " Accessed via ", allCitations$occSearch,
              " on ", allCitations$`Accession Date`, "."),
        sep = "\n")
  }
}
