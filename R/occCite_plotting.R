#' @title Tabulate occurrence results
#'
#' @description This is a helper function that tabulates `occCiteData`
#' objects for use by map.occCite and `sumFig.occCite`.
#'
#' @param x One species' worth of results from an `occCiteData` object
#'
#' @param sp.name A character string that is a species name from `x`
#'
#' @return A table that can be more easily mapped and used
#' for summary plots.
#'
#' @examples
#' \donttest{
#' tableForPlot <- tabulate.occResults(occCiteDataResults, "Protea cynaroides")
#'}
#'
tabulate.occResults <- function(x, sp.name) {
  occTbls <- lapply(x, function(db) db$OccurrenceTable)
  occTbls.nulls <- sapply(occTbls, is.null)
  occTbls.char <- lapply(occTbls[!occTbls.nulls], function(tbl)
    tbl %>% dplyr::mutate_if(is.factor, as.character)
                         %>% dplyr::mutate(name = sp.name))
  occTbls.bind <- dplyr::bind_rows(occTbls.char)
  return(occTbls.bind)
}

#' @title Generating a map of downloaded points
#'
#' @description Makes maps for each individual species in an occCite
#' data object.
#'
#' @param occCiteData An object of class \code{\link{occCiteData}} to
#' map.
#'
#' @param cluster Logical; setting to `TRUE` turns on marker clustering.
#'
#' @return A GBIF download key, if one is available
#'
#' @examples
#' \donttest{
#' map.occCite(occCiteData, cluster = FALSE)
#'}
#'
#' @importFrom magrittr "%>%"
#'
#' @export
#'

map.occCite <- function(occCiteData, cluster = FALSE) {

  #Error check input.
  if (!class(occCiteData)=="occCiteData"){
    warning("Input is not of class 'occCiteData'.\n");
    return(NULL);
  }

  d.res <- occCiteData@occResults
  d.tbl <- lapply(1:length(d.res), function(x) tabulate.occResults(d.res[[x]], names(d.res)[x]))

  d <- dplyr::bind_rows(d.tbl)
  d$Dataset[d$Dataset==""] <- "Dataset not specified"

  d$label <- paste(paste("name:", d$name),
                   paste("longitude:", d$longitude), paste("latitude:", d$latitude),
                   paste0("day: ", d$day, ", month: ", d$month, ", year: ", d$year),
                   paste("dataset:", d$Dataset), paste("data service:", d$DataService), sep = "<br/>")
  d$label <- lapply(d$label, htmltools::HTML)

  # leaflet::setView(mean(d$longitude), mean(d$latitude), zoom = 1) %>%

  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sp")

  sp.names <- unique(d$name)
  cols <- viridis::viridis(length(sp.names))

  sp.cols <- as.list(sample(cols, length(sp.names)))
  names(sp.cols) <- sp.names
  d$col <- sapply(d$name, function(x) sp.cols[[x]])

  if(cluster == TRUE) {
    clusterOpts <- leaflet::markerClusterOptions()
  }else{
    clusterOpts <- NULL
  }

  leaflet::leaflet(world) %>%
    leaflet::addProviderTiles(leaflet::providers$Esri.WorldPhysical) %>%
    leaflet::addCircleMarkers(data = d, ~longitude, ~latitude, label = ~label, color = ~col, radius = 2, clusterOptions = clusterOpts)
}

#' @title Generating summary figures for occCite search results
#'
#' @description Generates up to three different kinds of plots,
#' with toggles determining whether plots should be done for
#' individual species or aggregating all species--histogram
#' by year of occurrence records, waffle::waffle plot of primary
#' data sources, waffle::waffle plot of data aggregators.
#'
#' @param occCiteData An object of class \code{\link{occCiteData}} to
#' map.
#'
#' @param bySpecies Logical; setting to `TRUE` generates the desired
#' plots for each species.
#'
#' @param plotTypes The type of plot to be generated; "yearHistogram",
#' "sourcePie", and/or "aggregatorPie".
#'
#' @return A list containing the desired plots.
#'
#' @examples
#' \donttest{
#' sumFig.occCite(occCiteData,
#' bySpecies = FALSE,
#' plotType = c("yearHistogram", "sourcePie", "aggregatorPie"))
#'}
#'
#' @importFrom ggplot2 ggplot aes geom_histogram ggtitle theme xlab ylab theme_classic scale_y_continuous ggplot_build element_text
#'
#' @export
#'
sumFig.occCite <- function (occCiteData, bySpecies = FALSE, plotTypes = c("yearHistogram", "source", "aggregator")){
  #Error check input.
  if (!class(occCiteData)=="occCiteData"){
    warning("Input is not of class 'occCiteData'.\n");
    return(NULL);
  }

  if (!is.logical(bySpecies)){
    warning("The bySpecies argument must be TRUE or FALSE.")
    return(NULL);
  }

  plots <- c("yearHistogram", "source", "aggregator")
  if(sum(!plotTypes %in% plots) > 0){
    warning(paste0("The following plot types are not implemented in sumFig.occCite: ",
                   plotTypes[!plotTypes %in% plots]));
    return(NULL)
  }
  else if(is.null(plotTypes)){#Fills in NULL
    plotTypes <- plots;
  }

  d.res <- occCiteData@occResults
  d.tbl <- lapply(1:length(d.res), function(x) tabulate.occResults(d.res[[x]], names(d.res)[x]))

  d <- dplyr::bind_rows(d.tbl)
  d$Dataset[d$Dataset==""] <- "Dataset not specified"

  if(!bySpecies){
    allPlots <- vector(mode = "list", length = length(plotTypes))
    if("yearHistogram" %in% plotTypes){
      yearHistogram <- d %>%
        ggplot( aes(x=year)) +
        geom_histogram( binwidth= (max(d$year)-min(d$year))/10, fill="black", color="white", alpha=0.9) +
        ggtitle("All Occurrence Records by Year") +
        theme(plot.title = element_text(size=15)) +
        xlab("Year") +
        ylab("Count") +
        theme_classic(base_size = 15) +
        scale_y_continuous(expand = c(0, 0))
      yearHistogram <- ggplot_build(yearHistogram)
      allPlots[[1]] <- yearHistogram
    }
    if("source" %in% plotTypes){
      datasetTab <- sort(table(d$Dataset), decreasing = T)
      pct <- round(datasetTab/sum(datasetTab)*100)
      lbls <- names(datasetTab)
      lbls <- paste(lbls, pct) # add percents to labels
      lbls <- paste(lbls,"%",sep="") # ad % to labels
      names(pct) <- lbls
      pct <- pct[pct > 1]
      if(sum(pct) < 100){
        pct["Other*"] <- (100 - sum(pct))
        source <- waffle::waffle(pct, rows = 10, colors = viridis::viridis(length(pct)),
                         title = "All Occurrence Records by Primary Data Source",
                         xlab = "*Sources contributing <2% not shown.")
      }
      else{
        source <- waffle::waffle(pct, rows = 10, colors = viridis::viridis(length(pct)),
                         title = "All Occurrence Records by Primary Data Source")
      }
      source <- ggplot_build(source)
      if ("yearHistogram" %in% plotTypes){
        allPlots[[2]] <- source
      }
      else{
        allPlots[[1]] <- source
      }
    }
    if("aggregator" %in% plotTypes){
      datasetTab <- sort(table(d$DataService), decreasing = T)
      pct <- round(datasetTab/sum(datasetTab)*100)
      lbls <- names(datasetTab)
      lbls <- paste(lbls, pct) # add percents to labels
      lbls <- paste(lbls,"%",sep="") # ad % to labels
      names(pct) <- lbls
      aggregator <- waffle::waffle(pct, rows = 10, colors = viridis::viridis(length(datasetTab)),
             title = "All Occurrence Records by Data Aggregator")
      aggregator <- ggplot_build(aggregator)
      allPlots[[length(allPlots)]] <- aggregator
    }
    names(allPlots) <- plotTypes
    return(allPlots)
  }
  else{
    spList <- unique(d$name)
    spPlotList <- vector(mode = "list", length = length(spList))
    for (sp in spList){
      allPlots <- vector(mode = "list", length = length(plotTypes))
      sub.d <- d[d$name == sp,]
      if("yearHistogram" %in% plotTypes){
        yearHistogram <- sub.d %>%
          ggplot(aes(x=year)) +
          geom_histogram( binwidth= (max(sub.d$year)-min(sub.d$year))/10,
                          fill="black", color="white", alpha=0.9) +
          ggtitle(paste0(sp, " Occurrence Records by Year")) +
          theme(plot.title = element_text(size=15)) +
          xlab("Year") +
          ylab("Count") +
          theme_classic(base_size = 15) +
          scale_y_continuous(expand = c(0, 0))
        yearHistogram <- ggplot_build(yearHistogram)
        allPlots[[1]] <- yearHistogram
      }
      if("source" %in% plotTypes){
        datasetTab <- sort(table(sub.d$Dataset), decreasing = T)
        pct <- round(datasetTab/sum(datasetTab)*100)
        lbls <- names(datasetTab)
        lbls <- paste(lbls, pct) # add percents to labels
        lbls <- paste(lbls,"%",sep="") # ad % to labels
        names(pct) <- lbls
        pct <- pct[pct > 1]
        if(sum(pct) < 100){
          pct["Other*"] <- (100 - sum(pct))
          source <- waffle::waffle(pct, rows = 10, colors = viridis::viridis(length(pct)),
                           title = paste0(sp, " Occurrence Records by Primary Data Source"),
                           xlab = "*Sources contributing <2% not shown.")
        }
        else{
          source <- waffle::waffle(pct, rows = 10, colors = viridis::viridis(length(pct)),
                         title = paste0(sp, " Occurrence Records by Primary Data Source"))
        }
        source <- ggplot_build(source)
        if ("yearHistogram" %in% plotTypes){
          allPlots[[2]] <- source
        }
        else{
          allPlots[[1]] <- source
        }
      }
      if("aggregator" %in% plotTypes){
        datasetTab <- sort(table(sub.d$DataService), decreasing = T)
        pct <- round(datasetTab/sum(datasetTab)*100)
        lbls <- names(datasetTab)
        lbls <- paste(lbls, pct) # add percents to labels
        lbls <- paste(lbls,"%",sep="") # ad % to labels
        names(pct) <- lbls
        aggregator <- waffle::waffle(pct, rows = 10, colors = viridis::viridis(length(datasetTab)),
               title = paste0(sp, " Occurrences by Data Aggregator"))
        aggregator <- ggplot_build(aggregator)
        allPlots[[length(allPlots)]] <- aggregator
      }
      names(allPlots) <- plotTypes
      spPlotList[[match(sp, spList)]] <- allPlots
    }
    names(spPlotList) <- spList
    return(spPlotList)
  }
}
