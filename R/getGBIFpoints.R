#' @title Download occurrence points from GBIF
#'
#' @description Downloads occurrence points and useful related information
#' for processing within other occCite functions
#'
#' @param taxon A single species
#'
#' @param GBIFLogin An object of class \code{\link{GBIFLogin}} to log in to
#' GBIF to begin the download.
#'
#' @param GBIFDownloadDirectory An optional argument that specifies the local
#' directory where GBIF downloads will be saved. If this is not specified, the
#' downloads will be saved to your current working directory.
#'
#' @param checkPreviousGBIFDownload A logical operator specifying whether the
#' user wishes to check their existing prepared downloads on the GBIF website.
#'
#' @return A list containing \enumerate{ \item a data frame of occurrence data;
#' \item GBIF search metadata; \item a data frame containing the raw results of
#'  a query to `rgbif::occ_download_get()`.}
#'
#' @examples
#' \dontrun{
#' getGBIFpoints(
#'   taxon = "Gadus morhua",
#'   GBIFLogin = myGBIFLogin,
#'   GBIFDownloadDirectory = NULL
#' )
#' }
#'
#' @export
getGBIFpoints <- function(taxon, GBIFLogin = GBIFLogin,
                          GBIFDownloadDirectory = NULL,
                          checkPreviousGBIFDownload = T) {

  # File hygene
  oldwd <- getwd()
  on.exit(setwd(oldwd))

  # Avoids errors when taxonomic authority includes special characters, i.e. "æ"
  cleanTaxon <- stringr::str_extract(
    string = taxon,
    pattern = "(\\w+\\s\\w+)"
  )

  tryCatch(expr = key <- rgbif::name_suggest(q = cleanTaxon,
                                             rank = "species")$data$key[1],
           error = function(e) {
             message(paste("GBIF unreachable at the moment, please try again later. \n"))
           })

  if(!exists("key")){
    return(invisible(NULL))
  }

  if (is.null(key)) {
    outlist <- list()
    outlist[[1]] <- data.frame()
    outlist[[2]] <- paste0("There was no taxonomic match for ", taxon, ".\n")
    outlist[[3]] <- data.frame()
    names(outlist) <- c("OccurrenceTable", "Metadata", "RawOccurrences")
    warning(paste0("There was no taxonomic match for ", taxon, ".\n"))
    return(outlist)
  }

  if (checkPreviousGBIFDownload) {
    occD <- prevGBIFdownload(key, GBIFLogin)
    if (is.null(occD)) {
      print(paste0(
        "There was no previously-prepared download on GBIF for ",
        taxon, ". New GBIF download will be prepared."
      ))
    }
  }

  if (checkPreviousGBIFDownload == F |
    (checkPreviousGBIFDownload == T && is.null(occD))) {
    tryCatch(expr = occD <- rgbif::occ_download(rgbif::pred("taxonKey", value = key),
                                                rgbif::pred("hasCoordinate", TRUE),
                                                rgbif::pred("hasGeospatialIssue", FALSE),
                                                user = GBIFLogin@username, email = GBIFLogin@email,
                                                pwd = GBIFLogin@pwd),
             error = function(e) {
               message(paste("GBIF unreachable at the moment, please try again later. \n"))
             })

    if(!exists("occD")){
      return(invisible(NULL))
    }

    print(paste0(
      "It is: ", format(Sys.time(), format = "%H:%M:%S"),
      ". Please be patient while GBIF prepares your download for ",
      taxon, ". This can take some time."
    ))
    tryCatch(expr = prepSuccess <- rgbif::occ_download_meta(occD[1])$status,
             error = function(e) {
               message(paste("GBIF unreachable at the moment, please try again later. \n"))
             })
    if(!exists("prepSuccess")){
      return(invisible(NULL))
    }
    while (prepSuccess != "SUCCEEDED") {
      rm(prepSuccess)
      Sys.sleep(60)
      print(paste(
        "Still waiting for", taxon,
        "download preparation to be completed. Time: ",
        format(Sys.time(), format = "%H:%M:%S")))
      tryCatch(expr = prepSuccess <- rgbif::occ_download_meta(occD[1])$status,
               error = function(e) {
                 message(paste("GBIF unreachable at the moment, please try again later. \n"))
               })
      if(!exists("prepSuccess")){
        return(invisible(NULL))
      }
    }
  }

  if (is.null(GBIFDownloadDirectory)) {
    GBIFDownloadDirectory <- getwd()
  }

  # Create folders for each species at the designated location
  fileTax <- gsub(pattern = " ", replacement = "_", x = taxon)
  dir.create(file.path(GBIFDownloadDirectory, fileTax),
    showWarnings = FALSE
  )
  presWD <- getwd()
  setwd(GBIFDownloadDirectory)

  # Getting the download from GBIF and loading it into R
  tryCatch(expr = res <- rgbif::occ_download_get(key = occD[1],
                                                 overwrite = TRUE,
                                                 file.path(getwd(),
                                                           fileTax)),
           error = function(e) {
             message(paste("GBIF unreachable at the moment, please try again later. \n"))
           })
  if(!exists("res")){
    return(invisible(NULL))
  }

  rawOccs <- res
  occFromGBIF <- tabGBIF(GBIFresults = res, taxon)

  tryCatch(expr = occMetadata <- rgbif::occ_download_meta(occD[1]),
           error = function(e) {
             message(paste("GBIF unreachable at the moment, please try again later. \n"))
           })

  if(!exists("occMetadata")){
    return(invisible(NULL))
  }

  # Preparing list for return
  outlist <- list()
  outlist[[1]] <- occFromGBIF
  outlist[[2]] <- occMetadata
  outlist[[3]] <- rawOccs
  names(outlist) <- c("OccurrenceTable", "Metadata", "RawOccurrences")

  setwd(presWD)
  return(outlist)
}
