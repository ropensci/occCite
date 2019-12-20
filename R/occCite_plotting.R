library(rnaturalearth)
library(leaflet)

map.occCite <- function(occCiteData, cluster = FALSE) {

  mapTbl <- function(x, sp.name) {
    occTbls <- lapply(x, function(db) db$OccurrenceTable)
    occTbls.nulls <- sapply(occTbls, is.null)
    occTbls.char <- lapply(occTbls[!occTbls.nulls], function(tbl) tbl %>% dplyr::mutate_if(is.factor, as.character) %>% dplyr::mutate(name = sp.name))
    occTbls.bind <- dplyr::bind_rows(occTbls.char)
    return(occTbls.bind)
  }

  d.res <- occCiteData@occResults
  d.tbl <- lapply(1:length(d.res), function(x) mapTbl(d.res[[x]], names(d.res)[x]))
  d <- dplyr::bind_rows(d.tbl)

  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sp")

  d$label <- paste(paste("name:", d$name), paste("gbifID:", d$gbifID),
                   paste("longitude:", d$longitude), paste("latitude:", d$latitude),
                   paste0("day: ", d$day, ", month: ", d$month, ", year: ", d$year),
                   paste("dataset:", d$Dataset), paste("data service:", d$DataService), sep = "<br/>")
  d$label <- lapply(d$label, htmltools::HTML)

  # leaflet::setView(mean(d$longitude), mean(d$latitude), zoom = 1) %>%


  sp.names <- unique(d$name)
  cols <- RColorBrewer::brewer.pal(9, "Set1")

  sp.cols <- as.list(sample(cols, length(sp.names)))
  names(sp.cols) <- sp.names
  d$col <- sapply(d$name, function(x) sp.cols[[x]])

  if(cluster == TRUE) {
    clusterOpts <- markerClusterOptions()
  }else{
    clusterOpts <- NULL
  }

  leaflet::leaflet(world) %>%
    addProviderTiles(leaflet::providers$Esri.WorldPhysical) %>%
    leaflet::addCircleMarkers(data = d, ~longitude, ~latitude, label = ~label, color = ~col, radius = 2, clusterOptions = clusterOpts)
}



