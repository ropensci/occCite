Introduction
============

We have entered the age of data-intensive scientific discovery. As
datasets increase in complexity and heterogeneity, we must preserve the
cycle of data citation from primary data sources to aggregating
databases to research products and back to primary data sources. The
citation cycle keeps science transparent, but it is also key to
supporting primary providers by documenting the use of their data. The
Global Biodiversity Information Facility and other data aggregators have
made great strides in harvesting citation data from research products
and linking them back to primary data providers. However, this only
works if those that publish research products cite primary data sources
in the first place. We developed `occCite`, a set of `R`-based tools for
downloading, managing, and citing biodiversity data, to advance toward
the goal of closing the data provenance cycle. These tools preserve
links between occurrence data and primary providers once researchers
download aggregated data, and facilitate the citation of primary data
providers in research papers.

The `occCite` work flow follows a three-step process. First, the user
inputs one or more taxonomic names (or a phylogeny). `occCite` then
rectifies those names by checking them against one or more taxonomic
databases, which can be specified by the user (see the [Global Names
List](http://gni.globalnames.org/%7D)). The results of the taxonomic
rectification are then kept in an `occCiteData` object in local memory.
Next, `occCite` takes the `occCiteData` object and user-defined search
parameters to query BIEN (through `rbien`) and/or GBIF(through `rGBIF`)
for records. The results are appended to the `occCiteData` object, along
with metadata on the search. Finally, the user can pass the
`occCiteData` object to `occCitation`, which compiles citations for the
primary providers, database aggregators, and `R` packages used to build
the dataset.

For an overview tutorial video of the package, see [our YouTube
video](https://www.youtube.com/watch?v=7qSCULN_VjY&t=17s).

Future iterations of `occCite` will track citation data through the data
cleaning process and provide a series of visualizations on raw query
results and final datasets. It will also provide data citations in a
format congruent with best-practice recommendations for large
biodiversity datasets. Based on these data citation tools, we will also
propose a new set of standards for citing primary biodiversity data in
published research articles that provides due credit to contributors and
allows them to track the use of their work. Keep checking back!

Setup
=====

If you plan to query GBIF, you will need to provide them with your user
login information. We have provided a dummy login below to show you the
format. *You will need to provide actual account information.* This is
because you will actually be downloading *all* of the records available
for the species using `occ_download()`, instead of getting results from
`occ_search()`, which has a hard limit of 200,000 occurrences.

``` r
library(occCite);
#Creating a GBIF login
GBIFLogin <- GBIFLoginManager(user = "occCiteTester",
                          email = "****@yahoo.com",
                          pwd = "12345")
```

Performing a simple search
==========================

The basics
----------

At its simplest, `occCite` allows you to search for occurrences for a
single species. The taxonomy of the user-specified species will be
verified using EOL and NCBI taxonomies by default.

``` r
# Simple search
mySimpleOccCiteObject <- occQuery(x = "Protea cynaroides",
                            datasources = c("gbif", "bien"),
                            GBIFLogin = GBIFLogin, 
                            GBIFDownloadDirectory = paste0(path.package("occCite"), "/extdata/"),
                            checkPreviousGBIFDownload = T)
```

Here is what the GBIF results look like:

``` r
# GBIF search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable)
```

    ##                name longitude  latitude day month year
    ## 1 Protea cynaroides  18.40540 -33.95891   4     1 2015
    ## 2 Protea cynaroides  18.42350 -33.96619  20     6 2019
    ## 3 Protea cynaroides  22.99340 -34.05478  16     6 2019
    ## 4 Protea cynaroides  18.40232 -34.08405   9     6 2019
    ## 5 Protea cynaroides  19.44807 -34.52123  13     6 2019
    ## 6 Protea cynaroides  18.39757 -34.07418   9     6 2019
    ##                                   Dataset                           DatasetKey
    ## 1 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 2 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 3 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 4 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 5 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 6 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ##   DataService
    ## 1        GBIF
    ## 2        GBIF
    ## 3        GBIF
    ## 4        GBIF
    ## 5        GBIF
    ## 6        GBIF

And here are the BIEN results:

``` r
#BIEN search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$BIEN$OccurrenceTable)
```

    ##                name longitude latitude day month year Dataset DatasetKey
    ## 1 Protea cynaroides    22.875  -33.875  20     8 1973   SANBI       2249
    ## 2 Protea cynaroides    25.125  -33.875   3     7 1934   SANBI       2249
    ## 3 Protea cynaroides    20.375  -33.875  16     8 1952   SANBI       2249
    ## 4 Protea cynaroides    21.375  -33.375  20     3 1947   SANBI       2249
    ## 5 Protea cynaroides    20.875  -34.125  21     6 1987   SANBI       2249
    ## 6 Protea cynaroides    24.625  -33.625  12     9 1973   SANBI       2249
    ##   DataService
    ## 1        BIEN
    ## 2        BIEN
    ## 3        BIEN
    ## 4        BIEN
    ## 5        BIEN
    ## 6        BIEN

There is also a summary method for `occCite` objects with some basic
information about your search.

``` r
summary(mySimpleOccCiteObject)
```

    ##  
    ##  OccCite query occurred on: 31 August, 2020
    ##  
    ##  User query type: User-supplied list of taxa.
    ##  
    ##  Sources for taxonomic rectification: NCBI
    ##      
    ##  
    ##  Taxonomic cleaning results:     
    ## 
    ##          Input Name        Best Match Taxonomic Databases w/ Matches
    ## 1 Protea cynaroides Protea cynaroides                           NCBI
    ##  
    ##  Sources for occurrence data: gbif, bien
    ##      
    ##             Species Occurrences Sources
    ## 1 Protea cynaroides         828      15
    ##  
    ##  GBIF dataset DOIs:  
    ## 
    ##             Species GBIF Access Date           GBIF DOI
    ## 1 Protea cynaroides       2019-07-15 10.15468/dl.iqnra2

Simple citations
----------------

After doing a search for occurrence points, you can use `occCitation()`
to generate citations for primary biodiversity databases, as well as
database aggregators. **Note:** Currently, GBIF and BIEN are the only
aggregators for which citations are supported.

``` r
#Get citations
mySimpleOccCitations <- occCitation(mySimpleOccCiteObject)
```

Here is a simple way of generating a formatted citation document from
the results of `occCitation()`.

``` r
print(mySimpleOccCitations)
```

    ## An object of class "occCiteCitation"
    ## Slot "occResults":
    ## $`Protea cynaroides`
    ##    occSearch                          Dataset Key
    ## 4       GBIF 83ae84cf-88e4-4b5c-80b2-271a15a3e0fc
    ## 8       GBIF 5288946d-5fcf-4b53-8fd3-74f4cc6b53fc
    ## 9       GBIF 1881d048-04f9-4bc2-b7c8-931d1659a354
    ## 7       GBIF 7bd65a7a-f762-11e1-a439-00145eb45e9a
    ## 11      BIEN                                 2249
    ## 13      BIEN                                 3466
    ## 10      GBIF b5cdf794-8fa4-4a85-8b26-755d087bf531
    ## 2       GBIF 6ac3f774-d9fb-4796-b3e9-92bf6c81c084
    ## 12      BIEN                                 3541
    ## 3       GBIF d0963cee-1a29-47a2-b9bf-fb0e7690077c
    ## 14      BIEN                                 1754
    ## 6       GBIF e5774d90-9f01-42bb-a747-32331be82b18
    ## 5       GBIF baa86fb2-7346-4507-a34f-44e4c1bd0d57
    ## 15      BIEN                                  280
    ## 1       GBIF 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ##                                                                                                                                                                                                                                                    Citation
    ## 4                                                                                  Cameron E, Auckland Museum A M (2020). Auckland Museum Botany Collection. Version 1.51. Auckland War Memorial Museum. Occurrence dataset https://doi.org/10.15468/mnjkvv
    ## 8                                                                                                                                                      Capers R (2014). CONN. University of Connecticut. Occurrence dataset https://doi.org/10.15468/w35jmd
    ## 9                                                                                                         Fatima Parker-Allie, Ranwashe F (2018). PRECIS. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/rckmn2
    ## 7                                                                                                              Magill B, Solomon J, Stimmel H (2020). Tropicos Specimen Data. Missouri Botanical Garden. Occurrence dataset https://doi.org/10.15468/hja69f
    ## 11                                                                                                                                                                                                                      Missouri Botanical Garden,Herbarium
    ## 13                                                                                                                                                                                                                                                     MNHN
    ## 10 MNHN, Chagnoux S (2020). The vascular plants collection (P) at the Herbarium of the Muséum national d'Histoire Naturelle (MNHN - Paris). Version 69.179. MNHN - Museum national d'Histoire naturelle. Occurrence dataset https://doi.org/10.15468/nc6rxy
    ## 2                                                                                                                                                                           naturgucker.de. naturgucker. Occurrence dataset https://doi.org/10.15468/uc1apo
    ## 12                                                                                                                                                                                                                                                      NSW
    ## 3                                                                                         Ranwashe F (2019). BODATSA: Botanical Collections. Version 1.4. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/2aki0q
    ## 14                                                                                                                                                                                                                                                    SANBI
    ## 6                                                                                                                                                    Senckenberg (2020). African Plants - a photo guide. Occurrence dataset https://doi.org/10.15468/r9azth
    ## 5                                                                                                                                                                        Tela Botanica. Carnet en Ligne. Occurrence dataset https://doi.org/10.15468/rydcn2
    ## 15                                                                                                                                                                                                                                                    UConn
    ## 1                                                                                                                               Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. Occurrence dataset https://doi.org/10.15468/ab3s5x
    ##    Accession Date Number of Occurrences
    ## 4      2019-07-15                    17
    ## 8      2019-07-15                     1
    ## 9      2019-07-15                     2
    ## 7      2019-07-15                     8
    ## 11           <NA>                     3
    ## 13     2018-08-14                     1
    ## 10     2019-07-15                    10
    ## 2      2019-07-15                   474
    ## 12     2018-08-14                   133
    ## 3      2019-07-15                     3
    ## 14     2018-08-14                     3
    ## 6      2019-07-15                     2
    ## 5      2019-07-15                     2
    ## 15     2018-08-14                     8
    ## 1      2019-07-15                   161

Simple Taxonomic Rectification
------------------------------

In the simplest of searches, such as the one above, the taxonomy of your
input species name is automatically rectified through the `occCite`
function `studyTaxonList()` using `gnr_resolve()` from the `taxize` `R`
package. If you would like to change the source of the taxonomy being
used to rectify your species names, you can specify as many taxonomic
repositories as you like from the Global Names Index (GNI). The complete
list of GNI repositories can be found
[here](http://gni.globalnames.org/data_sources).

`studyTaxonList()` chooses the taxonomic names closest to those being
input and documents which taxonomic repositories agreed with those
names. `studyTaxonList()` instantiates an `occCiteData` object the same
way `occQuery()` does. This object can be passed into `occQuery()` to
perform your occurrence data search.

``` r
#Rectify taxonomy
myTROccCiteObject <- studyTaxonList(x = "Protea cynaroides", 
                                  datasources = c("NCBI", "EOL", "ITIS"))
myTROccCiteObject@cleanedTaxonomy
```

    ##          Input Name        Best Match Taxonomic Databases w/ Matches
    ## 1 Protea cynaroides Protea cynaroides                           NCBI

------------------------------------------------------------------------

Advanced features
=================

Loading data from previous GBIF searches
----------------------------------------

Querying GBIF can take quite a bit of time, especially for multiple
species and/or well-known species. In this case, you may wish to access
previously-downloaded data sets from your computer by specifying the
general location of your downloaded `.zip` files. `occQuery` will crawl
through your specified `GBIFDownloadDirectory` to collect all the `.zip`
files contained in that folder and its subfolders. It will then import
the most recent downloads that match your taxon list. These GBIF data
will be appended to a BIEN search the same as if you do the simple
real-time search (if you chose BIEN as well as GBIF), as was shown
above. `checkPreviousGBIFDownload` is `TRUE` by default, but if
`loadLocalGBIFDownload` is `TRUE`, `occQuery` will ignore
`checkPreviousDownload`. It is also worth noting that `occCite` does not
currently support mixed data download sources. That is, you cannot do
GBIF queries for some taxa, download previously-prepared data sets for
others, and load the rest from local data sets on your computer.

``` r
# Simple load
myOldOccCiteObject <- occQuery(x = "Protea cynaroides", 
                                  datasources = c("gbif", "bien"), 
                                  GBIFLogin = NULL, 
                                  GBIFDownloadDirectory = paste0(path.package("occCite"), "/extdata/"),
                                  loadLocalGBIFDownload = T,
                                  checkPreviousGBIFDownload = F)
```

Here is the result. Look familiar?

``` r
#GBIF search results
head(myOldOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable)
```

    ##                name longitude  latitude day month year
    ## 1 Protea cynaroides  18.40540 -33.95891   4     1 2015
    ## 2 Protea cynaroides  18.42350 -33.96619  20     6 2019
    ## 3 Protea cynaroides  22.99340 -34.05478  16     6 2019
    ## 4 Protea cynaroides  18.40232 -34.08405   9     6 2019
    ## 5 Protea cynaroides  19.44807 -34.52123  13     6 2019
    ## 6 Protea cynaroides  18.39757 -34.07418   9     6 2019
    ##                                   Dataset                           DatasetKey
    ## 1 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 2 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 3 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 4 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 5 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 6 iNaturalist research-grade observations 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ##   DataService
    ## 1        GBIF
    ## 2        GBIF
    ## 3        GBIF
    ## 4        GBIF
    ## 5        GBIF
    ## 6        GBIF

``` r
#The full summary
summary(myOldOccCiteObject)
```

    ##  
    ##  OccCite query occurred on: 31 August, 2020
    ##  
    ##  User query type: User-supplied list of taxa.
    ##  
    ##  Sources for taxonomic rectification: NCBI
    ##      
    ##  
    ##  Taxonomic cleaning results:     
    ## 
    ##          Input Name        Best Match Taxonomic Databases w/ Matches
    ## 1 Protea cynaroides Protea cynaroides                           NCBI
    ##  
    ##  Sources for occurrence data: gbif, bien
    ##      
    ##             Species Occurrences Sources
    ## 1 Protea cynaroides         828      15
    ##  
    ##  GBIF dataset DOIs:  
    ## 
    ##             Species GBIF Access Date           GBIF DOI
    ## 1 Protea cynaroides       2019-07-15 10.15468/dl.iqnra2

Getting citation data works the exact same way with
previously-downloaded data as it does from a fresh dataset.

``` r
#Get citations
myOldOccCitations <- occCitation(myOldOccCiteObject)
print(myOldOccCitations)
```

    ## An object of class "occCiteCitation"
    ## Slot "occResults":
    ## $`Protea cynaroides`
    ##    occSearch                          Dataset Key
    ## 4       GBIF 83ae84cf-88e4-4b5c-80b2-271a15a3e0fc
    ## 8       GBIF 5288946d-5fcf-4b53-8fd3-74f4cc6b53fc
    ## 9       GBIF 1881d048-04f9-4bc2-b7c8-931d1659a354
    ## 7       GBIF 7bd65a7a-f762-11e1-a439-00145eb45e9a
    ## 11      BIEN                                 2249
    ## 13      BIEN                                 3466
    ## 10      GBIF b5cdf794-8fa4-4a85-8b26-755d087bf531
    ## 2       GBIF 6ac3f774-d9fb-4796-b3e9-92bf6c81c084
    ## 12      BIEN                                 3541
    ## 3       GBIF d0963cee-1a29-47a2-b9bf-fb0e7690077c
    ## 14      BIEN                                 1754
    ## 6       GBIF e5774d90-9f01-42bb-a747-32331be82b18
    ## 5       GBIF baa86fb2-7346-4507-a34f-44e4c1bd0d57
    ## 15      BIEN                                  280
    ## 1       GBIF 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ##                                                                                                                                                                                                                                                    Citation
    ## 4                                                                                  Cameron E, Auckland Museum A M (2020). Auckland Museum Botany Collection. Version 1.51. Auckland War Memorial Museum. Occurrence dataset https://doi.org/10.15468/mnjkvv
    ## 8                                                                                                                                                      Capers R (2014). CONN. University of Connecticut. Occurrence dataset https://doi.org/10.15468/w35jmd
    ## 9                                                                                                         Fatima Parker-Allie, Ranwashe F (2018). PRECIS. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/rckmn2
    ## 7                                                                                                              Magill B, Solomon J, Stimmel H (2020). Tropicos Specimen Data. Missouri Botanical Garden. Occurrence dataset https://doi.org/10.15468/hja69f
    ## 11                                                                                                                                                                                                                      Missouri Botanical Garden,Herbarium
    ## 13                                                                                                                                                                                                                                                     MNHN
    ## 10 MNHN, Chagnoux S (2020). The vascular plants collection (P) at the Herbarium of the Muséum national d'Histoire Naturelle (MNHN - Paris). Version 69.179. MNHN - Museum national d'Histoire naturelle. Occurrence dataset https://doi.org/10.15468/nc6rxy
    ## 2                                                                                                                                                                           naturgucker.de. naturgucker. Occurrence dataset https://doi.org/10.15468/uc1apo
    ## 12                                                                                                                                                                                                                                                      NSW
    ## 3                                                                                         Ranwashe F (2019). BODATSA: Botanical Collections. Version 1.4. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/2aki0q
    ## 14                                                                                                                                                                                                                                                    SANBI
    ## 6                                                                                                                                                    Senckenberg (2020). African Plants - a photo guide. Occurrence dataset https://doi.org/10.15468/r9azth
    ## 5                                                                                                                                                                        Tela Botanica. Carnet en Ligne. Occurrence dataset https://doi.org/10.15468/rydcn2
    ## 15                                                                                                                                                                                                                                                    UConn
    ## 1                                                                                                                               Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. Occurrence dataset https://doi.org/10.15468/ab3s5x
    ##    Accession Date Number of Occurrences
    ## 4      2019-07-15                    17
    ## 8      2019-07-15                     1
    ## 9      2019-07-15                     2
    ## 7      2019-07-15                     8
    ## 11           <NA>                     3
    ## 13     2018-08-14                     1
    ## 10     2019-07-15                    10
    ## 2      2019-07-15                   474
    ## 12     2018-08-14                   133
    ## 3      2019-07-15                     3
    ## 14     2018-08-14                     3
    ## 6      2019-07-15                     2
    ## 5      2019-07-15                     2
    ## 15     2018-08-14                     8
    ## 1      2019-07-15                   161

Note that you can also load multiple species using either a vector of
species names or a phylogeny (provided you have previously downloaded
data for all of the species of interest), and you can load occurrences
from non-GBIF data sources (e.g. BIEN) in the same query.

------------------------------------------------------------------------

Performing a Multi-Species Search
---------------------------------

In addition to doing a simple, single species search, you can also use
`occCite` to search for and manage occurrence datasets for multiple
species. You can either submit a vector of species names, or you can
submit a *phylogeny*!

occCite with a Phylogeny
------------------------

Here is an example of how such a search is structured, using an
unpublished phylogeny of billfishes.

``` r
library(ape)
#Get tree
treeFile <- system.file("extdata/Fish_12Tax_time_calibrated.tre", package='occCite')
phylogeny <- ape::read.nexus(treeFile)
tree <- ape::extract.clade(phylogeny, 18)
#Query databases for names
myPhyOccCiteObject <- studyTaxonList(x = tree, datasources = "NCBI")
#Query GBIF for occurrence data
myPhyOccCiteObject <- occQuery(x = myPhyOccCiteObject, 
                            datasources = "gbif",
                            GBIFDownloadDirectory = paste0(path.package("occCite"), "/extdata/"), 
                            loadLocalGBIFDownload = T,
                            checkPreviousGBIFDownload = F)
```

``` r
# What does a multispecies query look like?
summary(myPhyOccCiteObject)
```

    ##  
    ##  OccCite query occurred on: 31 August, 2020
    ##  
    ##  User query type: User-supplied phylogeny.
    ##  
    ##  Sources for taxonomic rectification: NCBI
    ##      
    ##  
    ##  Taxonomic cleaning results:     
    ## 
    ##                   Input Name                 Best Match
    ## 1           Istiompax_indica           Istiompax indica
    ## 2             Kajikia_albida             Kajikia albida
    ## 3              Kajikia_audax              Kajikia audax
    ## 4 Tetrapturus_angustirostris Tetrapturus angustirostris
    ## 5         Tetrapturus_belone         Tetrapturus belone
    ## 6        Tetrapturus_georgii        Tetrapturus georgii
    ## 7      Tetrapturus_pfluegeri      Tetrapturus pfluegeri
    ##   Taxonomic Databases w/ Matches
    ## 1                           NCBI
    ## 2                           NCBI
    ## 3                           NCBI
    ## 4                           NCBI
    ## 5                           NCBI
    ## 6                           NCBI
    ## 7                           NCBI
    ##  
    ##  Sources for occurrence data: gbif
    ##      
    ##                      Species Occurrences Sources
    ## 1           Istiompax indica         468      23
    ## 2             Kajikia albida         167      16
    ## 3              Kajikia audax        6721      22
    ## 4 Tetrapturus angustirostris         174      22
    ## 5         Tetrapturus belone           9       6
    ## 6        Tetrapturus georgii          62       4
    ## 7      Tetrapturus pfluegeri         409       7
    ##  
    ##  GBIF dataset DOIs:  
    ## 
    ##                      Species GBIF Access Date           GBIF DOI
    ## 1           Istiompax indica       2019-07-04 10.15468/dl.crapuf
    ## 2             Kajikia albida       2019-07-04 10.15468/dl.lnwf6a
    ## 3              Kajikia audax       2019-07-04 10.15468/dl.txromp
    ## 4 Tetrapturus angustirostris       2019-07-04 10.15468/dl.mumi5e
    ## 5         Tetrapturus belone       2019-07-04 10.15468/dl.q2nxb1
    ## 6        Tetrapturus georgii       2019-07-04 10.15468/dl.h860up
    ## 7      Tetrapturus pfluegeri       2019-07-04 10.15468/dl.qjidbs

``` r
#Get citations
myPhyOccCitations <- occCitation(myPhyOccCiteObject)

#Print citations as text with accession dates.
print(myPhyOccCitations)
```

    ## An object of class "occCiteCitation"
    ## Slot "occResults":
    ## $`Istiompax indica`
    ##    occSearch                          Dataset Key
    ## 15      GBIF dce8feb0-6c89-11de-8225-b8a03c50a862
    ## 22      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 9       GBIF cee6464f-cae2-4aab-aa8b-0429a2cb3af0
    ## 23      GBIF 5d6c10bd-ea31-4363-8b79-58c96d859f5b
    ## 17      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 14      GBIF b5267bb3-217b-49a1-b9c9-9024cdad2666
    ## 7       GBIF 0b81b94a-9761-46e5-a483-df6fcb840cc5
    ## 5       GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 19      GBIF 7a25f7aa-03fb-4322-aaeb-66719e1a9527
    ## 11      GBIF c7b39dbc-39f5-47e6-8b70-d49eea899ef9
    ## 16      GBIF 793c3890-6c8a-11de-8226-b8a03c50a862
    ## 13      GBIF 39905320-6c8a-11de-8226-b8a03c50a862
    ## 6       GBIF 6555005d-4594-4a3e-be33-c70e587b63d7
    ## 18      GBIF a79c2b50-6c8a-11de-8226-b8a03c50a862
    ## 8       GBIF 514ccc41-0fd0-4a49-86b1-ae1c739eb5d0
    ## 4       GBIF 69e81d22-3207-4663-9a7d-418919d7d779
    ## 21      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 12      GBIF 80ac6ada-f762-11e1-a439-00145eb45e9a
    ## 10      GBIF 41eb63f5-9a19-4f2c-8bf3-a1247e6b6c69
    ## 2       GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ## 1       GBIF 25f99a40-2327-4c57-9631-1a0825d834fa
    ## 3       GBIF 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 20      GBIF 7c93d290-6c8b-11de-8226-b8a03c50a862
    ##                                                                                                                                                                                                                                                                                                                      Citation
    ## 15                                                                                                                                                                                                         Australian Museum (2020). Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/e7susi
    ## 22                                                                                                                                                                             Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 9                                                               BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd
    ## 23                                                                                                                                                                       Catania D, Fong J (2020). CAS Ichthyology (ICH). Version 150.237. California Academy of Sciences. Occurrence dataset https://doi.org/10.15468/efh2ib
    ## 17                                                                                                                                                                  Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 14                                                                                                                                                 CSIRO Oceans and Atmosphere (2020). CSIRO, Rachel Cruises, Shark Data, Arafura Sea, North Australia, 1984. Version 6.2. Occurrence dataset https://doi.org/10.15468/yickr6
    ## 7                              Elías Gutiérrez M, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Códigos de barras de la vida en peces y zooplancton de México. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/xmbkgo
    ## 5                                                                                                                                                                                    European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 19                                                                                                                                                                Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd
    ## 11                                                                                                                           Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. Occurrence dataset https://doi.org/10.15468/i66xdm
    ## 16                                                                                                                                                  Museum and Art Gallery of the Northern Territory (2019). Northern Territory Museum and Art Gallery provider for OZCAM. Occurrence dataset https://doi.org/10.15468/giro3a
    ## 13                                                                                                                                                                                                           Museums Victoria (2020). Museums Victoria provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lp1ctu
    ## 6  Pozo de la Tijera M D C, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Fortalecimiento de las colecciones de ECOSUR. Primera fase (Ictioplancton Chetumal). Version 1.3. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/orx3mk
    ## 18                                                                                                                                                                                                         Queensland Museum (2020). Queensland Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lotsye
    ## 8                                                                                                        Raiva R, Santana P (2019). Diversidade e ocorrência de peixes em Inhambane (2009-2017). Version 1.4. National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/4fj2tq
    ## 4                                                                                                            Raiva R, Viador R, Santana P (2019). Diversidade e ocorrência de peixes na Zambézia (2003-2016). National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/mrz36h
    ## 21                                                                                                                                                                              Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 12        Sánchez González S, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Taxonomía y sistemática de la Ictiofauna de la Bahía de Banderas del Estado de Nayarit, México. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/uhrwsl
    ## 10                                                                                                                                                         Shane G (2018). Pelagic fish food web linkages, Queensland, Australia (2003-2005). CSIRO Oceans and Atmosphere. Occurrence dataset https://doi.org/10.15468/yy5wdp
    ## 2                                                                                                                                                                       The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ## 1                                                                                                                                                         Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/vjeh1p
    ## 3                                                                                                                                                                                                 Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. Occurrence dataset https://doi.org/10.15468/ab3s5x
    ## 20                                                                                                                                                                                         Western Australian Museum (2019). Western Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/5qt0dm
    ##    Accession Date Number of Occurrences
    ## 15     2019-07-04                     1
    ## 22     2019-07-04                    46
    ## 9      2019-07-04                   128
    ## 23     2019-07-04                     4
    ## 17     2019-07-04                     1
    ## 14     2019-07-04                    12
    ## 7      2019-07-04                     4
    ## 5      2019-07-04                     1
    ## 19     2019-07-04                     8
    ## 11     2019-07-04                     2
    ## 16     2019-07-04                     2
    ## 13     2019-07-04                     3
    ## 6      2019-07-04                     2
    ## 18     2019-07-04                     6
    ## 8      2019-07-04                     6
    ## 4      2019-07-04                     5
    ## 21     2019-07-04                     1
    ## 12     2019-07-04                     7
    ## 10     2019-07-04                     1
    ## 2      2019-07-04                     2
    ## 1      2019-07-04                    10
    ## 3      2019-07-04                   180
    ## 20     2019-07-04                    36
    ## 
    ## $`Kajikia albida`
    ##    occSearch                          Dataset Key
    ## 16      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 5       GBIF eacb9186-a68f-4f0a-8c32-94e6eb35e194
    ## 13      GBIF 8f79c802-a58c-447f-99aa-1d6a0790825a
    ## 14      GBIF 56caf05f-1364-4f24-85f6-0c82520c2792
    ## 10      GBIF 66f6192f-6cc0-45fd-a2d1-e76f5ae3eab2
    ## 11      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 4       GBIF 0b81b94a-9761-46e5-a483-df6fcb840cc5
    ## 2       GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 12      GBIF 7a25f7aa-03fb-4322-aaeb-66719e1a9527
    ## 6       GBIF e1a01804-881b-42ae-8f97-1e80f697fd56
    ## 9       GBIF 4bfac3ea-8763-4f4b-a71a-76a6f5f243d3
    ## 8       GBIF 4e5552d1-5eaf-40a3-b48b-01f92da22f17
    ## 7       GBIF 821cc27a-e3bb-4bc5-ac34-89ada245069d
    ## 3       GBIF 6555005d-4594-4a3e-be33-c70e587b63d7
    ## 15      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 1       GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ##                                                                                                                                                                                                                                                                                                                      Citation
    ## 16                                                                                                                                                                             Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 5                                                                         BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh
    ## 13                                                                                                                                                              Bentley A (2020). KUBI Ichthyology Collection. Version 17.66. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/mgjasg
    ## 14                                                                                                                                                       Bentley A (2020). KUBI Ichthyology Tissue Collection. Version 18.54. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/jmsnwg
    ## 10                                                                                                                                                       Casassovici A, Brosens D (2020). Diveboard - Scuba diving citizen science observations. Version 54.28. Diveboard. Occurrence dataset https://doi.org/10.15468/tnjrgy
    ## 11                                                                                                                                                                  Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 4                              Elías Gutiérrez M, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Códigos de barras de la vida en peces y zooplancton de México. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/xmbkgo
    ## 2                                                                                                                                                                                    European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 12                                                                                                                                                                Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd
    ## 6                                                                                                                                                                     Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. Occurrence dataset https://doi.org/10.15468/ad1ovc
    ## 9                                                                                                          Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.224. Museum of Comparative Zoology, Harvard University. Occurrence dataset https://doi.org/10.15468/p5rupv
    ## 8                                                                                                                                                                      Millen B (2019). Ichthyology Collection - Royal Ontario Museum. Version 18.7. Royal Ontario Museum. Occurrence dataset https://doi.org/10.15468/syisbx
    ## 7                                                                                                                                                Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. Occurrence dataset https://doi.org/10.15468/hnhrg3
    ## 3  Pozo de la Tijera M D C, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Fortalecimiento de las colecciones de ECOSUR. Primera fase (Ictioplancton Chetumal). Version 1.3. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/orx3mk
    ## 15                                                                                                                                                                              Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 1                                                                                                                                                                       The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ##    Accession Date Number of Occurrences
    ## 16     2019-07-04                     9
    ## 5      2019-07-04                     3
    ## 13     2019-07-04                    30
    ## 14     2019-07-04                     1
    ## 10     2019-07-04                    10
    ## 11     2019-07-04                     1
    ## 4      2019-07-04                     1
    ## 2      2019-07-04                    18
    ## 12     2019-07-04                     1
    ## 6      2019-07-04                     4
    ## 9      2019-07-04                     1
    ## 8      2019-07-04                     8
    ## 7      2019-07-04                     1
    ## 3      2019-07-04                    46
    ## 15     2019-07-04                     7
    ## 1      2019-07-04                    26
    ## 
    ## $`Kajikia audax`
    ##    occSearch                          Dataset Key
    ## 11      GBIF dce8feb0-6c89-11de-8225-b8a03c50a862
    ## 21      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 5       GBIF cee6464f-cae2-4aab-aa8b-0429a2cb3af0
    ## 6       GBIF eacb9186-a68f-4f0a-8c32-94e6eb35e194
    ## 13      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 22      GBIF f1d263a0-98a0-11de-b4d9-b8a03c50a862
    ## 15      GBIF 18c93d12-34fb-4d3f-903c-b77215a1dcc9
    ## 18      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 16      GBIF 7a25f7aa-03fb-4322-aaeb-66719e1a9527
    ## 9       GBIF e1a01804-881b-42ae-8f97-1e80f697fd56
    ## 4       GBIF e2f48768-39a3-4fdf-894c-52b9776ead07
    ## 19      GBIF afc30a94-6107-488a-b9c0-ba9c4fa68b7c
    ## 7       GBIF c7b39dbc-39f5-47e6-8b70-d49eea899ef9
    ## 8       GBIF 5e2c9b3a-9d7c-4871-af8c-144e4f40e9d2
    ## 17      GBIF 831234b2-f762-11e1-a439-00145eb45e9a
    ## 12      GBIF 793c3890-6c8a-11de-8226-b8a03c50a862
    ## 10      GBIF 821cc27a-e3bb-4bc5-ac34-89ada245069d
    ## 14      GBIF a79c2b50-6c8a-11de-8226-b8a03c50a862
    ## 20      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 2       GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ## 1       GBIF 25f99a40-2327-4c57-9631-1a0825d834fa
    ## 3       GBIF 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ##                                                                                                                                                                                                                                                                                                              Citation
    ## 11                                                                                                                                                                                                 Australian Museum (2020). Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/e7susi
    ## 21                                                                                                                                                                     Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 5                                                       BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd
    ## 6                                                                 BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh
    ## 13                                                                                                                                                          Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 22                                                                                                                                              Chiang W (2014). Taiwan Fisheries Research Institute – Digital archives of coastal and offshore specimens. TELDAP. Occurrence dataset https://doi.org/10.15468/xvxngy
    ## 15                                                                                                                                                      Commonwealth Scientific and Industrial Research Organisation (2020). CSIRO Ichthyology provider for OZCAM. Occurrence dataset https://doi.org/10.15468/azp1pf
    ## 18                                                                                                                                                                           European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 16                                                                                                                                                        Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd
    ## 9                                                                                                                                                             Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. Occurrence dataset https://doi.org/10.15468/ad1ovc
    ## 4  González Acosta A F, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Ampliación de la base de datos de la ictiofauna insular del Golfo de California. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/p5ovq7
    ## 19                                                                                                                                              Grant S, McMahan C (2020). Field Museum of Natural History (Zoology) Fish Collection. Version 13.12. Field Museum. Occurrence dataset https://doi.org/10.15468/alz7wu
    ## 7                                                                                                                    Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. Occurrence dataset https://doi.org/10.15468/i66xdm
    ## 8                                                                          Mackay K (2019). Marine biological observation data from coastal and offshore surveys around New Zealand. Version 1.8. The National Institute of Water and Atmospheric Research (NIWA). Occurrence dataset https://doi.org/10.15468/pzpgop
    ## 17                                                                                                                                                                        Maslenikov K (2019). UWFC Ichthyology Collection. University of Washington Burke Museum. Occurrence dataset https://doi.org/10.15468/vvp7gr
    ## 12                                                                                                                                          Museum and Art Gallery of the Northern Territory (2019). Northern Territory Museum and Art Gallery provider for OZCAM. Occurrence dataset https://doi.org/10.15468/giro3a
    ## 10                                                                                                                                       Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. Occurrence dataset https://doi.org/10.15468/hnhrg3
    ## 14                                                                                                                                                                                                 Queensland Museum (2020). Queensland Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lotsye
    ## 20                                                                                                                                                                      Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 2                                                                                                                                                               The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ## 1                                                                                                                                                 Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/vjeh1p
    ## 3                                                                                                                                                                                         Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. Occurrence dataset https://doi.org/10.15468/ab3s5x
    ##    Accession Date Number of Occurrences
    ## 11     2019-07-04                     1
    ## 21     2019-07-04                     1
    ## 5      2019-07-04                     9
    ## 6      2019-07-04                    50
    ## 13     2019-07-04                     1
    ## 22     2019-07-04                     1
    ## 15     2019-07-04                  6083
    ## 18     2019-07-04                    11
    ## 16     2019-07-04                     1
    ## 9      2019-07-04                     6
    ## 4      2019-07-04                     4
    ## 19     2019-07-04                     1
    ## 7      2019-07-04                    50
    ## 8      2019-07-04                     1
    ## 17     2019-07-04                    12
    ## 12     2019-07-04                     1
    ## 10     2019-07-04                     1
    ## 14     2019-07-04                     1
    ## 20     2019-07-04                     7
    ## 2      2019-07-04                   472
    ## 1      2019-07-04                     6
    ## 3      2019-07-04                     1
    ## 
    ## $`Tetrapturus angustirostris`
    ##    occSearch                          Dataset Key
    ## 13      GBIF dce8feb0-6c89-11de-8225-b8a03c50a862
    ## 20      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 6       GBIF cee6464f-cae2-4aab-aa8b-0429a2cb3af0
    ## 7       GBIF eacb9186-a68f-4f0a-8c32-94e6eb35e194
    ## 19      GBIF 5d6c10bd-ea31-4363-8b79-58c96d859f5b
    ## 21      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 22      GBIF f1d263a0-98a0-11de-b4d9-b8a03c50a862
    ## 15      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 16      GBIF 7a25f7aa-03fb-4322-aaeb-66719e1a9527
    ## 11      GBIF e1a01804-881b-42ae-8f97-1e80f697fd56
    ## 12      GBIF 4bfac3ea-8763-4f4b-a71a-76a6f5f243d3
    ## 10      GBIF c7b39dbc-39f5-47e6-8b70-d49eea899ef9
    ## 8       GBIF 80f63c1e-f762-11e1-a439-00145eb45e9a
    ## 14      GBIF a79c2b50-6c8a-11de-8226-b8a03c50a862
    ## 5       GBIF 514ccc41-0fd0-4a49-86b1-ae1c739eb5d0
    ## 4       GBIF 69e81d22-3207-4663-9a7d-418919d7d779
    ## 18      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 9       GBIF fa375330-6c8a-11de-8226-b8a03c50a862
    ## 2       GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ## 1       GBIF 25f99a40-2327-4c57-9631-1a0825d834fa
    ## 3       GBIF 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 17      GBIF 7c93d290-6c8b-11de-8226-b8a03c50a862
    ##                                                                                                                                                                                                                                                         Citation
    ## 13                                                                                                                                            Australian Museum (2020). Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/e7susi
    ## 20                                                                                                                Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 6  BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd
    ## 7            BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh
    ## 19                                                                                                          Catania D, Fong J (2020). CAS Ichthyology (ICH). Version 150.237. California Academy of Sciences. Occurrence dataset https://doi.org/10.15468/efh2ib
    ## 21                                                                                                     Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 22                                                                                         Chiang W (2014). Taiwan Fisheries Research Institute – Digital archives of coastal and offshore specimens. TELDAP. Occurrence dataset https://doi.org/10.15468/xvxngy
    ## 15                                                                                                                      European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 16                                                                                                   Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd
    ## 11                                                                                                       Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. Occurrence dataset https://doi.org/10.15468/ad1ovc
    ## 12                                            Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.224. Museum of Comparative Zoology, Harvard University. Occurrence dataset https://doi.org/10.15468/p5rupv
    ## 10                                                              Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. Occurrence dataset https://doi.org/10.15468/i66xdm
    ## 8                                                                                                         National Museum of Nature and Science, Japan (2020). Fish specimens of Kagoshima University Museum. Occurrence dataset https://doi.org/10.15468/vcj3j8
    ## 14                                                                                                                                            Queensland Museum (2020). Queensland Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lotsye
    ## 5                                           Raiva R, Santana P (2019). Diversidade e ocorrência de peixes em Inhambane (2009-2017). Version 1.4. National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/4fj2tq
    ## 4                                               Raiva R, Viador R, Santana P (2019). Diversidade e ocorrência de peixes na Zambézia (2003-2016). National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/mrz36h
    ## 18                                                                                                                 Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 9                                                                                                                       South Australian Museum (2020). South Australian Museum Australia provider for OZCAM. Occurrence dataset https://doi.org/10.15468/wz4rrh
    ## 2                                                                                                          The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ## 1                                                                                            Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/vjeh1p
    ## 3                                                                                                                                    Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. Occurrence dataset https://doi.org/10.15468/ab3s5x
    ## 17                                                                                                                            Western Australian Museum (2019). Western Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/5qt0dm
    ##    Accession Date Number of Occurrences
    ## 13     2019-07-04                     1
    ## 20     2019-07-04                     1
    ## 6      2019-07-04                     1
    ## 7      2019-07-04                     2
    ## 19     2019-07-04                     6
    ## 21     2019-07-04                     2
    ## 22     2019-07-04                     1
    ## 15     2019-07-04                    76
    ## 16     2019-07-04                     1
    ## 11     2019-07-04                     2
    ## 12     2019-07-04                     1
    ## 10     2019-07-04                     4
    ## 8      2019-07-04                     1
    ## 14     2019-07-04                     6
    ## 5      2019-07-04                     2
    ## 4      2019-07-04                     1
    ## 18     2019-07-04                     4
    ## 9      2019-07-04                     1
    ## 2      2019-07-04                    50
    ## 1      2019-07-04                     6
    ## 3      2019-07-04                     2
    ## 17     2019-07-04                     3
    ## 
    ## $`Tetrapturus belone`
    ##   occSearch                          Dataset Key
    ## 5      GBIF 8f79c802-a58c-447f-99aa-1d6a0790825a
    ## 1      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 4      GBIF 4bfac3ea-8763-4f4b-a71a-76a6f5f243d3
    ## 3      GBIF 95e635d4-f762-11e1-a439-00145eb45e9a
    ## 2      GBIF f946666e-67dc-4848-9fa8-2162f3559e33
    ## 6      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ##                                                                                                                                                                                                                                   Citation
    ## 5                                                                            Bentley A (2020). KUBI Ichthyology Collection. Version 17.66. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/mgjasg
    ## 1                                                                                                 European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 4                       Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.224. Museum of Comparative Zoology, Harvard University. Occurrence dataset https://doi.org/10.15468/p5rupv
    ## 3                                                       Ranz J (2017). Banco de Datos de la Biodiversidad de la Comunitat Valenciana. Biodiversity data bank of Generalitat Valenciana. Occurrence dataset https://doi.org/10.15468/b4yqdy
    ## 2 ROBERT Solène N, Inventaire National du Patrimoine Naturel (2020). Données d'occurrences Espèces issues de l'inventaire des ZNIEFF. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/ikshke
    ## 6                                                                                            Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ##   Accession Date Number of Occurrences
    ## 5     2019-07-04                     4
    ## 1     2019-07-04                     1
    ## 4     2019-07-04                     1
    ## 3     2019-07-04                     1
    ## 2     2019-07-04                     1
    ## 6     2019-07-04                     1
    ## 
    ## $`Tetrapturus georgii`
    ##   occSearch                          Dataset Key
    ## 4      GBIF 8f79c802-a58c-447f-99aa-1d6a0790825a
    ## 3      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 2      GBIF 821cc27a-e3bb-4bc5-ac34-89ada245069d
    ## 1      GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ##                                                                                                                                                                       Citation
    ## 4                Bentley A (2020). KUBI Ichthyology Collection. Version 17.66. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/mgjasg
    ## 3                                     European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 2 Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. Occurrence dataset https://doi.org/10.15468/hnhrg3
    ## 1                        The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ##   Accession Date Number of Occurrences
    ## 4     2019-07-04                    47
    ## 3     2019-07-04                     1
    ## 2     2019-07-04                     1
    ## 1     2019-07-04                    13
    ## 
    ## $`Tetrapturus pfluegeri`
    ##   occSearch                          Dataset Key
    ## 7      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 2      GBIF cee6464f-cae2-4aab-aa8b-0429a2cb3af0
    ## 3      GBIF eacb9186-a68f-4f0a-8c32-94e6eb35e194
    ## 5      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 4      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 6      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 1      GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ##                                                                                                                                                                                                                                                        Citation
    ## 7                                                                                                                Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 2 BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd
    ## 3           BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh
    ## 5                                                                                                     Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 4                                                                                                                      European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 6                                                                                                                 Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 1                                                                                                         The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ##   Accession Date Number of Occurrences
    ## 7     2019-07-04                     3
    ## 2     2019-07-04                   358
    ## 3     2019-07-04                     5
    ## 5     2019-07-04                     1
    ## 4     2019-07-04                    23
    ## 6     2019-07-04                    13
    ## 1     2019-07-04                     6

It is also possible to print citations separated by species.

``` r
print(myPhyOccCitations, bySpecies = T)
```

    ## <S4 Type Object>
    ## attr(,"occResults")
    ## attr(,"occResults")$`Istiompax indica`
    ##    occSearch                          Dataset Key
    ## 15      GBIF dce8feb0-6c89-11de-8225-b8a03c50a862
    ## 22      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 9       GBIF cee6464f-cae2-4aab-aa8b-0429a2cb3af0
    ## 23      GBIF 5d6c10bd-ea31-4363-8b79-58c96d859f5b
    ## 17      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 14      GBIF b5267bb3-217b-49a1-b9c9-9024cdad2666
    ## 7       GBIF 0b81b94a-9761-46e5-a483-df6fcb840cc5
    ## 5       GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 19      GBIF 7a25f7aa-03fb-4322-aaeb-66719e1a9527
    ## 11      GBIF c7b39dbc-39f5-47e6-8b70-d49eea899ef9
    ## 16      GBIF 793c3890-6c8a-11de-8226-b8a03c50a862
    ## 13      GBIF 39905320-6c8a-11de-8226-b8a03c50a862
    ## 6       GBIF 6555005d-4594-4a3e-be33-c70e587b63d7
    ## 18      GBIF a79c2b50-6c8a-11de-8226-b8a03c50a862
    ## 8       GBIF 514ccc41-0fd0-4a49-86b1-ae1c739eb5d0
    ## 4       GBIF 69e81d22-3207-4663-9a7d-418919d7d779
    ## 21      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 12      GBIF 80ac6ada-f762-11e1-a439-00145eb45e9a
    ## 10      GBIF 41eb63f5-9a19-4f2c-8bf3-a1247e6b6c69
    ## 2       GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ## 1       GBIF 25f99a40-2327-4c57-9631-1a0825d834fa
    ## 3       GBIF 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 20      GBIF 7c93d290-6c8b-11de-8226-b8a03c50a862
    ##                                                                                                                                                                                                                                                                                                                      Citation
    ## 15                                                                                                                                                                                                         Australian Museum (2020). Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/e7susi
    ## 22                                                                                                                                                                             Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 9                                                               BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd
    ## 23                                                                                                                                                                       Catania D, Fong J (2020). CAS Ichthyology (ICH). Version 150.237. California Academy of Sciences. Occurrence dataset https://doi.org/10.15468/efh2ib
    ## 17                                                                                                                                                                  Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 14                                                                                                                                                 CSIRO Oceans and Atmosphere (2020). CSIRO, Rachel Cruises, Shark Data, Arafura Sea, North Australia, 1984. Version 6.2. Occurrence dataset https://doi.org/10.15468/yickr6
    ## 7                              Elías Gutiérrez M, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Códigos de barras de la vida en peces y zooplancton de México. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/xmbkgo
    ## 5                                                                                                                                                                                    European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 19                                                                                                                                                                Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd
    ## 11                                                                                                                           Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. Occurrence dataset https://doi.org/10.15468/i66xdm
    ## 16                                                                                                                                                  Museum and Art Gallery of the Northern Territory (2019). Northern Territory Museum and Art Gallery provider for OZCAM. Occurrence dataset https://doi.org/10.15468/giro3a
    ## 13                                                                                                                                                                                                           Museums Victoria (2020). Museums Victoria provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lp1ctu
    ## 6  Pozo de la Tijera M D C, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Fortalecimiento de las colecciones de ECOSUR. Primera fase (Ictioplancton Chetumal). Version 1.3. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/orx3mk
    ## 18                                                                                                                                                                                                         Queensland Museum (2020). Queensland Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lotsye
    ## 8                                                                                                        Raiva R, Santana P (2019). Diversidade e ocorrência de peixes em Inhambane (2009-2017). Version 1.4. National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/4fj2tq
    ## 4                                                                                                            Raiva R, Viador R, Santana P (2019). Diversidade e ocorrência de peixes na Zambézia (2003-2016). National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/mrz36h
    ## 21                                                                                                                                                                              Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 12        Sánchez González S, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Taxonomía y sistemática de la Ictiofauna de la Bahía de Banderas del Estado de Nayarit, México. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/uhrwsl
    ## 10                                                                                                                                                         Shane G (2018). Pelagic fish food web linkages, Queensland, Australia (2003-2005). CSIRO Oceans and Atmosphere. Occurrence dataset https://doi.org/10.15468/yy5wdp
    ## 2                                                                                                                                                                       The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ## 1                                                                                                                                                         Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/vjeh1p
    ## 3                                                                                                                                                                                                 Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. Occurrence dataset https://doi.org/10.15468/ab3s5x
    ## 20                                                                                                                                                                                         Western Australian Museum (2019). Western Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/5qt0dm
    ##    Accession Date Number of Occurrences
    ## 15     2019-07-04                     1
    ## 22     2019-07-04                    46
    ## 9      2019-07-04                   128
    ## 23     2019-07-04                     4
    ## 17     2019-07-04                     1
    ## 14     2019-07-04                    12
    ## 7      2019-07-04                     4
    ## 5      2019-07-04                     1
    ## 19     2019-07-04                     8
    ## 11     2019-07-04                     2
    ## 16     2019-07-04                     2
    ## 13     2019-07-04                     3
    ## 6      2019-07-04                     2
    ## 18     2019-07-04                     6
    ## 8      2019-07-04                     6
    ## 4      2019-07-04                     5
    ## 21     2019-07-04                     1
    ## 12     2019-07-04                     7
    ## 10     2019-07-04                     1
    ## 2      2019-07-04                     2
    ## 1      2019-07-04                    10
    ## 3      2019-07-04                   180
    ## 20     2019-07-04                    36
    ## 
    ## attr(,"occResults")$`Kajikia albida`
    ##    occSearch                          Dataset Key
    ## 16      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 5       GBIF eacb9186-a68f-4f0a-8c32-94e6eb35e194
    ## 13      GBIF 8f79c802-a58c-447f-99aa-1d6a0790825a
    ## 14      GBIF 56caf05f-1364-4f24-85f6-0c82520c2792
    ## 10      GBIF 66f6192f-6cc0-45fd-a2d1-e76f5ae3eab2
    ## 11      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 4       GBIF 0b81b94a-9761-46e5-a483-df6fcb840cc5
    ## 2       GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 12      GBIF 7a25f7aa-03fb-4322-aaeb-66719e1a9527
    ## 6       GBIF e1a01804-881b-42ae-8f97-1e80f697fd56
    ## 9       GBIF 4bfac3ea-8763-4f4b-a71a-76a6f5f243d3
    ## 8       GBIF 4e5552d1-5eaf-40a3-b48b-01f92da22f17
    ## 7       GBIF 821cc27a-e3bb-4bc5-ac34-89ada245069d
    ## 3       GBIF 6555005d-4594-4a3e-be33-c70e587b63d7
    ## 15      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 1       GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ##                                                                                                                                                                                                                                                                                                                      Citation
    ## 16                                                                                                                                                                             Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 5                                                                         BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh
    ## 13                                                                                                                                                              Bentley A (2020). KUBI Ichthyology Collection. Version 17.66. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/mgjasg
    ## 14                                                                                                                                                       Bentley A (2020). KUBI Ichthyology Tissue Collection. Version 18.54. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/jmsnwg
    ## 10                                                                                                                                                       Casassovici A, Brosens D (2020). Diveboard - Scuba diving citizen science observations. Version 54.28. Diveboard. Occurrence dataset https://doi.org/10.15468/tnjrgy
    ## 11                                                                                                                                                                  Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 4                              Elías Gutiérrez M, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Códigos de barras de la vida en peces y zooplancton de México. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/xmbkgo
    ## 2                                                                                                                                                                                    European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 12                                                                                                                                                                Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd
    ## 6                                                                                                                                                                     Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. Occurrence dataset https://doi.org/10.15468/ad1ovc
    ## 9                                                                                                          Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.224. Museum of Comparative Zoology, Harvard University. Occurrence dataset https://doi.org/10.15468/p5rupv
    ## 8                                                                                                                                                                      Millen B (2019). Ichthyology Collection - Royal Ontario Museum. Version 18.7. Royal Ontario Museum. Occurrence dataset https://doi.org/10.15468/syisbx
    ## 7                                                                                                                                                Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. Occurrence dataset https://doi.org/10.15468/hnhrg3
    ## 3  Pozo de la Tijera M D C, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Fortalecimiento de las colecciones de ECOSUR. Primera fase (Ictioplancton Chetumal). Version 1.3. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/orx3mk
    ## 15                                                                                                                                                                              Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 1                                                                                                                                                                       The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ##    Accession Date Number of Occurrences
    ## 16     2019-07-04                     9
    ## 5      2019-07-04                     3
    ## 13     2019-07-04                    30
    ## 14     2019-07-04                     1
    ## 10     2019-07-04                    10
    ## 11     2019-07-04                     1
    ## 4      2019-07-04                     1
    ## 2      2019-07-04                    18
    ## 12     2019-07-04                     1
    ## 6      2019-07-04                     4
    ## 9      2019-07-04                     1
    ## 8      2019-07-04                     8
    ## 7      2019-07-04                     1
    ## 3      2019-07-04                    46
    ## 15     2019-07-04                     7
    ## 1      2019-07-04                    26
    ## 
    ## attr(,"occResults")$`Kajikia audax`
    ##    occSearch                          Dataset Key
    ## 11      GBIF dce8feb0-6c89-11de-8225-b8a03c50a862
    ## 21      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 5       GBIF cee6464f-cae2-4aab-aa8b-0429a2cb3af0
    ## 6       GBIF eacb9186-a68f-4f0a-8c32-94e6eb35e194
    ## 13      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 22      GBIF f1d263a0-98a0-11de-b4d9-b8a03c50a862
    ## 15      GBIF 18c93d12-34fb-4d3f-903c-b77215a1dcc9
    ## 18      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 16      GBIF 7a25f7aa-03fb-4322-aaeb-66719e1a9527
    ## 9       GBIF e1a01804-881b-42ae-8f97-1e80f697fd56
    ## 4       GBIF e2f48768-39a3-4fdf-894c-52b9776ead07
    ## 19      GBIF afc30a94-6107-488a-b9c0-ba9c4fa68b7c
    ## 7       GBIF c7b39dbc-39f5-47e6-8b70-d49eea899ef9
    ## 8       GBIF 5e2c9b3a-9d7c-4871-af8c-144e4f40e9d2
    ## 17      GBIF 831234b2-f762-11e1-a439-00145eb45e9a
    ## 12      GBIF 793c3890-6c8a-11de-8226-b8a03c50a862
    ## 10      GBIF 821cc27a-e3bb-4bc5-ac34-89ada245069d
    ## 14      GBIF a79c2b50-6c8a-11de-8226-b8a03c50a862
    ## 20      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 2       GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ## 1       GBIF 25f99a40-2327-4c57-9631-1a0825d834fa
    ## 3       GBIF 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ##                                                                                                                                                                                                                                                                                                              Citation
    ## 11                                                                                                                                                                                                 Australian Museum (2020). Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/e7susi
    ## 21                                                                                                                                                                     Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 5                                                       BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd
    ## 6                                                                 BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh
    ## 13                                                                                                                                                          Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 22                                                                                                                                              Chiang W (2014). Taiwan Fisheries Research Institute – Digital archives of coastal and offshore specimens. TELDAP. Occurrence dataset https://doi.org/10.15468/xvxngy
    ## 15                                                                                                                                                      Commonwealth Scientific and Industrial Research Organisation (2020). CSIRO Ichthyology provider for OZCAM. Occurrence dataset https://doi.org/10.15468/azp1pf
    ## 18                                                                                                                                                                           European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 16                                                                                                                                                        Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd
    ## 9                                                                                                                                                             Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. Occurrence dataset https://doi.org/10.15468/ad1ovc
    ## 4  González Acosta A F, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Ampliación de la base de datos de la ictiofauna insular del Golfo de California. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/p5ovq7
    ## 19                                                                                                                                              Grant S, McMahan C (2020). Field Museum of Natural History (Zoology) Fish Collection. Version 13.12. Field Museum. Occurrence dataset https://doi.org/10.15468/alz7wu
    ## 7                                                                                                                    Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. Occurrence dataset https://doi.org/10.15468/i66xdm
    ## 8                                                                          Mackay K (2019). Marine biological observation data from coastal and offshore surveys around New Zealand. Version 1.8. The National Institute of Water and Atmospheric Research (NIWA). Occurrence dataset https://doi.org/10.15468/pzpgop
    ## 17                                                                                                                                                                        Maslenikov K (2019). UWFC Ichthyology Collection. University of Washington Burke Museum. Occurrence dataset https://doi.org/10.15468/vvp7gr
    ## 12                                                                                                                                          Museum and Art Gallery of the Northern Territory (2019). Northern Territory Museum and Art Gallery provider for OZCAM. Occurrence dataset https://doi.org/10.15468/giro3a
    ## 10                                                                                                                                       Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. Occurrence dataset https://doi.org/10.15468/hnhrg3
    ## 14                                                                                                                                                                                                 Queensland Museum (2020). Queensland Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lotsye
    ## 20                                                                                                                                                                      Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 2                                                                                                                                                               The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ## 1                                                                                                                                                 Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/vjeh1p
    ## 3                                                                                                                                                                                         Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. Occurrence dataset https://doi.org/10.15468/ab3s5x
    ##    Accession Date Number of Occurrences
    ## 11     2019-07-04                     1
    ## 21     2019-07-04                     1
    ## 5      2019-07-04                     9
    ## 6      2019-07-04                    50
    ## 13     2019-07-04                     1
    ## 22     2019-07-04                     1
    ## 15     2019-07-04                  6083
    ## 18     2019-07-04                    11
    ## 16     2019-07-04                     1
    ## 9      2019-07-04                     6
    ## 4      2019-07-04                     4
    ## 19     2019-07-04                     1
    ## 7      2019-07-04                    50
    ## 8      2019-07-04                     1
    ## 17     2019-07-04                    12
    ## 12     2019-07-04                     1
    ## 10     2019-07-04                     1
    ## 14     2019-07-04                     1
    ## 20     2019-07-04                     7
    ## 2      2019-07-04                   472
    ## 1      2019-07-04                     6
    ## 3      2019-07-04                     1
    ## 
    ## attr(,"occResults")$`Tetrapturus angustirostris`
    ##    occSearch                          Dataset Key
    ## 13      GBIF dce8feb0-6c89-11de-8225-b8a03c50a862
    ## 20      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 6       GBIF cee6464f-cae2-4aab-aa8b-0429a2cb3af0
    ## 7       GBIF eacb9186-a68f-4f0a-8c32-94e6eb35e194
    ## 19      GBIF 5d6c10bd-ea31-4363-8b79-58c96d859f5b
    ## 21      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 22      GBIF f1d263a0-98a0-11de-b4d9-b8a03c50a862
    ## 15      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 16      GBIF 7a25f7aa-03fb-4322-aaeb-66719e1a9527
    ## 11      GBIF e1a01804-881b-42ae-8f97-1e80f697fd56
    ## 12      GBIF 4bfac3ea-8763-4f4b-a71a-76a6f5f243d3
    ## 10      GBIF c7b39dbc-39f5-47e6-8b70-d49eea899ef9
    ## 8       GBIF 80f63c1e-f762-11e1-a439-00145eb45e9a
    ## 14      GBIF a79c2b50-6c8a-11de-8226-b8a03c50a862
    ## 5       GBIF 514ccc41-0fd0-4a49-86b1-ae1c739eb5d0
    ## 4       GBIF 69e81d22-3207-4663-9a7d-418919d7d779
    ## 18      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 9       GBIF fa375330-6c8a-11de-8226-b8a03c50a862
    ## 2       GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ## 1       GBIF 25f99a40-2327-4c57-9631-1a0825d834fa
    ## 3       GBIF 50c9509d-22c7-4a22-a47d-8c48425ef4a7
    ## 17      GBIF 7c93d290-6c8b-11de-8226-b8a03c50a862
    ##                                                                                                                                                                                                                                                         Citation
    ## 13                                                                                                                                            Australian Museum (2020). Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/e7susi
    ## 20                                                                                                                Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 6  BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd
    ## 7            BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh
    ## 19                                                                                                          Catania D, Fong J (2020). CAS Ichthyology (ICH). Version 150.237. California Academy of Sciences. Occurrence dataset https://doi.org/10.15468/efh2ib
    ## 21                                                                                                     Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 22                                                                                         Chiang W (2014). Taiwan Fisheries Research Institute – Digital archives of coastal and offshore specimens. TELDAP. Occurrence dataset https://doi.org/10.15468/xvxngy
    ## 15                                                                                                                      European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 16                                                                                                   Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd
    ## 11                                                                                                       Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. Occurrence dataset https://doi.org/10.15468/ad1ovc
    ## 12                                            Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.224. Museum of Comparative Zoology, Harvard University. Occurrence dataset https://doi.org/10.15468/p5rupv
    ## 10                                                              Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. Occurrence dataset https://doi.org/10.15468/i66xdm
    ## 8                                                                                                         National Museum of Nature and Science, Japan (2020). Fish specimens of Kagoshima University Museum. Occurrence dataset https://doi.org/10.15468/vcj3j8
    ## 14                                                                                                                                            Queensland Museum (2020). Queensland Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lotsye
    ## 5                                           Raiva R, Santana P (2019). Diversidade e ocorrência de peixes em Inhambane (2009-2017). Version 1.4. National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/4fj2tq
    ## 4                                               Raiva R, Viador R, Santana P (2019). Diversidade e ocorrência de peixes na Zambézia (2003-2016). National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/mrz36h
    ## 18                                                                                                                 Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 9                                                                                                                       South Australian Museum (2020). South Australian Museum Australia provider for OZCAM. Occurrence dataset https://doi.org/10.15468/wz4rrh
    ## 2                                                                                                          The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ## 1                                                                                            Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/vjeh1p
    ## 3                                                                                                                                    Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. Occurrence dataset https://doi.org/10.15468/ab3s5x
    ## 17                                                                                                                            Western Australian Museum (2019). Western Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/5qt0dm
    ##    Accession Date Number of Occurrences
    ## 13     2019-07-04                     1
    ## 20     2019-07-04                     1
    ## 6      2019-07-04                     1
    ## 7      2019-07-04                     2
    ## 19     2019-07-04                     6
    ## 21     2019-07-04                     2
    ## 22     2019-07-04                     1
    ## 15     2019-07-04                    76
    ## 16     2019-07-04                     1
    ## 11     2019-07-04                     2
    ## 12     2019-07-04                     1
    ## 10     2019-07-04                     4
    ## 8      2019-07-04                     1
    ## 14     2019-07-04                     6
    ## 5      2019-07-04                     2
    ## 4      2019-07-04                     1
    ## 18     2019-07-04                     4
    ## 9      2019-07-04                     1
    ## 2      2019-07-04                    50
    ## 1      2019-07-04                     6
    ## 3      2019-07-04                     2
    ## 17     2019-07-04                     3
    ## 
    ## attr(,"occResults")$`Tetrapturus belone`
    ##   occSearch                          Dataset Key
    ## 5      GBIF 8f79c802-a58c-447f-99aa-1d6a0790825a
    ## 1      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 4      GBIF 4bfac3ea-8763-4f4b-a71a-76a6f5f243d3
    ## 3      GBIF 95e635d4-f762-11e1-a439-00145eb45e9a
    ## 2      GBIF f946666e-67dc-4848-9fa8-2162f3559e33
    ## 6      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ##                                                                                                                                                                                                                                   Citation
    ## 5                                                                            Bentley A (2020). KUBI Ichthyology Collection. Version 17.66. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/mgjasg
    ## 1                                                                                                 European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 4                       Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.224. Museum of Comparative Zoology, Harvard University. Occurrence dataset https://doi.org/10.15468/p5rupv
    ## 3                                                       Ranz J (2017). Banco de Datos de la Biodiversidad de la Comunitat Valenciana. Biodiversity data bank of Generalitat Valenciana. Occurrence dataset https://doi.org/10.15468/b4yqdy
    ## 2 ROBERT Solène N, Inventaire National du Patrimoine Naturel (2020). Données d'occurrences Espèces issues de l'inventaire des ZNIEFF. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/ikshke
    ## 6                                                                                            Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ##   Accession Date Number of Occurrences
    ## 5     2019-07-04                     4
    ## 1     2019-07-04                     1
    ## 4     2019-07-04                     1
    ## 3     2019-07-04                     1
    ## 2     2019-07-04                     1
    ## 6     2019-07-04                     1
    ## 
    ## attr(,"occResults")$`Tetrapturus georgii`
    ##   occSearch                          Dataset Key
    ## 4      GBIF 8f79c802-a58c-447f-99aa-1d6a0790825a
    ## 3      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 2      GBIF 821cc27a-e3bb-4bc5-ac34-89ada245069d
    ## 1      GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ##                                                                                                                                                                       Citation
    ## 4                Bentley A (2020). KUBI Ichthyology Collection. Version 17.66. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/mgjasg
    ## 3                                     European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 2 Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. Occurrence dataset https://doi.org/10.15468/hnhrg3
    ## 1                        The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ##   Accession Date Number of Occurrences
    ## 4     2019-07-04                    47
    ## 3     2019-07-04                     1
    ## 2     2019-07-04                     1
    ## 1     2019-07-04                    13
    ## 
    ## attr(,"occResults")$`Tetrapturus pfluegeri`
    ##   occSearch                          Dataset Key
    ## 7      GBIF 0e3d6f05-a287-4ffd-852d-4e17db22d810
    ## 2      GBIF cee6464f-cae2-4aab-aa8b-0429a2cb3af0
    ## 3      GBIF eacb9186-a68f-4f0a-8c32-94e6eb35e194
    ## 5      GBIF 54bae6ef-8b4e-4ad3-8729-c4296299e5c7
    ## 4      GBIF ad43e954-dd79-4986-ae34-9ccdbd8bf568
    ## 6      GBIF eccf4b09-f0c8-462d-a48c-41a7ce36815a
    ## 1      GBIF 040c5662-da76-4782-a48e-cdea1892d14c
    ##                                                                                                                                                                                                                                                        Citation
    ## 7                                                                                                                Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0
    ## 2 BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd
    ## 3           BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh
    ## 5                                                                                                     Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361
    ## 4                                                                                                                      European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv
    ## 6                                                                                                                 Robins R (2020). UF FLMNH Ichthyology. Version 117.276. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel
    ## 1                                                                                                         The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6
    ##   Accession Date Number of Occurrences
    ## 7     2019-07-04                     3
    ## 2     2019-07-04                   358
    ## 3     2019-07-04                     5
    ## 5     2019-07-04                     1
    ## 4     2019-07-04                    23
    ## 6     2019-07-04                    13
    ## 1     2019-07-04                     6
    ## 
    ## attr(,"class")
    ## [1] "occCiteCitation"
    ## attr(,"class")attr(,"package")
    ## [1] "occCite"

------------------------------------------------------------------------

Visualization features
======================

Search result summary figures
-----------------------------

occCite includes a function called `sumFig.occCite()` which is capable
of generating three types of plots from an `occCiteData` object. First,
let’s see how the results of our multispecies query looks.

``` r
sumFig.occCite(myPhyOccCiteObject, 
               bySpecies = F, 
               plotTypes = c("yearHistogram", "source", "aggregator"))
```

<img src="README_files/figure-markdown_github/summary figures overall-1.png" width="33%" /><img src="README_files/figure-markdown_github/summary figures overall-2.png" width="33%" /><img src="README_files/figure-markdown_github/summary figures overall-3.png" width="33%" />

We can also generate plots for each species in the `occCiteData` object
individually. Since GBIF is the only aggregator we used for the query,
I’ll skip generating the aggregator plot.

``` r
sumFig.occCite(myPhyOccCiteObject, 
               bySpecies = T, 
               plotTypes = c("yearHistogram", "source"))
```

<img src="README_files/figure-markdown_github/summary figures by species-1.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-2.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-3.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-4.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-5.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-6.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-7.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-8.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-9.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-10.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-11.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-12.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-13.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-14.png" width="50%" />

Mapping occCite search results
------------------------------

occCite also contains tools to map search results. We can pass occCite
objects to be mapped as an interactive html widget using `leaflet`. If
there are multiple species in a single occCite object, occurrences will
be color-coded by species. If you click on a single occurrence, you will
be able to see the species, the coordinates, the date on which it was
collected, the dataset to which it belongs, and the dataservice that
provided the record.

``` r
map.occCite(mySimpleOccCiteObject, cluster = T)
```
