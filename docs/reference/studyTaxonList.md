# Study Taxon List

Takes input phylogenies or vectors of taxon names, checks against
taxonomic database, returns vector of cleaned taxonomic names (using
[`taxize::gnr_resolve()`](https://docs.ropensci.org/taxize/reference/gnr_resolve.html))
for use in spocc queries, as well as warnings if there are invalid
names.

## Usage

``` r
studyTaxonList(x = NULL, datasources = "GBIF Backbone Taxonomy")
```

## Arguments

- x:

  A phylogeny of class 'phylo' or a vector of class 'character'
  containing the names of taxa of interest

- datasources:

  A vector of taxonomic data sources implemented in
  [`taxize::gnr_resolve`](https://docs.ropensci.org/taxize/reference/gnr_resolve.html).
  You can see the list using
  [`taxize::gna_data_sources()`](https://docs.ropensci.org/taxize/reference/gna_data_sources.html).

## Value

An object of class
[`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)
containing the type of inquiry the user has made –a phylogeny or a
vector of names– and a data frame containing input taxa names, the
closest match according to
[`taxize::gnr_resolve`](https://docs.ropensci.org/taxize/reference/gnr_resolve.html),
and a list of taxonomic data sources that contain the matching name.

## Examples

``` r
## Inputting a vector of taxon names
studyTaxonList(
  x = c(
    "Buteo buteo",
    "Buteo buteo hartedi",
    "Buteo japonicus"
  ),
  datasources = c("National Center for Biotechnology Information")
)
#> An object of class "occCiteData"
#> Slot "userQueryType":
#> [1] "User-supplied list of taxa."
#> 
#> Slot "userSpecTaxonomy":
#> [1] "National Center for Biotechnology Information"
#> 
#> Slot "cleanedTaxonomy":
#>            Input Name      Best Match Taxonomic Databases w/ Matches
#> 1         Buteo buteo           Buteo                           NCBI
#> 2 Buteo buteo hartedi           Buteo                           NCBI
#> 3     Buteo japonicus Buteo japonicus                           NCBI
#> 
#> Slot "occSources":
#> logical(0)
#> 
#> Slot "occCiteSearchDate":
#> character(0)
#> 
#> Slot "occResults":
#> list()
#> 

# \donttest{
## Inputting a phylogeny
phylogeny <- ape::read.nexus(
  system.file("extdata/Fish_12Tax_time_calibrated.tre",
    package = "occCite"
  )
)
phylogeny <- ape::extract.clade(phylogeny, 18)
studyTaxonList(
  x = phylogeny,
  datasources = c("GBIF Backbone Taxonomy")
)
#> An object of class "occCiteData"
#> Slot "userQueryType":
#> [1] "User-supplied phylogeny."
#> 
#> Slot "userSpecTaxonomy":
#> [1] "GBIF Backbone Taxonomy"
#> 
#> Slot "cleanedTaxonomy":
#>                   Input Name                 Best Match
#> 1           Istiompax_indica           Istiompax indica
#> 2             Kajikia_albida             Kajikia albida
#> 3              Kajikia_audax              Kajikia audax
#> 4 Tetrapturus_angustirostris Tetrapturus angustirostris
#> 5         Tetrapturus_belone         Tetrapturus belone
#> 6        Tetrapturus_georgii        Tetrapturus georgii
#> 7      Tetrapturus_pfluegeri      Tetrapturus pfluegeri
#>   Taxonomic Databases w/ Matches
#> 1         GBIF Backbone Taxonomy
#> 2         GBIF Backbone Taxonomy
#> 3         GBIF Backbone Taxonomy
#> 4         GBIF Backbone Taxonomy
#> 5         GBIF Backbone Taxonomy
#> 6         GBIF Backbone Taxonomy
#> 7         GBIF Backbone Taxonomy
#> 
#> Slot "occSources":
#> logical(0)
#> 
#> Slot "occCiteSearchDate":
#> character(0)
#> 
#> Slot "occResults":
#> list()
#> 
# }
```
