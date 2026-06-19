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
  [`taxize::gnr_datasources()`](https://docs.ropensci.org/taxize/reference/gnr_datasources.html).

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
#> handled warning: Following sources not found in
#> Global Names Index source list: GBIF Backbone Taxonomy
#> handled warning: No valid taxonomic data sources supplied.
#> Populating default list from all available sources.
#> handled warning: Following sources not found in
#> Global Names Index source list: GBIF Backbone Taxonomy
#> handled warning: No valid taxonomic data sources supplied.
#> Populating default list from all available sources.
#> handled warning: longer object length is not a multiple of shorter object length
#> handled warning: Following sources not found in
#> Global Names Index source list: GBIF Backbone Taxonomy
#> handled warning: No valid taxonomic data sources supplied.
#> Populating default list from all available sources.
#> handled warning: Following sources not found in
#> Global Names Index source list: GBIF Backbone Taxonomy
#> handled warning: No valid taxonomic data sources supplied.
#> Populating default list from all available sources.
#> handled warning: Following sources not found in
#> Global Names Index source list: GBIF Backbone Taxonomy
#> handled warning: No valid taxonomic data sources supplied.
#> Populating default list from all available sources.
#> handled warning: longer object length is not a multiple of shorter object length
#> handled warning: Following sources not found in
#> Global Names Index source list: GBIF Backbone Taxonomy
#> handled warning: No valid taxonomic data sources supplied.
#> Populating default list from all available sources.
#> handled warning: Following sources not found in
#> Global Names Index source list: GBIF Backbone Taxonomy
#> handled warning: No valid taxonomic data sources supplied.
#> Populating default list from all available sources.
#> An object of class "occCiteData"
#> Slot "userQueryType":
#> [1] "User-supplied phylogeny."
#> 
#> Slot "userSpecTaxonomy":
#> [1] "GBIF Backbone Taxonomy"
#> 
#> Slot "cleanedTaxonomy":
#>                    Input Name                 Best Match
#> 1            Istiompax_indica          Istiompax indicus
#> 2            Istiompax_indica           Istiompax indica
#> 3              Kajikia_albida            Kajikia albidus
#> 4              Kajikia_albida             Kajikia albida
#> 5               Kajikia_audax              Kajikia audax
#> 6  Tetrapturus_angustirostris Tetrapturus angustirostris
#> 7          Tetrapturus_belone         Tetrapturus beloni
#> 8          Tetrapturus_belone         Tetrapturus belone
#> 9         Tetrapturus_georgii        Tetrapturus georgii
#> 10      Tetrapturus_pfluegeri      Tetrapturus pfluegeri
#>                                                                                                                                                                                                                                                                                                                                                                                            Taxonomic Databases w/ Matches
#> 1                                                                                                                                                                                                                                                                        ITIS; IUCN; TAXREF; FishBase Cache; Plazi; Catalogue of Life XR; EOL; Arctos; IRMNG (old); ION; Catalogue of Life; FishBase; OBIS; uBio NameBank
#> 2                                                                                                                                                                                                                                                                        ITIS; IUCN; TAXREF; FishBase Cache; Plazi; Catalogue of Life XR; EOL; Arctos; IRMNG (old); ION; Catalogue of Life; FishBase; OBIS; uBio NameBank
#> 3                                                                                                                                                                                                                                                                                                               ITIS; IUCN; TAXREF; FishBase Cache; Plazi; Catalogue of Life XR; EOL; Open Tree of Life; IRMNG (old); ION
#> 4                                                                                                                                                                                                                                                                                                               ITIS; IUCN; TAXREF; FishBase Cache; Plazi; Catalogue of Life XR; EOL; Open Tree of Life; IRMNG (old); ION
#> 5                                                                                                                                                                                                       Catalogue of Life; ITIS; WoRMS; IUCN; iNaturalist; TAXREF; Wikispecies; FishBase; FishBase Cache; Plazi; GBIF Backbone Taxonomy; Catalogue of Life XR; Arctos; EOL; Open Tree of Life; Wikidata; IRMNG (old); ION
#> 6  Catalogue of Life; ITIS; WoRMS; IUCN; iNaturalist; TAXREF; Wikispecies; Catalog of Fishes; FishBase; FishBase Cache; Plazi; NZOR; GBIF Backbone Taxonomy; Catalogue of Life XR; Arctos; EOL; Open Tree of Life; MCZbase; Wikidata; IRMNG (old); NCBI; Papahanaumokuakea Marine National Monument; The National Checklist of Taiwan; CU*STAR; Bishop Museum; BioLib.cz; nlbif; ION; uBio NameBank; New Zealand Animalia
#> 7                                                                                                                                                                                                                       ITIS; IUCN; TAXREF; FishBase; Sherborn Index Animalium; Plazi; Catalogue of Life XR; Arctos; EOL; Open Tree of Life; Wikidata; IRMNG (old); CU*STAR; BioLib.cz; ION; uBio NameBank; Bishop Museum
#> 8                                                                                                                                                                                                                       ITIS; IUCN; TAXREF; FishBase; Sherborn Index Animalium; Plazi; Catalogue of Life XR; Arctos; EOL; Open Tree of Life; Wikidata; IRMNG (old); CU*STAR; BioLib.cz; ION; uBio NameBank; Bishop Museum
#> 9                                                                                            Catalogue of Life; ITIS; WoRMS; IUCN; iNaturalist; Wikispecies; Catalog of Fishes; FishBase; FishBase Cache; Sherborn Index Animalium; Plazi; GBIF Backbone Taxonomy; Catalogue of Life XR; EUNIS; Arctos; EOL; Open Tree of Life; Wikidata; IRMNG (old); NCBI; CU*STAR; Bishop Museum; BioLib.cz; nlbif; ION; uBio NameBank
#> 10                                                                                            Catalogue of Life; ITIS; WoRMS; IUCN; iNaturalist; TAXREF; Fauna of Brazil; Wikispecies; Catalog of Fishes; FishBase; FishBase Cache; Plazi; GBIF Backbone Taxonomy; Catalogue of Life XR; EUNIS; Arctos; EOL; Open Tree of Life; Wikidata; IRMNG (old); NCBI; CU*STAR; Bishop Museum; BioLib.cz; nlbif; ION; uBio NameBank
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
