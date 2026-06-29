# Plotting summary figures for occCite search results

Generates up to three different kinds of plots, with toggles determining
whether plots should be done for individual species or aggregating all
species–histogram by year of occurrence records, waffle plot of primary
data sources, waffle plot of data aggregators.

## Usage

``` r
# S3 method for class 'occCiteData'
plot(x, ...)
```

## Arguments

- x:

  An object of class
  [`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)
  to map.

- ...:

  Additional arguments affecting how the formatted citation document is
  produced. \`bySpecies\`: Logical; setting to \`TRUE\` generates the
  desired plots for each species. \`plotTypes\`: The type of plot to be
  generated; "yearHistogram", "source", and/or "aggregator".

## Value

A list containing the desired plots.

## Examples

``` r
plot(x = myOccCiteObject,
     bySpecies = FALSE,
     plotTypes = c("yearHistogram"))
#> $yearHistogram

#> 

if (FALSE) { # \dontrun{
# Requires the 'waffle' package from GitHub
plot(x = myOccCiteObject,
     bySpecies = FALSE,
     plotTypes = c("yearHistogram", "source", "aggregator"))
} # }
```
