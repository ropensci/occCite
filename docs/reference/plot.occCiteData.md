# Plotting summary figures for occCite search results

Generates up to three different kinds of plots, with toggles determining
whether plots should be done for individual species or aggregating all
species–histogram by year of occurrence records, waffle::waffle plot of
primary data sources, waffle::waffle plot of data aggregators.

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
data(myOccCiteObject)
plot(
  x = myOccCiteObject, bySpecies = FALSE,
  plotTypes = c("yearHistogram", "source", "aggregator")
)
#> Loading required namespace: waffle
#> Warning: waffle package not available. Skipping source, aggregator.
#> $yearHistogram

#> 
```
