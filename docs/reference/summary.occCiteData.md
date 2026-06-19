# Summary for occCite data objects

Displays a summary of relevant stats about a query

## Usage

``` r
# S3 method for class 'occCiteData'
summary(object, ...)
```

## Arguments

- object:

  An object of class
  [`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)

- ...:

  Additional arguments affecting the summary produced

## Examples

``` r

data(myOccCiteObject)
summary(myOccCiteObject)
#>  
#>  OccCite query occurred on: 20 June, 2024
#>  
#>  User query type: User-supplied list of taxa.
#>  
#>  Sources for taxonomic rectification: GBIF Backbone Taxonomy
#>      
#>  
#>  Taxonomic cleaning results:     
#> 
#>          Input Name                Best Match Taxonomic Databases w/ Matches
#> 1 Protea cynaroides Protea cynaroides (L.) L.         GBIF Backbone Taxonomy
#>  
#>  Sources for occurrence data: gbif, bien
#>      
#>                     Species Occurrences Sources
#> 1 Protea cynaroides (L.) L.        2334      17
#>  
#>  GBIF dataset DOIs:  
#> 
#>                     Species GBIF Access Date           GBIF DOI
#> 1 Protea cynaroides (L.) L.       2022-03-02 10.15468/dl.ztbx8c
```
