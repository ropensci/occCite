library(BIEN);
library(lubridate);

#' @title Download occurrence points from BIEN
#'
#' @description Downloads occurrence points and useful related information for processing within other occCite functions
#'
#' @param taxon A single plant species or vector of plant species
#'
#' @param limit An optional argument that limits the number of records returned to n. Note: This will return the FIRST n records, and will likely be a very biased sample.
#'
#' @return A list containing (1) a dataframe of occurrence data; (2) a list containing: i notes on usage, ii bibtex citations, and iii aknowledgement information.
#'
#' @examples
#' getBIENpoints(taxon="Acer rubrum", limit = NULL);
#'
#' @export
getBIENpoints<-function(taxon, limit = NULL){
  occs<-BIEN::BIEN_occurrence_species(species = taxon,cultivated = T,
                                  only.new.world = F, native.status = T,
                                  collection.info = T,natives.only = F);

  if(nrow(occs)==0){
    print(paste("There are no BIEN points for ", taxon, ". Are you sure it's a plant?", sep = ""));
    return(NULL);
  }

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

  if (is.null(limit)){
    limit <- nrow(outdata);
  }

  outdata <- as.data.frame(outdata)[1:min(limit,nrow(outdata)),];

  if (nrow(outdata)<limit){
    print(paste("Note: For ", taxon, ", there are fewer occurrences (", nrow(outdata), ") than the stipulated limit (", limit, ").", sep = ""))
  }

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
  names(outlist) <- c("OccurrenceTable", "Metadata")

  return(outlist);
}
