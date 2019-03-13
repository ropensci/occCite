library(methods);

#' @title Study Taxon List
#'
#' @description Takes input phylogenies or vectors of taxon names, checks against taxonomic database, returns vector of cleaned taxonomic names (using \code{\link{taxonRectification}}) for use in spocc queries, as well as warnings if there are invalid names.
#'
#' @param x A phylogeny of class 'phylo' or a vector of class 'character' containing the names of taxa of interest
#'
#' @param datasources A vector of taxonomic datasources implemented in \code{\link{gnr_resolve}}. See the \href{http://gni.globalnames.org/}{Global Names List} for more information.
#'
#' @return An object of class \code{\link{occCiteData}} containing the type of inquiry the user has made --a phylogeny or a vector of names-- and a dataframe containing input taxa names, the closeset match according to \code{\link{gnr_resolve}}, and a list of taxonomic datasources that contain the matching name.
#'
#' @examples
#' ## Inputting a phylogeny
#' \dontrun{
#' ## Inputting a vector of taxon names
#' studyTaxonList(x = c("Buteo buteo",
#'                      "Buteo buteo hartedi",
#'                      "Buteo japonicus"),
#'                      datasources = c('NCBI', 'EOL'));
#'
#' ## Inputting a phylogeny
#' studyTaxonList(x = phylogeny, datasources = c('NCBI', 'EOL'));
#'}
#'
#' @export

studyTaxonList <- function(x = NULL, datasources = c('NCBI', 'EOL')) {
  #Error check inputs (x).
  if (!class(x) == "phylo" & !(is.vector(class(x))&&class(x)=="character")){
    warning("Target input invalid. Input must be of class 'phylo' or a vector of class 'character'.\n");
    return(NULL);
  }
  else if(is.vector(class(x))&&class(x)=="character"){
    targets <- x;
    dataFrom <- "User-supplied list of taxa." #Keeping track of metadata
  }
  else if(class(x) == "phylo"){
    targets <- x$tip.label;
    dataFrom <- "User-supplied phylogeny." #Keeping track of metadata
  }

  #Building the results table
  resolvedNames <- data.frame();
  count <- 1;
  while(count <= length(targets)){
    resolvedNames <- rbind(resolvedNames, taxonRectification(taxName = targets[[count]], datasources = datasources));
    count <- count + 1;
  }

  colnames(resolvedNames) <- c("Input Name", "Best Match", "Taxonomic Databases w/ Matches");
  resolvedNames <- as.data.frame(resolvedNames);

  #Populating an instance of class occCiteData
  occCiteInstance <- methods::new("occCiteData", userQueryType = dataFrom, userSpecTaxonomicSources = datasources, cleanedTaxonomy = resolvedNames);
  return(occCiteInstance);
}
