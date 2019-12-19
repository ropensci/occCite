library(rnaturalearth)
library(leaflet)

map.occCite <- function(occCiteData) {

  mapTbl <- function(x) {
    occTbls <- lapply(x, function(db) db$OccurrenceTable)
   dplyr::bind_rows(occTbls)
  }

  d <- occCiteData@occResults
  lapply(d, mapTbl)

  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sp")

  d <- mySimpleOccCiteObject@occResults$`Protea cynaroides`
  lapply()
  d$BIEN$OccurrenceTable
  d$label <- paste(paste("name:", d$name), paste("gbifID:", d$gbifID),
                   paste("longitude:", d$longitude), paste("latitude:", d$latitude),
                   paste0("day: ", d$day, ", month: ", d$month, ", year: ", d$year),
                   paste("dataset:", d$Dataset), paste("data service:", d$DataService), sep = "<br/>")
  d$label <- lapply(d$label, htmltools::HTML)

  # leaflet::setView(mean(d$longitude), mean(d$latitude), zoom = 1) %>%

  leaflet::leaflet(world) %>%
    addProviderTiles(leaflet::providers$Esri.WorldPhysical) %>%
    leaflet::addCircles(data = d, ~longitude, ~latitude, label = ~label)
}



