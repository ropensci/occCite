#' @title Download previously-prepared GBIF datasets
#'
#' @description Searches the list of a user's previous downloads on the
#' GBIF servers and returns the dataset key for the most recently prepared
#' download.
#'
#' @param taxonKey A taxon key as returned from `rgbif::name_suggest()`.
#'
#' @param GBIFLogin An object of class \code{\link{GBIFLogin}} to log in to
#' GBIF to begin the download.
#'
#' @return A GBIF download key, if one is available
#'
#' @examples
#' \dontrun{
#' GBIFLogin <- GBIFLoginManager(user = "theWoman",
#'                email = "ireneAdler@@laScala.org",
#'                pwd = "sh3r");
#' taxKey <- rgbif::name_suggest(q= "Protea cynaroides", rank='species')$key[1]
#' prevGBIFdownload(taxonKey = taxKey,
#'               GBIFLogin = myGBIFLogin);
#'}
#'
#' @export
#'
prevGBIFdownload <- function(taxonKey, GBIFLogin){
  dl <- rgbif::occ_download_list(user= GBIFLogin@username, pwd = GBIFLogin@pwd, limit = 1000);
  recKey <- NULL;
  retmat <- NULL;
  for(i in 1:dim(dl$results)[1]){
    if(!is.na(dl$results$request.predicate.key[i]) &
       dl$results$request.predicate.key[i]=="TAXON_KEY"){
      recKey <- dl$results$request.predicate.value[i];
    } else if (any(dl$results$request.predicate.predicates[[i]]$key=="TAXON_KEY")) {
      recKey <- dl$results$request.predicate.predicates[[i]][
        dl$results$request.predicate.predicates[[i]]$key=="TAXON_KEY",]$value;
    }
    if(taxonKey %in% recKey){
      retmat <- rbind(retmat,dl$results[i,]);
    }
  }
  if (is.null(retmat)){
    return(NULL);
  }
  else{
    return(retmat[retmat$modified == rev(sort(retmat$modified))[1],]$key);
  }
}
