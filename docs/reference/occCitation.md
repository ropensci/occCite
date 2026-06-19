# Occurrence Citations

Harvests citations for occurrence data

## Usage

``` r
occCitation(x = NULL)
```

## Arguments

- x:

  An object of class
  [`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)

## Value

An object of class
[`occCiteCitation`](https://docs.ropensci.org/occCite/reference/occCiteCitation-class.md).
It is a named list of the same length as the number of species included
in your
[`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)
object. Each item in the list has citation information for occurrences.

## Examples

``` r
if (FALSE) { # \dontrun{
data(myOccCiteObject)
myCitations <- occCitation(x = myOccCiteObject)
} # }
```
