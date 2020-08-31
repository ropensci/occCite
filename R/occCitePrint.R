#' @title Print occCite citation object
#'
#' @description Prints formatted citations for occurrences
#'
#' @param x An object of class \code{\link{occCiteCitation}}
#'
#' @param ... Additional arguments affecting how the formatted
#' citation document is produced
#'
#' @return A text string with formatted citations
#'
#' @examples
#'
#' # Print citations for all species together
#' data(myOccCiteObject)
#' print(myOccCiteObject)
#'
#' # Print citations for each species individually
#' data(myOccCiteObject)
#' print(myOccCiteObject, bySpecies = TRUE)
#'
#' @export
#'
print.occCiteCitation <- function(x, ...) {
  args <- list(...)
  if ("bySpecies" %in% names(args)){
    bySpecies <- args$bySpecies
  } else {
    bySpecies <- FALSE
  }

  stopifnot(inherits(x, "occCiteCitation"))

  if(bySpecies){
    for (i in 1:length(x$occCitationResults)){
      cat(paste("Species:", names(x$occCitationResults)[[i]], "\n\n"))
      singleSpRecord <- x$occCitationResults[[i]]
      singleSpRecord <- singleSpRecord[order(singleSpRecord$Citation),]
      cat(paste0(singleSpRecord$Citation,
                " Accessed via ", singleSpRecord$occSearch,
                " on ", singleSpRecord$`Accession Date`, "."),
          sep = "\n")
      cat(paste("\n"))
    }
  } else {
    allCitations <- do.call(rbind, x$occCitationResults)
    allCitations <- allCitations[order(allCitations$Citation),]
    allCitations <- unique(allCitations[,c("occSearch", "Citation", "Accession Date")])
    cat(paste0(allCitations$Citation,
              " Accessed via ", allCitations$occSearch,
              " on ", allCitations$`Accession Date`, "."),
        sep = "\n")
  }
}
