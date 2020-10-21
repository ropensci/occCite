#' @title Print occCite citation object
#'
#' @description Prints formatted citations for occurrences and main
#' packages used (i.e. base, occCite, rgbif, and/or BIEN).
#'
#' @param x An object of class \code{\link{occCiteCitation}}
#'
#' @param ... Additional arguments affecting how the formatted
#' citation document is produced
#'
#' @return A text string with formatted citations
#'
#' @import bib2df
#' @importFrom stats na.omit
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

  if (!requireNamespace("RefManageR", quietly = TRUE)) {
    stop("Package \"RefManageR\" needed for this function to work. Please install it.",
         call. = FALSE)
  }

  #Utility function for making a citation list
  refManMCL <- function(x) {
    rval <- list()
    for (i in seq_along(x)) {
      if (!is.null(x[[i]]))
        rval <- c(rval, unclass(x[[i]]))
    }
    class(rval) <- c("BibEntry", "bibentry")
    rval
  }
  # Function to generate package citations
  packageCitations <- function(packagesUsed){
    pkg.bib<- lapply(packagesUsed, function(pkg){
      refs<- RefManageR::as.BibEntry(utils::citation(pkg))
      if(length(refs))
        names(refs) <- make.unique(rep(pkg,length(refs)))
      refs})
    pkg.bib <- refManMCL(pkg.bib)
    RefManageR::WriteBib(pkg.bib, "temp.bib")

    #this works
    temp <- bib2df::bib2df("temp.bib", separate_names = T)

    packageCitations <- vector(mode = "character", length = nrow(temp))
    for(j in 1:nrow(temp)){
      i <- temp[j,]
      if("R Core Team" %in% i$AUTHOR[[1]]["full_name"]){
        packageCitations[j] <- paste0(i$AUTHOR[[1]]['full_name'], ". ", "(",i$YEAR, "). ",
                                      i$TITLE, ". ", i$ORGANIZATION, ", ",
                                      i$ADDRESS, ". ", i$URL, ".")
      } else if(i$CATEGORY=="ARTICLE"){
        packageCitations[j] <- paste0(paste(apply(i$AUTHOR[[1]],
                                                  MARGIN = 1,
                                                  FUN = function(x) paste0(x[4], ", ",
                                                                           substring(x[2], 1, 1), ".",
                                                                           if(!is.na(x[3])){
                                                                             paste0(substring(x[3], 1, 1), ".")})),
                                            collapse = ", "),
                                      " (",i$YEAR, "). ",
                                      i$TITLE, ". ",
                                      i$JOURNAL, if(!any(is.na(i$VOLUME), is.na(i$PAGES))){paste0(" ")},
                                      if(!is.na(i$VOLUME)){paste0(i$VOLUME, ": ")},
                                      if(!is.na(i$PAGES)){paste0(i$PAGES)},
                                      "."
        )
      } else if(grepl("R package", i$NOTE)){
        packageCitations[j] <- paste0(paste(apply(i$AUTHOR[[1]],
                                                  MARGIN = 1,
                                                  FUN = function(x) paste0(x[4], ", ",
                                                                           substring(x[2], 1, 1), ".",
                                                                           if(!is.na(x[3])){
                                                                             paste0(substring(x[3], 1, 1), ".")})),
                                            collapse = ", "),
                                      " (",i$YEAR, "). ",
                                      i$TITLE, ". ",
                                      i$NOTE, ". ",
                                      i$URL, ".")
      }
      else{
        packageCitations[j] <- paste0(paste(apply(i$AUTHOR[[1]],
                                                  MARGIN = 1,
                                                  FUN = function(x) paste0(x[4], ", ",
                                                                           substring(x[2], 1, 1), ".",
                                                                           if(!is.na(x[3])){
                                                                             paste0(substring(x[3], 1, 1), ".")})),
                                            collapse = ", "),
                                      " (",i$YEAR, "). ",
                                      i$TITLE, ". ",
                                      i$ORGANIZATION, ", ",
                                      i$ADDRESS, ". ",
                                      i$URL, ".")
      }
    }

    file.remove("temp.bib")
    packageCitations <- sort(packageCitations)
    return(packageCitations)
  }

  # Combine citations
  if(bySpecies){
    for (i in 1:length(x$occCitationResults)){
      # Get list of packages used and get citations
      packCit <- c("base", "occCite", "RefManageR")
      packages <- unique(x$occCitationResults[[i]]$occSearch)
      if("GBIF" %in% packages) packCit <- c(packCit, "rgbif")
      if("BIEN" %in% packages) packCit <- c(packCit, "BIEN")
      packCit <- packageCitations(packCit)

      # Print results
      cat(paste("Species:", names(x$occCitationResults)[[i]], "\n\n"))
      singleSpRecord <- x$occCitationResults[[i]]
      singleSpRecord <- singleSpRecord[order(singleSpRecord$Citation),]
      if(nrow(singleSpRecord[!is.na(singleSpRecord$Citation),]) > 0){
        recordCitations <- paste0(singleSpRecord$Citation,
               " Accessed via ", singleSpRecord$occSearch,
               " on ", singleSpRecord$`Accession Date`, ".")
        allCitations <- sort(c(packCit, recordCitations))
        cat(allCitations, sep = "\n")
      } else {
        cat("NOTE: No occurrences to cite.\n\n")
        cat(packCit, sep = "\n")
      }
      cat(paste("\n"))
    }
  } else {
    recordCitations <- do.call(rbind, x$occCitationResults)
    recordCitations <- recordCitations[!is.na(recordCitations$Citation),]

    # Get list of packages used and get citations
    packCit <- c("base", "occCite")
    packages <- unique(recordCitations$occSearch)
    if("GBIF" %in% packages) packCit <- c(packCit, "rgbif")
    if("BIEN" %in% packages) packCit <- c(packCit, "BIEN")
    packCit <- packageCitations(packCit)

    # Print results
    recordCitations <- recordCitations[order(recordCitations$Citation),]
    recordCitations <- unique(recordCitations[,c("occSearch", "Citation", "Accession Date")])
    recordCitations <- paste0(recordCitations$Citation,
              " Accessed via ", recordCitations$occSearch,
              " on ", recordCitations$`Accession Date`, ".")
    allCitations <- sort(c(packCit, recordCitations))
    cat(allCitations, sep = "\n")
    cat(paste("\n"))
  }
}
