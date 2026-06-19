# Generating a map of downloaded points

Makes maps for each individual species in an
[`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)
object.

## Usage

``` r
occCiteMap(
  occCiteData,
  species_map = "all",
  species_colors = NULL,
  ds_map = c("GBIF", "BIEN"),
  map_limit = 1000,
  awesomeMarkers = TRUE,
  cluster = FALSE
)
```

## Arguments

- occCiteData:

  An object of class
  [`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)
  to map

- species_map:

  Character; either the default "all" to map all species in
  [`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md),
  or a subset of these specified as a character or character vector.

- species_colors:

  Character; the default NULL will choose random colors from those
  available (see Details), or those specified by the user as a character
  or character vector (the number of colors must match the number of
  species mapped).

- ds_map:

  Character; specifies which data service records will be mapped, with
  the default being GBIF, BIEN, and GBIF_BIEN (records with the same
  coordinates in both databases).

- map_limit:

  Numeric; the number of points to map per species, set at a default of
  1000 randomly selected records; users can specify a higher number, but
  be aware that leaflet can lag or crash when too many points are
  plotted.

- awesomeMarkers:

  Logical; if \`TRUE\` (default), mapped points will be
  \`awesomeMarkers\` attributed with an icon for a globe for GBIF, a
  leaf for BIEN, or a database if records from both databases have the
  same coordinates; if \`FALSE\`, mapped points will be leaflet
  \`circleMarkers\`

- cluster:

  Logical; if \`TRUE\` (default is \`FALSE\`) turns on marker
  clustering, which does not preserve color differences between species

## Value

A leaflet map

## Details

When mapping using \`awesomeMarkers\` (default), the parameter
species_colors must match those in a specified color library, currently:
c("red", "lightred", "orange", "beige", "green", "lightgreen", "blue",
"lightblue", "purple", "pink", "cadetblue", "white", "gray",
"lightgray"). When \`awesomeMarkers\` is \`FALSE\` and species_colors
are not specified, random colors from the \`RColorBrewer\` Set1 palette
are used.

## Examples

``` r
if (FALSE) { # \dontrun{
data(myOccCiteObject)
occCiteMap(myOccCiteObject, cluster = FALSE)
} # }
```
