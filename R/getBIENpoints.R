library(BIEN);
library(lubridate);

#' @title Download occurrence points from BIEN
#'
#' @description Downloads occurrence points and useful related information for processing within other occCite functions
#'
#' @param taxon A single plant species or vector of plant species
#'
#' @return A list containing (1) a dataframe of occurrence data; (2) a list containing: i notes on usage, ii bibtex citations, and iii acknowledgement information; (3) a dataframe containing the raw results of a query to `BIEN::BIEN_occurrence_species()`.
#'
#' @examples
#' \dontrun{
#' getBIENpoints(taxon="Acer rubrum", limit = NULL);
#'}
#' @import lubridate
#'
#' @export
getBIENpoints<-function(taxon){
  occs<-BIEN::BIEN_occurrence_species(species = taxon,cultivated = T,
                                  only.new.world = F, native.status = T,
                                  collection.info = T,natives.only = F);

  if(nrow(occs)==0){
    print(paste("There are no BIEN points for ", taxon, ". Are you sure it's a plant?", sep = ""));
    return(NULL);
  }

  rawOccs <- occs;
  occs<-occs[which(!is.na(occs$latitude) & !is.na(occs$longitude)),];

  #Fixing dates
  occs <-occs[which(!is.na(occs$date_collected)),];
  occs$date_collected <- lubridate::ymd(occs$date_collected);
  yearCollected <- as.numeric(format(occs$date_collected, format = "%Y"))
  monthCollected <- as.numeric(format(occs$date_collected, format = "%m"))
  dayCollected <- as.numeric(format(occs$date_collected, format = "%d"))
  occs <- cbind(occs, dayCollected, monthCollected, yearCollected)

  #Tidying up data table
  outdata<-occs[c('scrubbed_species_binomial',
                  'longitude','latitude','dayCollected', 'monthCollected',
                  'yearCollected', 'dataset','datasource_id')];
  dataService <- rep("BIEN", nrow(outdata));
  outdata <- cbind(outdata, dataService);

  colnames(outdata) <- c("name", "longitude",
                         "latitude", "day", "month",
                         "year", "Dataset",
                         "DatasetKey", "DataService");

  #Get metadata
  occMetadata <- BIEN::BIEN_metadata_citation(occs);
  occMetadata$license<-"CC BY-NC-ND";
  occMetadata$warnings <-

  #Package it all up
  outlist<-list();
  outlist[[1]]<-outdata;
  outlist[[2]]<-occMetadata;
  outlist[[3]]<-rawOccs;
  names(outlist) <- c("OccurrenceTable", "Metadata", "RawOccurrences")

  return(outlist);
}
