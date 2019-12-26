#' @export

map.occCite <- function(occCiteData, by_species = "all", species_colors = NULL, cluster = FALSE, map_limit = 1000) {

  # checks
  if()

  mapTbl <- function(x, sp.name) {
    occTbls <- lapply(x, function(db) db$OccurrenceTable)
    occTbls.nulls <- sapply(occTbls, is.null)
    occTbls.char <- lapply(occTbls[!occTbls.nulls], function(tbl) tbl %>% dplyr::mutate_if(is.factor, as.character) %>% dplyr::mutate(name = sp.name))
    occTbls.bind <- dplyr::bind_rows(occTbls.char)
    message(paste0("Number of occurrences for ", sp.name, " exceeds limit of ", map_limit, ", so mapping first ", map_limit, " occurrences..."))
    if(nrow(occTbls.bind > map_limit)) {
      occTbls.bind <- occTbls.bind[1:map_limit,]
    }
    return(occTbls.bind)
  }

  d.res <- occCiteData@occResults
  if(by_species != "all") d.res <- d.res[names(d.res) == by_species]
  d.tbl <- lapply(1:length(d.res), function(x) mapTbl(d.res[[x]], names(d.res)[x]))
  d <- dplyr::bind_rows(d.tbl)
  d$DataService <- factor(d$DataService)

  d$label <- paste(paste("name:", d$name), paste("gbifID:", d$gbifID),
                   paste("longitude:", d$longitude), paste("latitude:", d$latitude),
                   paste0("day: ", d$day, ", month: ", d$month, ", year: ", d$year),
                   paste("dataset:", d$Dataset), paste("data service:", d$DataService), sep = "<br/>")
  d$label <- lapply(d$label, htmltools::HTML)

  sp.names <- unique(d$name)
  cols <- c("red", "darkred", "lightred", "orange", "beige", "green", "darkgreen",
            "lightgreen", "blue", "darkblue", "lightblue", "purple", "darkpurple",
            "pink", "cadetblue", "white", "gray", "lightgray", "black")

  if(is.null(species_colors)) {
    species_colors <- as.list(sample(cols, length(sp.names)))
  }
  names(species_colors) <- sp.names

  d$col <- sapply(d$name, function(x) species_colors[[x]])

  if(cluster == TRUE) {
    clusterOpts <- markerClusterOptions()
  }else{
    clusterOpts <- NULL
  }

  makeIconList <- function(sp) {
    leaflet::awesomeIconList(
      GBIF = leaflet::makeAwesomeIcon(icon = "globe", library = "fa", markerColor = species_colors[[sp]]),
      BIEN = leaflet::makeAwesomeIcon(icon = "leaf", library = "fa", markerColor = species_colors[[sp]])
    )
  }

  sp.icons <- lapply(sp.names, makeIconList)
  names(sp.icons) <- sp.names

  m <- leaflet::leaflet() %>%
    addProviderTiles(leaflet::providers$Esri.WorldPhysical)
  if(by_species == "all") {
    for(i in sp.names) {
      sp.icons.i <- sp.icons[[i]]
      m <- m %>% leaflet::addAwesomeMarkers(data = d %>% dplyr::filter(name == i), ~longitude, ~latitude,
                                            label = ~label, icon = ~sp.icons.i[DataService], clusterOptions = clusterOpts)
    }
  }else{
    sp.icons.i <- sp.icons[[by_species]]
    m <- m %>% leaflet::addAwesomeMarkers(data = d %>% dplyr::filter(name == by_species), ~longitude, ~latitude,
                                          label = ~label, icon = ~sp.icons.i[DataService], clusterOptions = clusterOpts)
  }

  m
}



