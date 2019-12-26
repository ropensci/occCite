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
  d$DataService <- factor(d$DataService)

  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sp")

  d$label <- paste(paste("name:", d$name), paste("gbifID:", d$gbifID),
                   paste("longitude:", d$longitude), paste("latitude:", d$latitude),
                   paste0("day: ", d$day, ", month: ", d$month, ", year: ", d$year),
                   paste("dataset:", d$Dataset), paste("data service:", d$DataService), sep = "<br/>")
  d$label <- lapply(d$label, htmltools::HTML)

  # leaflet::setView(mean(d$longitude), mean(d$latitude), zoom = 1) %>%


  sp.names <- unique(d$name)
  cols <- c("red", "darkred", "lightred", "orange", "beige", "green", "darkgreen",
            "lightgreen", "blue", "darkblue", "lightblue", "purple", "darkpurple",
            "pink", "cadetblue", "white", "gray", "lightgray", "black")

  sp.cols <- as.list(sample(cols, length(sp.names)))
  names(sp.cols) <- sp.names
  d$col <- sapply(d$name, function(x) sp.cols[[x]])

  if(cluster == TRUE) {
    clusterOpts <- markerClusterOptions()
  }else{
    clusterOpts <- NULL
  }

  sp.icons <- lapply(sp.names, makeIconList)
  names(sp.icons) <- sp.names

  makeIconList <- function(sp) {
    leaflet::awesomeIconList(
      GBIF = leaflet::makeAwesomeIcon(icon = "globe", library = "fa", markerColor = sp.cols[[sp]]),
      BIEN = leaflet::makeAwesomeIcon(icon = "leaf", library = "fa", markerColor = sp.cols[[sp]])
    )
  }


  d2 <- d[c(1:50,900:925, 2000:2100),]


  m <- leaflet::leaflet(world) %>%
    addProviderTiles(leaflet::providers$Esri.WorldPhysical)
  for(i in sp.names) {
    sp.icons.i <- sp.icons[[i]]
    m <- m %>% leaflet::addAwesomeMarkers(data = d2 %>% dplyr::filter(name == i), ~longitude, ~latitude, label = ~label, icon = ~sp.icons.i[DataService], clusterOptions = clusterOpts)
  }
m
}



