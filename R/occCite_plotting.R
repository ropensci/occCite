#' @title Tabulate occurrence results
#'
#' @description This is a helper function that tabulates `occCiteData`
#' objects for use by occCiteMap and `plot`.
#'
#' @param x One species' worth of results from an `occCiteData` object
#'
#' @param sp.name A character string that is a species name from `x`
#'
#' @return A table that can be more easily mapped and used
#' for summary plots.
#'
#' @keywords internal
#'
#' @examples
#' data(myOccCiteObject)
#' tabulate.occResults(myOccCiteObject@occResults,
#'   sp.name = "Protea cynaroides"
#' )
#' @importFrom dplyr "%>%" mutate_if mutate bind_rows
#'
#' @noRd

tabulate.occResults <- function(x, sp.name) {
  sp.name <- stringr::str_extract(
    string = sp.name,
    pattern = "(\\w+\\s\\w+)"
  )
  occTbls <- lapply(x, function(db) db$OccurrenceTable)
  occTbls.nulls <- sapply(occTbls, is.null)
  occTbls.char <- lapply(occTbls[!occTbls.nulls], function(tbl) {
    tbl %>%
      mutate_if(is.factor, as.character) %>%
      mutate(name = sp.name)
  })
  occTbls.bind <- dplyr::bind_rows(occTbls.char)
  return(occTbls.bind)
}

#' @title Generating a map of downloaded points
#'
#' @description Makes maps for each individual species in an
#' \code{\link{occCiteData}} object.
#'
#' @param occCiteData An object of class \code{\link{occCiteData}} to map
#'
#' @param species_map Character; either the default "all" to map all species
#' in \code{\link{occCiteData}}, or a subset of these specified as a character
#' or character vector.
#'
#' @param species_colors Character; the default NULL will choose random
#' colors from those available (see Details), or those specified by the
#' user as a character or character vector (the number of colors must match
#' the number of species mapped).
#'
#' @param ds_map Character; specifies which data service records will be
#' mapped, with the default being GBIF, BIEN, and GBIF_BIEN (records with
#' the same coordinates in both databases).
#'
#' @param map_limit Numeric; the number of points to map per species, set
#' at a default of 1000 randomly selected records; users can specify a
#' higher number, but be aware that leaflet can lag or crash when too many
#' points are plotted.
#'
#' @param awesomeMarkers Logical; if `TRUE` (default), mapped points will
#' be `awesomeMarkers` attributed with an icon for a globe for GBIF, a leaf
#' for BIEN, or a database if records from both databases have the same
#' coordinates; if `FALSE`, mapped points will be leaflet `circleMarkers`
#'
#' @param cluster Logical; if `TRUE` (default is `FALSE`) turns on marker
#' clustering, which does not preserve color differences between species
#'
#' @details When mapping using `awesomeMarkers` (default), the parameter
#' species_colors must match those in a specified color library, currently:
#' c("red", "lightred", "orange", "beige", "green", "lightgreen", "blue",
#' "lightblue", "purple", "pink", "cadetblue", "white", "gray", "lightgray").
#' When `awesomeMarkers` is `FALSE` and species_colors are not specified,
#' random colors from the `RColorBrewer` Set1 palette are used.
#'
#' @return A leaflet map
#'
#' @examples
#' \dontrun{
#' data(myOccCiteObject)
#' occCiteMap(myOccCiteObject, cluster = FALSE)
#' }
#'
#' @importFrom dplyr "%>%" filter
#' @importFrom rlang .data
#' @importFrom stats complete.cases
#' @importFrom RColorBrewer brewer.pal
#' @import leaflet
#'
#' @export
#'

occCiteMap <- function(occCiteData,
                       species_map = "all",
                       species_colors = NULL,
                       ds_map = c("GBIF", "BIEN"),
                       map_limit = 1000,
                       awesomeMarkers = TRUE,
                       cluster = FALSE) {

  # color library
  awesomeMarkers.cols <- c(
    "red", "lightred", "orange", "beige", "green",
    "lightgreen", "blue", "lightblue", "purple",
    "pink", "cadetblue", "white", "gray", "lightgray"
  )

  # Error check input.
  if (!is(occCiteData, class2 = "occCiteData")) {
    warning("Input is not of class 'occCiteData'.\n")
    return(NULL)
  }

  if (!(all(ds_map %in% c("GBIF", "BIEN", "GBIF_BIEN")))) {
    stop(paste0('Input for ds_map must be one, or all of:\n",
                "GBIF", "BIEN", "GBIF_BIEN".'))
  }

  d.res <- occCiteData@occResults
  sp.names <- stringr::str_extract(
    string = names(d.res),
    pattern = "(\\w+\\s\\w+)"
  )
  if (!"all" %in% species_map) d.res <- d.res[match(species_map, sp.names)]

  if (!is.null(species_colors)) {
    if (length(species_colors) != length(sp.names)) {
      stop(paste0(
        "Number of species colors provided must\n",
        "match number of species mapped."
      ))
    }
    if (awesomeMarkers == TRUE & !all(species_colors %in%
      awesomeMarkers.cols)) {
      stop(paste0(
        "If mapping awesomeMarkers, please specify species\n",
        "colors from those available (see Details in ?occCiteMap)"
      ))
    }
  }

  d.tbl <- lapply(
    1:length(d.res),
    function(x) tabulate.occResults(d.res[[x]], names(d.res)[x])
  )
  for (i in 1:length(d.tbl)) {
    if (nrow(d.tbl[[i]]) > 0) {
      d.tbl[[i]] <- d.tbl[[i]][complete.cases(d.tbl[[1]][
        ,
        c(
          "longitude",
          "latitude"
        )
      ]), ]
    }
    d.tbl.n <- nrow(d.tbl[[i]])
    if (d.tbl.n > map_limit) {
      message(paste0(
        "Number of occurrences for ",
        sp.names[i], " exceeds limit of ",
        map_limit,
        ", so mapping a random sample of ",
        map_limit,
        " occurrences..."
      ))
      d.tbl[[i]] <- d.tbl[[i]][sample(1:d.tbl.n, map_limit), ]
    }
    if (d.tbl.n == 0) {
      d.tbl[[i]] <- NULL
    }
  }
  d.tbl <- d.tbl[lengths(d.tbl) != 0]
  if (length(d.tbl) == 0) {
    warning("No occurrences exist in this occCite object.")
    return(NULL)
  }

  d <- dplyr::bind_rows(d.tbl)

  d$datasetName[d$datasetName == ""] <- "Dataset not specified"

  # remove coordinate duplicates with same data service
  longitude <- NULL # Cheat to silence R CMD check
  latitude <- NULL # Cheat to silence R CMD check
  d <- dplyr::distinct(d, longitude, latitude,
    dataService,
    .keep_all = TRUE
  )

  d$label <- paste(paste("name:", d$name),
    paste("longitude:", d$longitude),
    paste("latitude:", d$latitude),
    paste0(
      "day: ", d$day, ", month: ",
      d$month, ", year: ", d$year
    ),
    paste("dataset:", d$datasetName),
    paste(
      "data service:", d$dataService,
      "<br/><br/>"
    ),
    sep = "<br/>"
  )
  d$label <- lapply(d$label, htmltools::HTML)
  d$dataService <- factor(d$dataService)

  if (awesomeMarkers == TRUE) {
    cols <- awesomeMarkers.cols
  } else {
    cols <- RColorBrewer::brewer.pal(9, "Set1")
  }

  if (is.null(species_colors)) {
    sp.cols <- as.list(sample(cols, length(sp.names)))
  } else {
    sp.cols <- species_colors
  }
  names(sp.cols) <- sp.names

  d.nest <- tidyr::nest(d, data = -c("longitude", "latitude", "name"))
  d.nest.ds <- lapply(d.nest$data, function(x) as.character(x$dataService))
  if (length(ds_map) > 1 | all(ds_map == "GBIF_BIEN")) {
    d.nest.dsBoth <- which(sapply(d.nest.ds, length) == 2)
    d.nest.ds[d.nest.dsBoth] <- "GBIF_BIEN"
  }
  d.nest$dataService <- d.nest.ds
  dataService <- NULL # Cheat to silence R CMD check
  d.nest <- d.nest %>%
    tidyr::unnest(dataService) %>%
    dplyr::mutate(dataService = factor(dataService))
  if (length(ds_map) == 1) {
    d.nest <- d.nest[dataService %in% ds_map, ]
  }
  labs.lst <- lapply(sp.names, function(x) {
    lapply(
      d.nest[d.nest$name == x, ]$data,
      function(y) htmltools::HTML(unlist(y$label))
    )
  })
  names(labs.lst) <- sp.names

  if (cluster == TRUE) {
    clusterOpts <- leaflet::markerClusterOptions()
  } else {
    clusterOpts <- NULL
  }

  m <- leaflet::leaflet() %>%
    leaflet::addProviderTiles(leaflet::providers$Esri.WorldPhysical)

  if (awesomeMarkers == TRUE) {
    makeIconList <- function(sp) {
      leaflet::awesomeIconList(
        GBIF = leaflet::makeAwesomeIcon(
          icon = "globe",
          library = "fa",
          markerColor = sp.cols[[sp]]
        ),
        BIEN = leaflet::makeAwesomeIcon(
          icon = "leaf",
          library = "fa",
          markerColor = sp.cols[[sp]]
        ),
        GBIF_BIEN = leaflet::makeAwesomeIcon(
          icon = "database",
          library = "fa",
          markerColor = sp.cols[[sp]]
        )
      )
    }
    sp.icons <- lapply(sp.names, makeIconList)
    names(sp.icons) <- sp.names
    for (i in sp.names) {
      d.nest.i <- d.nest %>% dplyr::filter(.data$name == i)
      if (nrow(d.nest.i) == 0) next
      sp.icons.i <- sp.icons[[i]]
      labs.lst.i <- labs.lst[[i]]
      m <- m %>% leaflet::addAwesomeMarkers(
        data = as.data.frame(d.nest) %>% dplyr::filter(.data$name == i),
        ~longitude, ~latitude,
        label = ~labs.lst.i,
        icon = ~ sp.icons.i[dataService],
        clusterOptions = clusterOpts
      )
    }
  } else {
    for (i in sp.names) {
      d.nest.i <- d.nest %>% dplyr::filter(.data$name == i)
      if (nrow(d.nest.i) == 0) next
      sp.cols.i <- sp.cols[[i]]
      labs.lst.i <- labs.lst[[i]]
      m <- m %>% leaflet::addCircleMarkers(
        data = as.data.frame(d.nest) %>% dplyr::filter(.data$name == i),
        ~longitude, ~latitude,
        label = ~labs.lst.i,
        color = "black",
        fillColor = ~sp.cols.i,
        weight = 2,
        radius = 5,
        fill = TRUE,
        fillOpacity = 0.5,
        clusterOptions = clusterOpts
      )
    }
  }
  return(m)
}

#' @title Plotting summary figures for occCite search results
#'
#' @description Generates up to three different kinds of plots,
#' with toggles determining whether plots should be done for
#' individual species or aggregating all species--histogram
#' by year of occurrence records, waffle::waffle plot of primary
#' data sources, waffle::waffle plot of data aggregators.
#'
#' @param x An object of class \code{\link{occCiteData}} to
#' map.
#'
#' @param ... Additional arguments affecting how the formatted
#' citation document is produced.
#' `bySpecies`: Logical; setting to `TRUE` generates the desired
#' plots for each species.
#' `plotTypes`: The type of plot to be generated; "yearHistogram",
#' "source", and/or "aggregator".
#'
#' @return A list containing the desired plots.
#'
#' @examples
#' data(myOccCiteObject)
#' plot(
#'   x = myOccCiteObject, bySpecies = FALSE,
#'   plotTypes = c("yearHistogram", "source", "aggregator")
#' )
#' @importFrom ggplot2 ggplot aes geom_histogram ggtitle
#' @importFrom ggplot2 theme xlab ylab theme_classic
#' @importFrom ggplot2 scale_y_continuous ggplot_build element_text
#' @importFrom stats complete.cases
#' @importFrom methods is
#' @importFrom viridis viridis
#'
#' @method plot occCiteData
#' @export
#'
plot.occCiteData <- function(x, ...) {
  # Function to wrap labels
  occ_strwrap <- function(x) {
    x <- unlist(lapply(strwrap(x, width = 30, simplify = FALSE),
      paste,
      collapse = "\n"
    ))
    return(x)
  }

  args <- list(...)

  if ("bySpecies" %in% names(args)) {
    bySpecies <- args$bySpecies
  } else {
    bySpecies <- FALSE
  }

  if ("plotTypes" %in% names(args)) {
    plotTypes <- args$plotType
  } else {
    plotTypes <- c("yearHistogram", "source", "aggregator")
  }

  stopifnot(is(x, "occCiteData"))

  # Error check input.
  if (!is(x, "occCiteData")) {
    warning("Input is not of class 'occCiteData'.\n")
    return(NULL)
  }

  if (!is.logical(bySpecies)) {
    warning("The bySpecies argument must be TRUE or FALSE.")
    return(NULL)
  }

  plots <- c("yearHistogram", "source", "aggregator")
  if (sum(!plotTypes %in% plots) > 0) {
    warning(paste0(
      "The following plot types are not implemented in plot.occCite: ",
      plotTypes[!plotTypes %in% plots]
    ))
    return(NULL)
  } else if (is.null(plotTypes)) { # Fills in NULL
    plotTypes <- plots
  }

  d.res <- x@occResults
  d.tbl <- lapply(
    1:length(d.res),
    function(x) tabulate.occResults(d.res[[x]], names(d.res)[x])
  )
  for (i in 1:length(d.tbl)) {
    d.tbl[[i]] <- d.tbl[[i]][complete.cases(d.tbl[[1]][
      ,
      c(
        "longitude",
        "latitude"
      )
    ]), ]
    d.tbl.n <- nrow(d.tbl[[i]])
    if (d.tbl.n == 0) {
      d.tbl[[i]] <- NULL
    }
  }
  d.tbl <- d.tbl[lengths(d.tbl) != 0]
  if (length(d.tbl) == 0) {
    warning("No occurrences exist in this occCite object.")
    return(NULL)
  }

  d <- dplyr::bind_rows(d.tbl)
  d$datasetName[d$datasetName == ""] <- "Dataset not specified"
  d <- d[, c("name", "year", "datasetName", "dataService")]
  d <- d[complete.cases(d), ]

  if (!bySpecies) {
    allPlots <- vector(mode = "list", length = length(plotTypes))
    if ("yearHistogram" %in% plotTypes) {
      yearHistogram <- d %>%
        ggplot(aes(x = year)) +
        geom_histogram(
          binwidth = (max(d$year,
            na.rm = T
          ) - min(d$year,
            na.rm = T
          )) / 10,
          fill = "black", color = "white", alpha = 0.9, na.rm = T
        ) +
        ggtitle("All Occurrence Records by Year") +
        theme(plot.title = element_text(size = 15)) +
        xlab("Year") +
        ylab("Count") +
        theme_classic(base_size = 15) +
        scale_y_continuous(expand = c(0, 0))
      yearHistogram <- ggplot_build(yearHistogram)
      allPlots[[1]] <- yearHistogram
    }
    if ("source" %in% plotTypes) {
      datasetTab <- sort(table(d$datasetName), decreasing = T)
      pct <- round(datasetTab / sum(datasetTab) * 100)
      lbls <- names(datasetTab)
      lbls <- paste0(lbls, " ", pct) # add percents to labels
      lbls <- paste(lbls, "%", sep = "") # add % to labels
      lbls <- occ_strwrap(lbls)
      names(pct) <- lbls
      pct <- pct[pct > 1]
      if (sum(pct) < 100) {
        pct["Other*"] <- (100 - sum(pct))
        source <- waffle::waffle(pct,
          rows = 10,
          colors = viridis::viridis(length(pct)),
          title = "All Occurrence Records by Primary Data Source",
          xlab = "*Sources contributing <2% not shown."
        )
      } else {
        source <- waffle::waffle(pct,
          rows = 10,
          colors = viridis::viridis(length(pct)),
          title = "All Occurrence Records by Primary Data Source"
        )
      }
      source <- ggplot_build(source)
      if ("yearHistogram" %in% plotTypes) {
        allPlots[[2]] <- source
      } else {
        allPlots[[1]] <- source
      }
    }
    if ("aggregator" %in% plotTypes) {
      datasetTab <- sort(table(d$dataService), decreasing = T)
      pct <- round(datasetTab / sum(datasetTab) * 100)
      lbls <- names(datasetTab)
      lbls <- paste(lbls, pct) # add percents to labels
      lbls <- paste(lbls, "%", sep = "") # ad % to labels
      names(pct) <- lbls
      aggregator <- waffle::waffle(pct,
        rows = 10,
        colors = viridis::viridis(length(datasetTab)),
        title = "All Occurrence Records by Data Aggregator"
      )
      aggregator <- ggplot_build(aggregator)
      allPlots[[length(allPlots)]] <- aggregator
    }
    names(allPlots) <- plotTypes
    return(allPlots)
  } else {
    spList <- unique(d$name)
    spList <- spList[!is.na(spList)]
    spPlotList <- vector(mode = "list", length = length(spList))
    for (sp in spList) {
      allPlots <- vector(mode = "list", length = length(plotTypes))
      sub.d <- d[d$name == sp, ]
      sub.d <- sub.d[complete.cases(sub.d), ]
      if ("yearHistogram" %in% plotTypes) {
        yearHistogram <- sub.d %>%
          ggplot(aes(x = year)) +
          geom_histogram(
            binwidth = (max(sub.d$year,
              na.rm = T
            ) - min(sub.d$year,
              na.rm = T
            )) / 10,
            fill = "black", color = "white", alpha = 0.9, na.rm = T
          ) +
          ggtitle(paste0(sp, " Occurrence Records by Year")) +
          theme(plot.title = element_text(size = 15)) +
          xlab("Year") +
          ylab("Count") +
          theme_classic(base_size = 15) +
          scale_y_continuous(expand = c(0, 0))
        yearHistogram <- ggplot_build(yearHistogram)
        allPlots[[1]] <- yearHistogram
      }
      if ("source" %in% plotTypes) {
        datasetTab <- sort(table(sub.d$datasetName), decreasing = T)
        pct <- round(datasetTab / sum(datasetTab) * 100)
        lbls <- names(datasetTab)
        lbls <- paste(lbls, pct) # add percents to labels
        lbls <- paste(lbls, "%", sep = "") # ad % to labels
        lbls <- occ_strwrap(lbls)
        names(pct) <- lbls
        pct <- pct[pct > 1]
        pct["Other*"] <- (100 - sum(pct))
        source <- waffle::waffle(pct,
          rows = 10,
          colors = viridis::viridis(length(pct)),
          title = paste0(sp, " Occurrence Records by Primary Data Source"),
          xlab = "*Sources contributing <2% not shown.")
        source <- ggplot_build(source)
        if ("yearHistogram" %in% plotTypes) {
          allPlots[[2]] <- source
        } else {
          allPlots[[1]] <- source
        }
      }
      if ("aggregator" %in% plotTypes) {
        datasetTab <- sort(table(sub.d$dataService), decreasing = T)
        pct <- round(datasetTab / sum(datasetTab) * 100)
        lbls <- names(datasetTab)
        lbls <- paste(lbls, pct) # add percents to labels
        lbls <- paste(lbls, "%", sep = "") # ad % to labels
        names(pct) <- lbls
        aggregator <- waffle::waffle(pct,
          rows = 10,
          colors = viridis::viridis(length(datasetTab)),
          title = paste0(
            sp,
            " Occurrences by Data Aggregator"
          )
        )
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
