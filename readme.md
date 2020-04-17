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
                          pwd = "12345");
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
                            checkPreviousGBIFDownload = T);
```

Here is what the GBIF results look like:

``` r
# GBIF search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);
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
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$BIEN$OccurrenceTable);
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
    ##  OccCite query occurred on: 17 April, 2020
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
mySimpleOccCitations <- occCitation(mySimpleOccCiteObject);
```

Here is a simple way of generating a formatted citation document from
the results of `occCitation()`.

``` r
cat(paste(mySimpleOccCitations$Citation, 
          " Accessed via ", mySimpleOccCitations$occSearch, 
          " on ", mySimpleOccCitations$`Accession Date`, "."), 
    sep = "\n");
```

    ## Cameron E, Auckland Museum A M (2020). Auckland Museum Botany Collection. Version 1.46. Auckland War Memorial Museum. Occurrence dataset https://doi.org/10.15468/mnjkvv  Accessed via  GBIF  on  2019-07-15 .
    ## Capers R (2014). CONN. University of Connecticut. Occurrence dataset https://doi.org/10.15468/w35jmd  Accessed via  GBIF  on  2019-07-15 .
    ## iNaturalist.org (2020). iNaturalist Research-grade Observations. Occurrence dataset https://doi.org/10.15468/ab3s5x  Accessed via  GBIF  on  2019-07-15 .
    ## Magill B, Solomon J, Stimmel H (2020). Tropicos Specimen Data. Missouri Botanical Garden. Occurrence dataset https://doi.org/10.15468/hja69f  Accessed via  GBIF  on  2019-07-15 .
    ## Missouri Botanical Garden,Herbarium  Accessed via  BIEN  on  NA .
    ## MNHN  Accessed via  BIEN  on  2018-08-14 .
    ## MNHN - Museum national d'Histoire naturelle (2020). The vascular plants collection (P) at the Herbarium of the Muséum national d'Histoire Naturelle (MNHN - Paris). Version 69.164. Occurrence dataset https://doi.org/10.15468/nc6rxy  Accessed via  GBIF  on  2019-07-15 .
    ## naturgucker.de. naturgucker. Occurrence dataset https://doi.org/10.15468/uc1apo  Accessed via  GBIF  on  2019-07-15 .
    ## NSW  Accessed via  BIEN  on  2018-08-14 .
    ## Ranwashe F (2019). BODATSA: Botanical Collections. Version 1.4. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/2aki0q  Accessed via  GBIF  on  2019-07-15 .
    ## SANBI  Accessed via  BIEN  on  2018-08-14 .
    ## Senckenberg. African Plants - a photo guide. Occurrence dataset https://doi.org/10.15468/r9azth  Accessed via  GBIF  on  2019-07-15 .
    ## South African National Biodiversity Institute (2018). PRECIS. Occurrence dataset https://doi.org/10.15468/rckmn2  Accessed via  GBIF  on  2019-07-15 .
    ## Tela Botanica. Carnet en Ligne. Occurrence dataset https://doi.org/10.15468/rydcn2  Accessed via  GBIF  on  2019-07-15 .
    ## UConn  Accessed via  BIEN  on  2018-08-14 .

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
                                  datasources = c("NCBI", "EOL", "ITIS"));
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
previously-downloaded datasets from your computer by specifying the
general location of your downloaded `.zip` files. `occQuery` will crawl
through your specified `GBIFDownloadDirectory` to collect all the `.zip`
files contained in that folder and its subfolders. It will then improt
the most recent downloads that match your taxon list. These GBIF data
will be appended to a BIEN search the same as if you do the simple
real-time search (if you chose BIEN as well as GBIF), as was shown
above. `checkPreviousGBIFDownload` is `TRUE` by default, but if
`loadLocalGBIFDownload` is `TRUE`, `occQuery` will ignore
`checkPreviousDownload`. It is also worth noting that `occCite` does not
currently support mixed data download sources. That is, you cannot do
GBIF queries for some taxa, download previously-prepared datasets for
others, and load the rest from local datasets on your computer.

``` r
# Simple load
myOldOccCiteObject <- occQuery(x = "Protea cynaroides", 
                                  datasources = c("gbif", "bien"), 
                                  GBIFLogin = NULL, 
                                  GBIFDownloadDirectory = paste0(path.package("occCite"), "/extdata/"),
                                  loadLocalGBIFDownload = T,
                                  checkPreviousGBIFDownload = F);
```

Here is the result. Look familiar?

``` r
#GBIF search results
head(myOldOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);
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
    ##  OccCite query occurred on: 17 April, 2020
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
myOldOccCitations <- occCitation(myOldOccCiteObject);
cat(paste0(mySimpleOccCitations$Citation, " Accessed via ", mySimpleOccCitations$occSearch, " on ", mySimpleOccCitations$`Accession Date`, "."), sep = "\n");
```

    ## Cameron E, Auckland Museum A M (2020). Auckland Museum Botany Collection. Version 1.46. Auckland War Memorial Museum. Occurrence dataset https://doi.org/10.15468/mnjkvv Accessed via GBIF on 2019-07-15.
    ## Capers R (2014). CONN. University of Connecticut. Occurrence dataset https://doi.org/10.15468/w35jmd Accessed via GBIF on 2019-07-15.
    ## iNaturalist.org (2020). iNaturalist Research-grade Observations. Occurrence dataset https://doi.org/10.15468/ab3s5x Accessed via GBIF on 2019-07-15.
    ## Magill B, Solomon J, Stimmel H (2020). Tropicos Specimen Data. Missouri Botanical Garden. Occurrence dataset https://doi.org/10.15468/hja69f Accessed via GBIF on 2019-07-15.
    ## Missouri Botanical Garden,Herbarium Accessed via BIEN on NA.
    ## MNHN Accessed via BIEN on 2018-08-14.
    ## MNHN - Museum national d'Histoire naturelle (2020). The vascular plants collection (P) at the Herbarium of the Muséum national d'Histoire Naturelle (MNHN - Paris). Version 69.164. Occurrence dataset https://doi.org/10.15468/nc6rxy Accessed via GBIF on 2019-07-15.
    ## naturgucker.de. naturgucker. Occurrence dataset https://doi.org/10.15468/uc1apo Accessed via GBIF on 2019-07-15.
    ## NSW Accessed via BIEN on 2018-08-14.
    ## Ranwashe F (2019). BODATSA: Botanical Collections. Version 1.4. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/2aki0q Accessed via GBIF on 2019-07-15.
    ## SANBI Accessed via BIEN on 2018-08-14.
    ## Senckenberg. African Plants - a photo guide. Occurrence dataset https://doi.org/10.15468/r9azth Accessed via GBIF on 2019-07-15.
    ## South African National Biodiversity Institute (2018). PRECIS. Occurrence dataset https://doi.org/10.15468/rckmn2 Accessed via GBIF on 2019-07-15.
    ## Tela Botanica. Carnet en Ligne. Occurrence dataset https://doi.org/10.15468/rydcn2 Accessed via GBIF on 2019-07-15.
    ## UConn Accessed via BIEN on 2018-08-14.

Note that you can also load multiple species using either a vector of
species names or a phylogeny (provided you have previously downloaded
data for all of the species of interest), and you can load occurrences
from non-GBIF datasources (e.g. BIEN) in the same query.

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
library(ape);
#Get tree
treeFile <- system.file("extdata/Fish_12Tax_time_calibrated.tre", package='occCite');
tree <- ape::read.nexus(treeFile);
#Query databases for names
myPhyOccCiteObject <- studyTaxonList(x = tree, datasources = "NCBI");
#Query GBIF for occurrence data
myPhyOccCiteObject <- occQuery(x = myPhyOccCiteObject, 
                            datasources = "gbif",
                            GBIFDownloadDirectory = paste0(path.package("occCite"), "/extdata/"), 
                            loadLocalGBIFDownload = T,
                            checkPreviousGBIFDownload = F);
```

    ## Warning in if (searchTaxa == "No match" | is.null(searchTaxa)) {: the condition
    ## has length > 1 and only the first element will be used

``` r
# What does a multispecies query look like?
summary(myPhyOccCiteObject)
```

    ##  
    ##  OccCite query occurred on: 17 April, 2020
    ##  
    ##  User query type: User-supplied phylogeny.
    ##  
    ##  Sources for taxonomic rectification: NCBI
    ##      
    ##  
    ##  Taxonomic cleaning results:     
    ## 
    ##                    Input Name                 Best Match
    ## 1            Istiompax_indica           Istiompax indica
    ## 2        Istiophorus_albicans       Istiophorus albicans
    ## 3     Istiophorus_platypterus    Istiophorus platypterus
    ## 4              Kajikia_albida             Kajikia albida
    ## 5               Kajikia_audax              Kajikia audax
    ## 6           Makaira_nigricans          Makaira nigricans
    ## 7  Tetrapturus_angustirostris Tetrapturus angustirostris
    ## 8          Tetrapturus_belone         Tetrapturus belone
    ## 9         Tetrapturus_georgii        Tetrapturus georgii
    ## 10      Tetrapturus_pfluegeri      Tetrapturus pfluegeri
    ## 11        Trachurus_trachurus        Trachurus trachurus
    ## 12            Xiphias_gladius            Xiphias gladius
    ##    Taxonomic Databases w/ Matches
    ## 1                            NCBI
    ## 2                            NCBI
    ## 3                            NCBI
    ## 4                            NCBI
    ## 5                            NCBI
    ## 6                            NCBI
    ## 7                            NCBI
    ## 8                            NCBI
    ## 9                            NCBI
    ## 10                           NCBI
    ## 11                           NCBI
    ## 12                           NCBI
    ##  
    ##  Sources for occurrence data: gbif
    ##      
    ##                       Species Occurrences Sources
    ## 1            Istiompax indica         468      23
    ## 2        Istiophorus albicans         723      10
    ## 3     Istiophorus platypterus       16368      66
    ## 4              Kajikia albida         167      16
    ## 5               Kajikia audax        6721      22
    ## 6           Makaira nigricans         402      24
    ## 7  Tetrapturus angustirostris         174      22
    ## 8          Tetrapturus belone           9       6
    ## 9         Tetrapturus georgii          62       4
    ## 10      Tetrapturus pfluegeri         409       7
    ## 11        Trachurus trachurus        9916      76
    ## 12            Xiphias gladius        1408      60
    ##  
    ##  GBIF dataset DOIs:  
    ## 
    ##                       Species GBIF Access Date           GBIF DOI
    ## 1            Istiompax indica       2019-07-04 10.15468/dl.crapuf
    ## 2        Istiophorus albicans       2019-07-04 10.15468/dl.qvapht
    ## 3     Istiophorus platypterus       2019-07-04 10.15468/dl.ps4axk
    ## 4              Kajikia albida       2019-07-04 10.15468/dl.lnwf6a
    ## 5               Kajikia audax       2019-07-04 10.15468/dl.txromp
    ## 6           Makaira nigricans       2019-07-04 10.15468/dl.lpwjh4
    ## 7  Tetrapturus angustirostris       2019-07-04 10.15468/dl.mumi5e
    ## 8          Tetrapturus belone       2019-07-04 10.15468/dl.q2nxb1
    ## 9         Tetrapturus georgii       2019-07-04 10.15468/dl.h860up
    ## 10      Tetrapturus pfluegeri       2019-07-04 10.15468/dl.qjidbs
    ## 11        Trachurus trachurus       2019-07-04 10.15468/dl.eabzvg
    ## 12            Xiphias gladius       2019-07-04 10.15468/dl.blqftz

``` r
#Get citations
myPhyOccCitations <- occCitation(myPhyOccCiteObject);

#Print citations as text with accession dates.
cat(paste(myPhyOccCitations$Citation, 
           " Accessed via ", myPhyOccCitations$occSearch, 
           " on ", myPhyOccCitations$`Accession Date`, "."), sep = "\n");
```

    ## Atkinson L, Ranwashe F (2017). FBIP:SAEON: Historical Research Survey Database (1897-1949). Version 1.2. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/sfwehq  Accessed via  GBIF  on  2019-07-04 .
    ## Atlas of Life in the Coastal Wilderness (2020). Atlas of Life in the Coastal Wilderness. Occurrence dataset https://doi.org/10.15468/rtxjkt  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2019). Dry Tortugas Reef Visual Census 2008. Version 1.1. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/oomxex  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2019). Florida Keys Reef Visual Census 1994. Version 1.1. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/rdkfyf  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2019). Florida Keys Reef Visual Census 1996. Version 1.1. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/gaekez  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2019). Florida Keys Reef Visual Census 1999. Version 1.1. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/dwxlan  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2019). Florida Keys Reef Visual Census 2002. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/pcikkj  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2019). Florida Keys Reef Visual Census 2009. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/tnn5ra  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2019). Florida Keys Reef Visual Census 2012. Version 1.4. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/vnvtmr  Accessed via  GBIF  on  2019-07-04 .
    ## Australian Museum (2020). Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/e7susi  Accessed via  GBIF  on  2019-07-04 .
    ## Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0  Accessed via  GBIF  on  2019-07-04 .
    ## BARDE Julien N (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd  Accessed via  GBIF  on  2019-07-04 .
    ## BARDE Julien N (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh  Accessed via  GBIF  on  2019-07-04 .
    ## Bentley A (2020). KUBI Ichthyology Collection. Version 17.62. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/mgjasg  Accessed via  GBIF  on  2019-07-04 .
    ## Bentley A (2020). KUBI Ichthyology Tissue Collection. Version 18.50. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/jmsnwg  Accessed via  GBIF  on  2019-07-04 .
    ## Bio-environmental research group; Institute of Agricultural and Fisheries research (ILVO), Belgium; (2015): Epibenthos and demersal fish monitoring at long-term monitoring stations in the Belgian part of the North Sea https://doi.org/10.14284/54  Accessed via  GBIF  on  2019-07-04 .
    ## Bio-environmental research group; Institute of Agricultural and Fisheries research (ILVO), Belgium; (2015): Epibenthos and demersal fish monitoring data in function of wind energy development. https://doi.org/10.14284/53  Accessed via  GBIF  on  2019-07-04 .
    ## Bio-environmental research group; Institute of Agricultural and Fisheries research (ILVO), Belgium; (2015): Zooplankton monitoring in the Belgian Part of the North Sea between 2009 and 2010 https://doi.org/10.14284/55  Accessed via  GBIF  on  2019-07-04 .
    ## Bio-environmental research group; Institute of Agricultural and Fisheries research (ILVO), Belgium; (2016): Epibenthos and demersal fish monitoring in function of aggregate extraction in the Belgian part of the North Sea. https://doi.org/10.14284/197  Accessed via  GBIF  on  2019-07-04 .
    ## Bio-environmental research group; Institute of Agricultural and Fisheries research (ILVO), Belgium; (2016): Epibenthos and demersal fish monitoring in function of dredge disposal monitoring in the Belgian part of the North Sea. https://doi.org/10.14284/198  Accessed via  GBIF  on  2019-07-04 .
    ## Blindheim T (2020). BioFokus. Version 1.1356. BioFokus. Occurrence dataset https://doi.org/10.15468/jxbhqx  Accessed via  GBIF  on  2019-07-04 .
    ## Boon T, Zühlke R (2011). Abundance of benthic infauna in surface sediments from the North Sea sampled during cruise Cirolana00/5. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.756782  Accessed via  GBIF  on  2019-07-04 .
    ## Breine J, Verreycken H, De Boeck T, Brosens D, Desmet P (2016). VIS - Fishes in estuarine waters in Flanders, Belgium. Version 9.4. Research Institute for Nature and Forest (INBO). Occurrence dataset https://doi.org/10.15468/estwpt  Accessed via  GBIF  on  2019-07-04 .
    ## Canadian node of the Ocean Biogeographic Information System (OBIS Canada). Canada Maritimes Regional Cetacean Sightings (OBIS Canada). Occurrence dataset https://doi.org/10.15468/orwtwi  Accessed via  GBIF  on  2019-07-04 .
    ## Casassovici A, Brosens D (2020). Diveboard - Scuba diving citizen science observations. Version 54.24. Diveboard. Occurrence dataset https://doi.org/10.15468/tnjrgy  Accessed via  GBIF  on  2019-07-04 .
    ## Catania D, Fong J (2020). CAS Ichthyology (ICH). Version 150.219. California Academy of Sciences. Occurrence dataset https://doi.org/10.15468/efh2ib  Accessed via  GBIF  on  2019-07-04 .
    ## Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361  Accessed via  GBIF  on  2019-07-04 .
    ## Chiang W (2014). Taiwan Fisheries Research Institute – Digital archives of coastal and offshore specimens. TELDAP. Occurrence dataset https://doi.org/10.15468/xvxngy  Accessed via  GBIF  on  2019-07-04 .
    ## Chic Giménez Ò, Lombarte Carrera A (2018). Colección de referencia de otolitos, Instituto de Ciencias del Mar-CSIC. Institute of Marine Sciences (ICM-CSIC). Occurrence dataset https://doi.org/10.15468/wdwxid  Accessed via  GBIF  on  2019-07-04 .
    ## Citizen Science - ALA Website (2020). ALA species sightings and OzAtlas. Occurrence dataset https://doi.org/10.15468/jayxmn  Accessed via  GBIF  on  2019-07-04 .
    ## Coetzer W (2017). Occurrence records of southern African aquatic biodiversity. Version 1.10. The South African Institute for Aquatic Biodiversity. Occurrence dataset https://doi.org/10.15468/pv7vds  Accessed via  GBIF  on  2019-07-04 .
    ## Commonwealth Scientific and Industrial Research Organisation (2019). CSIRO Ichthyology provider for OZCAM. Occurrence dataset https://doi.org/10.15468/azp1pf  Accessed via  GBIF  on  2019-07-04 .
    ## Craeymeersch J A, Duineveld G C A (2011). Abundance of benthic infauna in surface sediments from the North Sea sampled during cruise Tridens00/5. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.756784  Accessed via  GBIF  on  2019-07-04 .
    ## Creuwels J (2020). Naturalis Biodiversity Center (NL) - Pisces. Naturalis Biodiversity Center. Occurrence dataset https://doi.org/10.15468/evijly  Accessed via  GBIF  on  2019-07-04 .
    ## CSIRO - Arafura Sea shark surveys (Rachel cruises 1984-1985) https://doi.org/10.15468/yickr6  Accessed via  GBIF  on  2019-07-04 .
    ## CSIRO - Soviet Fishery surveys in Australian waters 1965-78 https://doi.org/10.15468/ttcx7v  Accessed via  GBIF  on  2019-07-04 .
    ## de Vries H (2018). Observation.org, Nature data from the Netherlands. Observation.org. Occurrence dataset https://doi.org/10.15468/5nilie  Accessed via  GBIF  on  2019-07-04 .
    ## DFO. (2017).  DFO Maritimes Region Cetacean Sightings. Version 7 In OBIS Canada Digital Collections. Bedford Institute of Oceanography, Dartmouth, NS, Canada. Published by OBIS, Digital http://www.iobis.org/. Accessed on –INSERT DATE https://doi.org/10.15468/2khlz1  Accessed via  GBIF  on  2019-07-04 .
    ## DFO. 2016. DFO Maritimes Research Vessel Trawl Surveys Fish observations. Version 11 In OBIS Canada Digital Collections. Bedford Institute of Oceanography, Dartmouth, NS, Canada. Published by OBIS, Digital http://www.iobis.org/. Accessed on –INSERT DATE https://doi.org/10.15468/hlhopd  Accessed via  GBIF  on  2019-07-04 .
    ## Dillman C (2018). CUMV Fish Collection. Version 28.16. Cornell University Museum of Vertebrates. Occurrence dataset https://doi.org/10.15468/jornbc  Accessed via  GBIF  on  2019-07-04 .
    ## DIMEGLIO Tristan N, VONG Lilita N (2019). Programme national de science participative sur la Biodiversité Littorale (BioLit). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/xmv4ik  Accessed via  GBIF  on  2019-07-04 .
    ## Edgar G J, Stuart-Smith R D (2016). Reef Life Survey: Global reef fish dataset. Version 2.1. Reef Life Survey. Sampling event dataset https://doi.org/10.15468/qjgwba  Accessed via  GBIF  on  2019-07-04 .
    ## Ehrich S, Kröncke I (2011). Abundance of benthic infauna in surface sediments from the North Sea sampled during Walther Herwig cruise WH220. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.756783  Accessed via  GBIF  on  2019-07-04 .
    ## Elías Gutiérrez M, Comisión nacional para el conocimiento y uso de la biodiversidad C (2018). Códigos de barras de la vida en peces y zooplancton de México. Version 1.5. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/xmbkgo  Accessed via  GBIF  on  2019-07-04 .
    ## Environment Agency (2019). Environment Agency Rare and Protected Species Records. Occurrence dataset https://doi.org/10.15468/awfvnp  Accessed via  GBIF  on  2019-07-04 .
    ## European Molecular Biology Laboratory Australia (2019). European Molecular Biology Laboratory Australian Mirror. Occurrence dataset https://doi.org/10.15468/ypsvix  Accessed via  GBIF  on  2019-07-04 .
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv  Accessed via  GBIF  on  2019-07-04 .
    ## Fahy K (2016). SBMNH Vertebrate Zoology. Version 5.1. Santa Barbara Museum of Natural History. Occurrence dataset https://doi.org/10.15468/amfnkq  Accessed via  GBIF  on  2019-07-04 .
    ## Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd  Accessed via  GBIF  on  2019-07-04 .
    ## Flanders Marine Institute (VLIZ); (2013). Data collected during the expeditions of the e-learning projects Expedition Zeeleeuw and Planet Ocean. https://doi.org/10.14284/4  Accessed via  GBIF  on  2019-07-04 .
    ## Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. Occurrence dataset https://doi.org/10.15468/ad1ovc  Accessed via  GBIF  on  2019-07-04 .
    ## Gall L (2020). Vertebrate Zoology Division - Ichthyology, Yale Peabody Museum. Yale University Peabody Museum. Occurrence dataset https://doi.org/10.15468/mgyhok  Accessed via  GBIF  on  2019-07-04 .
    ## González Acosta A F, Comisión nacional para el conocimiento y uso de la biodiversidad C (2018). Ampliación de la base de datos de la ictiofauna insular del Golfo de California. Version 1.5. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/p5ovq7  Accessed via  GBIF  on  2019-07-04 .
    ## Grant S, Swagel K (2019). Field Museum of Natural History (Zoology) Fish Collection. Version 13.11. Field Museum. Occurrence dataset https://doi.org/10.15468/alz7wu  Accessed via  GBIF  on  2019-07-04 .
    ## Hårsaker K, Daverdin M (2020). Fish collection NTNU University Museum. Version 1.381. NTNU University Museum. Occurrence dataset https://doi.org/10.15468/q909ac  Accessed via  GBIF  on  2019-07-04 .
    ## Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.202. Museum of Comparative Zoology, Harvard University. Occurrence dataset https://doi.org/10.15468/p5rupv  Accessed via  GBIF  on  2019-07-04 .
    ## iNaturalist.org (2020). iNaturalist Research-grade Observations. Occurrence dataset https://doi.org/10.15468/ab3s5x  Accessed via  GBIF  on  2019-07-04 .
    ## Joint Nature Conservation Committee (2018). Marine Nature Conservation Review (MNCR) and associated benthic marine data held and managed by JNCC. Occurrence dataset https://doi.org/10.15468/kcx3ca  Accessed via  GBIF  on  2019-07-04 .
    ## Kent & Medway Biological Records Centre (2019). Fish:  Records for Kent.. Occurrence dataset https://doi.org/10.15468/kd1utk  Accessed via  GBIF  on  2019-07-04 .
    ## Khidas K (2018): Canadian Museum of Nature Fish Collection. v1.69. Canadian Museum of Nature. Dataset/Occurrence. http://ipt.nature.ca/resource?r=cmn_fish&v=1.69 https://doi.org/10.15468/bm8amw  Accessed via  GBIF  on  2019-07-04 .
    ## Kiki P, Ganglo J (2017). Census of the threatened species of Benin.. Version 1.5. GBIF Benin. Occurrence dataset https://doi.org/10.15468/fbbbfl  Accessed via  GBIF  on  2019-07-04 .
    ## Laurent Colombet N, COLOMBET Laurent N (2019). Données BioObs - Base pour l’Inventaire des Observations Subaquatiques de la FFESSM. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/ldch7a  Accessed via  GBIF  on  2019-07-04 .
    ## Machete, M.; Institute of Marine Research (IMAR), Portugal; Department of Oceanography and Fisheries, University of the Azores (DOP/UAC), Portugal; (2014): POPA- Fisheries Observer Program of the Azores: Accessory species caught in the Azores tuna fishery between 2000 and 2013. https://doi.org/10.14284/211  Accessed via  GBIF  on  2019-07-04 .
    ## Machete, M.; Institute of Marine Research (IMAR), Portugal; Department of Oceanography and Fisheries, University of the Azores (DOP/UAC), Portugal; (2014): POPA- Fisheries Observer Program of the Azores: Discards in the Azores tuna fishery from 1998 to 2013. https://doi.org/10.14284/20  Accessed via  GBIF  on  2019-07-04 .
    ## Malzahn A M (2006). Larval fish at time series station Helgoland Roads, North Sea, in 2003. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.733539  Accessed via  GBIF  on  2019-07-04 .
    ## Malzahn A M (2006). Larval fish at time series station Helgoland Roads, North Sea, in 2004. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.733540  Accessed via  GBIF  on  2019-07-04 .
    ## Malzahn A M (2006). Larval fish at time series station Helgoland Roads, North Sea, in 2005. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.733541  Accessed via  GBIF  on  2019-07-04 .
    ## Marine Biological Association (2017). DASSH Data Archive Centre volunteer survey data. Occurrence dataset https://doi.org/10.15468/pjowth  Accessed via  GBIF  on  2019-07-04 .
    ## Marine Biological Association (2017). Verified Marine records from Indicia-based surveys. Occurrence dataset https://doi.org/10.15468/yfyeyg  Accessed via  GBIF  on  2019-07-04 .
    ## Menezes, G.; Institute of Marine Research (IMAR - Azores), Portugal; Department of Oceanography and Fisheries, University of the Azores (DOP/UAC), Portugal; (2014): Demersais survey in the Azores between 1996 and 2013. https://doi.org/10.14284/22  Accessed via  GBIF  on  2019-07-04 .
    ## Merseyside BioBank (2018). Merseyside BioBank (unverified). Occurrence dataset https://doi.org/10.15468/iou2ld  Accessed via  GBIF  on  2019-07-04 .
    ## Millen B (2019). Ichthyology Collection - Royal Ontario Museum. Version 18.7. Royal Ontario Museum. Occurrence dataset https://doi.org/10.15468/syisbx  Accessed via  GBIF  on  2019-07-04 .
    ## Ministry for Primary Industries (2014). New Zealand research tagging database. Southwestern Pacific OBIS, National Institute of Water and Atmospheric Research (NIWA), Wellington, New Zealand, 411926 records, Online http://nzobisipt.niwa.co.nz/resource.do?r=mpi_tag released on November 5, 2014. https://doi.org/10.15468/i66xdm  Accessed via  GBIF  on  2019-07-04 .
    ## Ministry for Primary Industries (2014). Soviet Fishery Data (New Zealand Waters) 1964-1987. Southwestern Pacific OBIS, National Institute of Water and Atmospheric Research (NIWA), Wellington, New Zealand, 111883 records, Online http://nzobisipt.niwa.co.nz/resource.do?r=mbis_soviettrawl released on November 5, 2014. https://doi.org/10.15468/yqk5jg  Accessed via  GBIF  on  2019-07-04 .
    ## Miya M (2020). Fish Collection of Natural History Museum and Institute, Chiba. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/p2eb5z  Accessed via  GBIF  on  2019-07-04 .
    ## MNHN - Museum national d'Histoire naturelle (2020). The fishes collection (IC) of the Muséum national d'Histoire naturelle (MNHN - Paris). Version 57.161. Occurrence dataset https://doi.org/10.15468/tm7whu  Accessed via  GBIF  on  2019-07-04 .
    ## Museum and Art Gallery of the Northern Territory (2019). Northern Territory Museum and Art Gallery provider for OZCAM. Occurrence dataset https://doi.org/10.15468/giro3a  Accessed via  GBIF  on  2019-07-04 .
    ## Museums Victoria (2019). Museums Victoria provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lp1ctu  Accessed via  GBIF  on  2019-07-04 .
    ## n/a N (2019). Parc_National_des_Calanques_2017_12_18. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/g0ds6l  Accessed via  GBIF  on  2019-07-04 .
    ## National Biodiversity Data Centre. Marine sites, habitats and species data collected during the BioMar survey of Ireland.. Occurrence dataset https://doi.org/10.15468/cr7gvs  Accessed via  GBIF  on  2019-07-04 .
    ## National Biodiversity Data Centre. Marine sites, habitats and species data collected during the BioMar survey of Ireland.. Occurrence dataset https://doi.org/10.15468/nwlt7a  Accessed via  GBIF  on  2019-07-04 .
    ## National Biodiversity Data Centre. Rare marine fishes taken in Irish waters from 1786 to 2008. Occurrence dataset https://doi.org/10.15468/yvsxdp  Accessed via  GBIF  on  2019-07-04 .
    ## National Institute of Oceanography and Experimental Geophysics (OGS); Italian National Institute for Environmental Protection and Research (ISPRA), Italy; (2017): Trawl survey data from the Jabuka Pit area (central-eastern Adriatic Sea, Mediterranean) collected between 1956 and 1971. https://doi.org/10.14284/287  Accessed via  GBIF  on  2019-07-04 .
    ## National Institute of Oceanography and Experimental Geophysics (OGS); Italian National Institute for Environmental Protection and Research (ISPRA), Italy; (2017): Trawl-survey data from the “expedition Hvar” in the Adriatic Sea (Mediterranean) collected in 1948-1949. https://doi.org/10.14284/285  Accessed via  GBIF  on  2019-07-04 .
    ## National Institute of Oceanography and Experimental Geophysics (OGS); Italian National Institute for Environmental Protection and Research (ISPRA), Italy; (2017): Trawl-survey data in the central-eastern Adriatic Sea (Mediterranean) collected in 1957 and 1958. https://doi.org/10.14284/286  Accessed via  GBIF  on  2019-07-04 .
    ## National Museum of Nature and Science, Japan (2020). Fish specimens of Kagoshima University Museum. Occurrence dataset https://doi.org/10.15468/vcj3j8  Accessed via  GBIF  on  2019-07-04 .
    ## Natural History Museum (2020). Natural History Museum (London) Collection Specimens. Occurrence dataset https://doi.org/10.5519/0002965  Accessed via  GBIF  on  2019-07-04 .
    ## Natural History Museum, University of Oslo (2019). Fish collection, Natural History Museum, University of Oslo. Version 1.179. Occurrence dataset https://doi.org/10.15468/4vqytb  Accessed via  GBIF  on  2019-07-04 .
    ## Natural Resources Wales (2018). Marine Records from Pembrokeshire Marine Species Atlas. Occurrence dataset https://doi.org/10.15468/42yudm  Accessed via  GBIF  on  2019-07-04 .
    ## naturgucker.de. naturgucker. Occurrence dataset https://doi.org/10.15468/uc1apo  Accessed via  GBIF  on  2019-07-04 .
    ## NIWA (2014). New Zealand fish and squid distributions from research bottom trawls. Southwestern Pacific OBIS, National Institute of Water and Atmospheric Research (NIWA), Wellington, New Zealand, 486781 records, Online http://nzobisipt.niwa.co.nz/resource.do?r=obisprovider released on May 8, 2014. https://doi.org/10.15468/ti5yah  Accessed via  GBIF  on  2019-07-04 .
    ## Norén M, Shah M (2017). Fishbase. FishBase. Occurrence Dataset https://doi.org/10.15468/wk3zk7  Accessed via  GBIF  on  2019-07-04 .
    ## Norton B (2019). NCSM Ichthyology Collection. Version 22.4. North Carolina State Museum of Natural Sciences. Occurrence dataset https://doi.org/10.15468/7et8cq  Accessed via  GBIF  on  2019-07-04 .
    ## Olivas González F J (2018). Biological Reference Collections ICM CSIC. Version 1.23. Institute of Marine Sciences (ICM-CSIC). Occurrence dataset https://doi.org/10.15470/qlqqdx  Accessed via  GBIF  on  2019-07-04 .
    ## Orrell T (2020). NMNH Extant Specimen Records. Version 1.30. National Museum of Natural History, Smithsonian Institution. Occurrence dataset https://doi.org/10.15468/hnhrg3  Accessed via  GBIF  on  2019-07-04 .
    ## Pierre NOEL N (2019). Données naturalistes de Pierre NOEL (stage). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/if4ism  Accessed via  GBIF  on  2019-07-04 .
    ## Pinheiro H (2017). Fish biodiversity of the Vitória-Trindade Seamount Chain, Southwestern Atlantic: an updated database. Version 2.11. Brazilian Marine Biodiversity Database. Occurrence dataset https://doi.org/10.15468/o5jdnr  Accessed via  GBIF  on  2019-07-04 .
    ## Pozo de la Tijera M D C, Comisión nacional para el conocimiento y uso de la biodiversidad C (2018). Fortalecimiento de las colecciones de ECOSUR. Primera fase. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/orx3mk  Accessed via  GBIF  on  2019-07-04 .
    ## Prestridge H (2019). Biodiversity Research and Teaching Collections - TCWC Vertebrates. Version 9.3. Texas A&M University Biodiversity Research and Teaching Collections. Occurrence dataset https://doi.org/10.15468/szomia  Accessed via  GBIF  on  2019-07-04 .
    ## Prince P (2011). Abundance of benthic infauna in surface sediments from the North Sea sampled during cruise Dana00/5. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.756781  Accessed via  GBIF  on  2019-07-04 .
    ## Pugh W (2017). UAIC Ichthyological Collection. Version 3.2. University of Alabama Biodiversity and Systematics. Occurrence dataset https://doi.org/10.15468/a2laag  Accessed via  GBIF  on  2019-07-04 .
    ## Pyle R (2016). Bernice P. Bishop Museum. Version 8.1. Bernice Pauahi Bishop Museum. Occurrence dataset https://doi.org/10.15468/s6ctus  Accessed via  GBIF  on  2019-07-04 .
    ## Queensland Museum (2020). Queensland Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lotsye  Accessed via  GBIF  on  2019-07-04 .
    ## Quesada Lara J, Agulló Villaronga J (2019). Museu de Ciències Naturals de Barcelona: MCNB-Cord. Museu de Ciències Naturals de Barcelona. Occurrence dataset https://doi.org/10.15468/yta7zj  Accessed via  GBIF  on  2019-07-04 .
    ## Raiva R, Santana P (2019). Diversidade e ocorrência de peixes em Inhambane (2009-2017). Version 1.4. National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/4fj2tq  Accessed via  GBIF  on  2019-07-04 .
    ## Raiva R, Viador R, Santana P (2019). Diversidade e ocorrência de peixes na Zambézia (2003-2016). National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/mrz36h  Accessed via  GBIF  on  2019-07-04 .
    ## Ranz J (2017). Banco de Datos de la Biodiversidad de la Comunitat Valenciana. Biodiversity data bank of Generalitat Valenciana. Occurrence dataset https://doi.org/10.15468/b4yqdy  Accessed via  GBIF  on  2019-07-04 .
    ## Riutort Jean-Jacques N (2019). Données naturalistes de Jean-Jacques RIUTORT. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/97bvs0  Accessed via  GBIF  on  2019-07-04 .
    ## Robins R (2020). UF FLMNH Ichthyology. Version 117.255. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel  Accessed via  GBIF  on  2019-07-04 .
    ## Sánchez González S, Comisión nacional para el conocimiento y uso de la biodiversidad C (2018). Taxonomía y sistemática de la Ictiofauna de la Bahía de Banderas del Estado de Nayarit, México. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/uhrwsl  Accessed via  GBIF  on  2019-07-04 .
    ## Schiphouwer M (2018). RAVON (NL) - Fish observations extracted from Redeke (1907). Reptile, Amphibian and Fish Conservation Netherlands (RAVON). Occurrence dataset https://doi.org/10.15468/edt24y  Accessed via  GBIF  on  2019-07-04 .
    ## Scottish Natural Heritage (2017). Species data for Scottish waters held and managed by Scottish Natural Heritage,  derived from benthic surveys 1993 to 2014. Occurrence dataset https://doi.org/10.15468/faxvgd  Accessed via  GBIF  on  2019-07-04 .
    ## Seasearch (2019). Seasearch Marine Surveys in England. Occurrence dataset https://doi.org/10.15468/kywx6m  Accessed via  GBIF  on  2019-07-04 .
    ## Senckenberg. Collection Pisces SMF. Occurrence dataset https://doi.org/10.15468/xaofbe  Accessed via  GBIF  on  2019-07-04 .
    ## Shah M, Coulson S (2020). Artportalen (Swedish Species Observation System). Version 92.186. ArtDatabanken. Occurrence dataset https://doi.org/10.15468/kllkyl  Accessed via  GBIF  on  2019-07-04 .
    ## Shah M, Ericson Y (2020). SLU Aqua Institute of Coastal Research Database for Coastal Fish - KUL. GBIF-Sweden. Occurrence dataset https://doi.org/10.15468/bp9w9y  Accessed via  GBIF  on  2019-07-04 .
    ## Shane G (2018). Pelagic fish food web linkages, Queensland, Australia (2003-2005). CSIRO Oceans and Atmosphere. Occurrence dataset https://doi.org/10.15468/yy5wdp  Accessed via  GBIF  on  2019-07-04 .
    ## Shao K, Lin H (2014). The Fish Database of Taiwan. TELDAP. Occurrence dataset https://doi.org/10.15468/zavxg7  Accessed via  GBIF  on  2019-07-04 .
    ## Sidlauskas B (2017). Oregon State Ichthyology Collection. Oregon State University. Occurrence dataset https://doi.org/10.15468/b7htot  Accessed via  GBIF  on  2019-07-04 .
    ## Silva A S (2018). Ichthyological Collection of the Museu Oceanográfico D. Carlos I. Version 1.7. Aquário Vasco da Gama. Occurrence dataset https://doi.org/10.15468/dkxpqt  Accessed via  GBIF  on  2019-07-04 .
    ## South Australian Museum (2020). South Australian Museum Australia provider for OZCAM. Occurrence dataset https://doi.org/10.15468/wz4rrh  Accessed via  GBIF  on  2019-07-04 .
    ## South East Wales Biodiversity Records Centre (2018). SEWBReC Fish (South East Wales). Occurrence dataset https://doi.org/10.15468/htsfiy  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/06aqle  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/1pyhh5  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/419say  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/6chrsz  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/7dnpl0  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/7zofww  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/adis7b  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/dfyb57  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/dple14  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/es1iso  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/g8q8ey  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/jlkkrw  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/kfnaep  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/nawlft  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/nuqkih  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/rexjmu  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/t0r3vt  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/uzpt9m  Accessed via  GBIF  on  2019-07-04 .
    ## South Florida Reef Visual Census; http://www.sefsc.noaa.gov/rvc_analysis20/samples/index https://doi.org/10.15468/zq1ep2  Accessed via  GBIF  on  2019-07-04 .
    ## Staatliche Naturwissenschaftliche Sammlungen Bayerns. The Fish Collection at the Zoologische Staatssammlung München. Occurrence dataset https://doi.org/10.15468/fzn9sv  Accessed via  GBIF  on  2019-07-04 .
    ## Staatliche Naturwissenschaftliche Sammlungen Bayerns. The Pisces Collection at the Staatssammlung für Anthropologie und Paläoanatomie München. Occurrence dataset https://doi.org/10.15468/uxag7k  Accessed via  GBIF  on  2019-07-04 .
    ## SWPRON (2014). Marine biological observation data from coastal and offshore surveys around New Zealand. Southwestern Pacific OBIS, National Institute of Water and Atmospheric Research (NIWA), Wellington, New Zealand, 9092 records, Online http://nzobisipt.niwa.co.nz/resource.do?r=mbis_nz released on January 16, 2018. https://doi.org/10.15468/pzpgop  Accessed via  GBIF  on  2019-07-04 .
    ## Telenius A, Ekström J (2020). Lund Museum of Zoology (MZLU). GBIF-Sweden. Occurrence dataset https://doi.org/10.15468/mw39rb  Accessed via  GBIF  on  2019-07-04 .
    ## The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6  Accessed via  GBIF  on  2019-07-04 .
    ## The Norwegian Biodiversity Information Centre ., Hoem S (2020). Norwegian Species Observation Service. Version 1.82. The Norwegian Biodiversity Information Centre (NBIC). Occurrence dataset https://doi.org/10.15468/zjbzel  Accessed via  GBIF  on  2019-07-04 .
    ## The Wildlife Trusts (2018). Marine Data from The Wildlife Trusts (TWT) Dive Team; 2014-2018. Occurrence dataset https://doi.org/10.15468/aqr7zv  Accessed via  GBIF  on  2019-07-04 .
    ## Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/vjeh1p  Accessed via  GBIF  on  2019-07-04 .
    ## UMS PatriNat (OFB-CNRS-MNHN), Paris (2018). Données d'occurrences Espèces issues de l'inventaire des ZNIEFF. Occurrence dataset https://doi.org/10.15468/ikshke  Accessed via  GBIF  on  2019-07-04 .
    ## University of Michigan Museum of Zoology (2020). University of Michigan Museum of Zoology, Division of Fishes. Version 1.22. Occurrence dataset https://doi.org/10.15468/8cxijb  Accessed via  GBIF  on  2019-07-04 .
    ## University of Washington Ichthyology Collection (UWFC) https://doi.org/10.15468/vvp7gr  Accessed via  GBIF  on  2019-07-04 .
    ## van der Es H (2020). Natural History Museum Rotterdam (NL) - Chordata collection. Version 13.21. Natural History Museum Rotterdam. Occurrence dataset https://doi.org/10.15468/5rtmkg  Accessed via  GBIF  on  2019-07-04 .
    ## Van der Veer H W, De Bruin T (2019). Royal Netherlands Institute for Sea Research (NIOZ) - Kom Fyke Mokbaai. Version 3.2. NIOZ Royal Netherlands Institute for Sea Research. Occurrence dataset https://doi.org/10.15468/ztbuho  Accessed via  GBIF  on  2019-07-04 .
    ## Van Guelpen, L., 2016. Atlantic Reference Centre Museum of Canadian Atlantic Organisms - Invertebrates and Fishes Data. Version 4 In OBIS Canada Digital Collections. Bedford Institute of Oceanography, Dartmouth, NS, Canada. Published by OBIS, Digital http://www.iobis.org/. Accessed on –INSERT DATE https://doi.org/10.15468/wsxvo6  Accessed via  GBIF  on  2019-07-04 .
    ## Vanreusel W, Gielen K, Van den Neucker T, Jooris R, Desmet P (2019). Waarnemingen.be - Fish occurrences in Flanders and the Brussels Capital Region, Belgium. Version 1.6. Natuurpunt. Occurrence dataset https://doi.org/10.15468/7reil0  Accessed via  GBIF  on  2019-07-04 .
    ## Western Australian Museum (2019). Western Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/5qt0dm  Accessed via  GBIF  on  2019-07-04 .
    ## Wimer M, Benson A (2016). USGS Patuxent Wildlife Research Center Seabirds Compendium. Version 1.1. United States Geological Survey. Occurrence dataset https://doi.org/10.15468/w2vk7x  Accessed via  GBIF  on  2019-07-04 .

------------------------------------------------------------------------

Visualization features
======================

Search result summary figures
-----------------------------

occCite includes a function called `sumFig.occCite()` which is capable
of generating three types of plots from an `occCiteData` object. First,
let’s see how the results of our multispecies query looks.

``` r
par(mfrow = c(1,3))
sumFig.occCite(myPhyOccCiteObject, 
               bySpecies = F, 
               plotTypes = c("yearHistogram", "source", "aggregator"))
```

    ## $yearHistogram
    ## $data
    ## $data[[1]]
    ##        y count      x    xmin    xmax      density       ncount     ndensity
    ## 1     14    14 1690.7 1674.75 1706.65 1.191711e-05 5.303030e-04 5.303030e-04
    ## 2      0     0 1722.6 1706.65 1738.55 0.000000e+00 0.000000e+00 0.000000e+00
    ## 3      0     0 1754.5 1738.55 1770.45 0.000000e+00 0.000000e+00 0.000000e+00
    ## 4      1     1 1786.4 1770.45 1802.35 8.512223e-07 3.787879e-05 3.787879e-05
    ## 5      1     1 1818.3 1802.35 1834.25 8.512223e-07 3.787879e-05 3.787879e-05
    ## 6      3     3 1850.2 1834.25 1866.15 2.553667e-06 1.136364e-04 1.136364e-04
    ## 7     12    12 1882.1 1866.15 1898.05 1.021467e-05 4.545455e-04 4.545455e-04
    ## 8    383   383 1914.0 1898.05 1929.95 3.260181e-04 1.450758e-02 1.450758e-02
    ## 9   1239  1239 1945.9 1929.95 1961.85 1.054664e-03 4.693182e-02 4.693182e-02
    ## 10  8774  8774 1977.8 1961.85 1993.75 7.468624e-03 3.323485e-01 3.323485e-01
    ## 11 26400 26400 2009.7 1993.75 2025.65 2.247227e-02 1.000000e+00 1.000000e+00
    ##    flipped_aes PANEL group ymin  ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0    14  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0     0  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0     0  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0     1  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0     1  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0     3  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0    12  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0   383  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0  1239  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0  8774  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0 26400  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20overall-1.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #48186AFF  5  2     1     2  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #48186AFF  5  3     1     2  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #48186AFF  5  4     1     2  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #48186AFF  5  5     1     2  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #48186AFF  5  6     1     2  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #48186AFF  5  7     1     2  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #48186AFF  5  8     1     2  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #48186AFF  5  9     1     2  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #48186AFF  5 10     1     2  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #48186AFF  6  1     1     2  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #48186AFF  6  2     1     2  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #48186AFF  6  3     1     2  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #48186AFF  6  4     1     2  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #48186AFF  6  5     1     2  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #48186AFF  6  6     1     2  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #48186AFF  6  7     1     2  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #48186AFF  6  8     1     2  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #48186AFF  6  9     1     2  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #472D7BFF  6 10     1     3  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #472D7BFF  7  1     1     3  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #472D7BFF  7  2     1     3  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #424086FF  7  3     1     4  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #424086FF  7  4     1     4  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #3B528BFF  7  5     1     5  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #3B528BFF  7  6     1     5  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #33638DFF  7  7     1     6  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #33638DFF  7  8     1     6  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #2C728EFF  7  9     1     7  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #2C728EFF  7 10     1     7  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #26828EFF  8  1     1     8  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #26828EFF  8  2     1     8  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #21908CFF  8  3     1     9  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #21908CFF  8  4     1     9  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #1F9F88FF  8  5     1    10  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #1F9F88FF  8  6     1    10  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #27AD81FF  8  7     1    11  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #27AD81FF  8  8     1    11  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #3EBC74FF  8  9     1    12  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #3EBC74FF  8 10     1    12  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #5DC863FF  9  1     1    13  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #5DC863FF  9  2     1    13  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #82D34DFF  9  3     1    14  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #82D34DFF  9  4     1    14  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #AADC32FF  9  5     1    15  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #AADC32FF  9  6     1    15  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #D5E21AFF  9  7     1    16  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #D5E21AFF  9  8     1    16  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #FDE725FF  9  9     1    17  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #FDE725FF  9 10     1    17  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #FDE725FF 10  1     1    17  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #FDE725FF 10  2     1    17  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #FDE725FF 10  3     1    17  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #FDE725FF 10  4     1    17  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #FDE725FF 10  5     1    17  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #FDE725FF 10  6     1    17  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #FDE725FF 10  7     1    17  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #FDE725FF 10  8     1    17  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1    17  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1    17  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20overall-2.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20overall-3.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"

We can also generate plots for each species in the `occCiteData` object
individually.

``` r
par(mfrow = c(2,3))
sumFig.occCite(myPhyOccCiteObject, 
               bySpecies = T, 
               plotTypes = c("yearHistogram", "source", "aggregator"))
```

    ## $`Istiompax indica`
    ## $`Istiompax indica`$yearHistogram
    ## $data
    ## $data[[1]]
    ##      y count      x   xmin   xmax      density      ncount    ndensity
    ## 1    1     1 1876.8 1869.9 1883.7 0.0001548371 0.007462687 0.007462687
    ## 2    0     0 1890.6 1883.7 1897.5 0.0000000000 0.000000000 0.000000000
    ## 3    0     0 1904.4 1897.5 1911.3 0.0000000000 0.000000000 0.000000000
    ## 4    2     2 1918.2 1911.3 1925.1 0.0003096742 0.014925373 0.014925373
    ## 5    0     0 1932.0 1925.1 1938.9 0.0000000000 0.000000000 0.000000000
    ## 6    1     1 1945.8 1938.9 1952.7 0.0001548371 0.007462687 0.007462687
    ## 7   17    17 1959.6 1952.7 1966.5 0.0026322309 0.126865672 0.126865672
    ## 8  134   134 1973.4 1966.5 1980.3 0.0207481729 1.000000000 1.000000000
    ## 9   71    71 1987.2 1980.3 1994.1 0.0109934349 0.529850746 0.529850746
    ## 10 108   108 2001.0 1994.1 2007.9 0.0167224080 0.805970149 0.805970149
    ## 11 134   134 2014.8 2007.9 2021.7 0.0207481729 1.000000000 1.000000000
    ##    flipped_aes PANEL group ymin ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0    2  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0   17  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0  134  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0   71  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0  108  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0  134  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-1.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Istiompax indica`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #31688EFF  9  7     1     2  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #31688EFF  9  8     1     2  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #31688EFF  9  9     1     2  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #31688EFF  9 10     1     2  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #31688EFF 10  1     1     2  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #31688EFF 10  2     1     2  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #31688EFF 10  3     1     2  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #31688EFF 10  4     1     2  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #35B779FF 10  5     1     3  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #35B779FF 10  6     1     3  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #35B779FF 10  7     1     3  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #FDE725FF 10  8     1     4  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1     4  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     4  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-2.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Istiompax indica`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-3.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Istiophorus albicans`
    ## $`Istiophorus albicans`$yearHistogram
    ## $data
    ## $data[[1]]
    ##      y count      x   xmin   xmax      density      ncount    ndensity
    ## 1    1     1 1685.4 1669.5 1701.3 4.349452e-05 0.001430615 0.001430615
    ## 2    0     0 1717.2 1701.3 1733.1 0.000000e+00 0.000000000 0.000000000
    ## 3    0     0 1749.0 1733.1 1764.9 0.000000e+00 0.000000000 0.000000000
    ## 4    0     0 1780.8 1764.9 1796.7 0.000000e+00 0.000000000 0.000000000
    ## 5    0     0 1812.6 1796.7 1828.5 0.000000e+00 0.000000000 0.000000000
    ## 6    1     1 1844.4 1828.5 1860.3 4.349452e-05 0.001430615 0.001430615
    ## 7    0     0 1876.2 1860.3 1892.1 0.000000e+00 0.000000000 0.000000000
    ## 8    0     0 1908.0 1892.1 1923.9 0.000000e+00 0.000000000 0.000000000
    ## 9    2     2 1939.8 1923.9 1955.7 8.698905e-05 0.002861230 0.002861230
    ## 10  20    20 1971.6 1955.7 1987.5 8.698905e-04 0.028612303 0.028612303
    ## 11 699   699 2003.4 1987.5 2019.3 3.040267e-02 1.000000000 1.000000000
    ##    flipped_aes PANEL group ymin ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0    2  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0   20  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0  699  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-4.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Istiophorus albicans`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     2  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-5.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Istiophorus albicans`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-6.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Istiophorus platypterus`
    ## $`Istiophorus platypterus`$yearHistogram
    ## $data
    ## $data[[1]]
    ##        y count      x    xmin    xmax      density       ncount     ndensity
    ## 1      1     1 1888.6 1881.95 1895.25 4.593595e-06 8.917425e-05 8.917425e-05
    ## 2      0     0 1901.9 1895.25 1908.55 0.000000e+00 0.000000e+00 0.000000e+00
    ## 3      0     0 1915.2 1908.55 1921.85 0.000000e+00 0.000000e+00 0.000000e+00
    ## 4      1     1 1928.5 1921.85 1935.15 4.593595e-06 8.917425e-05 8.917425e-05
    ## 5      4     4 1941.8 1935.15 1948.45 1.837438e-05 3.566970e-04 3.566970e-04
    ## 6     32    32 1955.1 1948.45 1961.75 1.469951e-04 2.853576e-03 2.853576e-03
    ## 7    479   479 1968.4 1961.75 1975.05 2.200332e-03 4.271446e-02 4.271446e-02
    ## 8   1025  1025 1981.7 1975.05 1988.35 4.708435e-03 9.140360e-02 9.140360e-02
    ## 9   3597  3597 1995.0 1988.35 2001.65 1.652316e-02 3.207598e-01 3.207598e-01
    ## 10 11214 11214 2008.3 2001.65 2014.95 5.151258e-02 1.000000e+00 1.000000e+00
    ## 11    15    15 2021.6 2014.95 2028.25 6.890393e-05 1.337614e-03 1.337614e-03
    ##    flipped_aes PANEL group ymin  ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0     1  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0     0  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0     0  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0     1  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0     4  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0    32  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0   479  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0  1025  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0  3597  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0 11214  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0    15  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-7.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Istiophorus platypterus`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #471164FF  2  1     1     2  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #471164FF  2  2     1     2  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #471164FF  2  3     1     2  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #471164FF  2  4     1     2  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #471164FF  2  5     1     2  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #471164FF  2  6     1     2  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #481F70FF  2  7     1     3  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #481F70FF  2  8     1     3  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #481F70FF  2  9     1     3  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #481F70FF  2 10     1     3  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #481F70FF  3  1     1     3  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #472D7BFF  3  2     1     4  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #472D7BFF  3  3     1     4  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #472D7BFF  3  4     1     4  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #472D7BFF  3  5     1     4  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #472D7BFF  3  6     1     4  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #443A83FF  3  7     1     5  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #443A83FF  3  8     1     5  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #443A83FF  3  9     1     5  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #443A83FF  3 10     1     5  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #443A83FF  4  1     1     5  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #404688FF  4  2     1     6  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #404688FF  4  3     1     6  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #404688FF  4  4     1     6  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #404688FF  4  5     1     6  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #404688FF  4  6     1     6  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #3B528BFF  4  7     1     7  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #3B528BFF  4  8     1     7  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #3B528BFF  4  9     1     7  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #3B528BFF  4 10     1     7  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #3B528BFF  5  1     1     7  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #365D8DFF  5  2     1     8  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #365D8DFF  5  3     1     8  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #365D8DFF  5  4     1     8  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #365D8DFF  5  5     1     8  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #31688EFF  5  6     1     9  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #31688EFF  5  7     1     9  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #31688EFF  5  8     1     9  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #31688EFF  5  9     1     9  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #2C728EFF  5 10     1    10  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #2C728EFF  6  1     1    10  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #2C728EFF  6  2     1    10  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #2C728EFF  6  3     1    10  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #287C8EFF  6  4     1    11  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #287C8EFF  6  5     1    11  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #287C8EFF  6  6     1    11  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #287C8EFF  6  7     1    11  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #24868EFF  6  8     1    12  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #24868EFF  6  9     1    12  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #24868EFF  6 10     1    12  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #24868EFF  7  1     1    12  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #21908CFF  7  2     1    13  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #21908CFF  7  3     1    13  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #21908CFF  7  4     1    13  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #21908CFF  7  5     1    13  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #1F9A8AFF  7  6     1    14  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #1F9A8AFF  7  7     1    14  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #1F9A8AFF  7  8     1    14  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #1F9A8AFF  7  9     1    14  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #20A486FF  7 10     1    15  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #20A486FF  8  1     1    15  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #20A486FF  8  2     1    15  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #20A486FF  8  3     1    15  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #27AD81FF  8  4     1    16  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #27AD81FF  8  5     1    16  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #27AD81FF  8  6     1    16  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #35B779FF  8  7     1    17  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #35B779FF  8  8     1    17  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #35B779FF  8  9     1    17  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #47C16EFF  8 10     1    18  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #47C16EFF  9  1     1    18  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #47C16EFF  9  2     1    18  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #5DC863FF  9  3     1    19  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #5DC863FF  9  4     1    19  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #5DC863FF  9  5     1    19  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #75D054FF  9  6     1    20  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #75D054FF  9  7     1    20  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #75D054FF  9  8     1    20  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #8FD744FF  9  9     1    21  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #8FD744FF  9 10     1    21  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #8FD744FF 10  1     1    21  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #AADC32FF 10  2     1    22  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #AADC32FF 10  3     1    22  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #C7E020FF 10  4     1    23  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #C7E020FF 10  5     1    23  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #E3E418FF 10  6     1    24  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #E3E418FF 10  7     1    24  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #FDE725FF 10  8     1    25  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1    25  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1    25  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-8.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Istiophorus platypterus`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-9.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Kajikia albida`
    ## $`Kajikia albida`$yearHistogram
    ## $data
    ## $data[[1]]
    ##     y count      x    xmin    xmax     density     ncount   ndensity
    ## 1  11    11 1958.8 1955.85 1961.75 0.011164112 0.13580247 0.13580247
    ## 2   2     2 1964.7 1961.75 1967.65 0.002029839 0.02469136 0.02469136
    ## 3   0     0 1970.6 1967.65 1973.55 0.000000000 0.00000000 0.00000000
    ## 4   0     0 1976.5 1973.55 1979.45 0.000000000 0.00000000 0.00000000
    ## 5   0     0 1982.4 1979.45 1985.35 0.000000000 0.00000000 0.00000000
    ## 6   9     9 1988.3 1985.35 1991.25 0.009134274 0.11111111 0.11111111
    ## 7   5     5 1994.2 1991.25 1997.15 0.005074597 0.06172840 0.06172840
    ## 8  28    28 2000.1 1997.15 2003.05 0.028417741 0.34567901 0.34567901
    ## 9  81    81 2006.0 2003.05 2008.95 0.082208464 1.00000000 1.00000000
    ## 10 28    28 2011.9 2008.95 2014.85 0.028417741 0.34567901 0.34567901
    ## 11  3     3 2017.8 2014.85 2020.75 0.003044758 0.03703704 0.03703704
    ##    flipped_aes PANEL group ymin ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0   11  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0    2  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0    9  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0    5  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0   28  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0   81  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0   28  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0    3  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-10.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Kajikia albida`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #414487FF  8  7     1     2  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #414487FF  8  8     1     2  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #414487FF  8  9     1     2  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #414487FF  8 10     1     2  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #414487FF  9  1     1     2  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #414487FF  9  2     1     2  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #414487FF  9  3     1     2  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #414487FF  9  4     1     2  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #414487FF  9  5     1     2  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #414487FF  9  6     1     2  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #414487FF  9  7     1     2  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #2A788EFF  9  8     1     3  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #2A788EFF  9  9     1     3  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #2A788EFF  9 10     1     3  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #2A788EFF 10  1     1     3  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #2A788EFF 10  2     1     3  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #22A884FF 10  3     1     4  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #22A884FF 10  4     1     4  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #22A884FF 10  5     1     4  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #22A884FF 10  6     1     4  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #7AD151FF 10  7     1     5  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #7AD151FF 10  8     1     5  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1     6  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     6  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-11.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Kajikia albida`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-12.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Kajikia audax`
    ## $`Kajikia audax`$yearHistogram
    ## $data
    ## $data[[1]]
    ##       y count      x   xmin   xmax      density       ncount     ndensity
    ## 1     1     1 1927.0 1922.3 1931.7 1.582844e-05 0.0002861230 0.0002861230
    ## 2     2     2 1936.4 1931.7 1941.1 3.165689e-05 0.0005722461 0.0005722461
    ## 3     1     1 1945.8 1941.1 1950.5 1.582844e-05 0.0002861230 0.0002861230
    ## 4     9     9 1955.2 1950.5 1959.9 1.424560e-04 0.0025751073 0.0025751073
    ## 5    78    78 1964.6 1959.9 1969.3 1.234619e-03 0.0223175966 0.0223175966
    ## 6   179   179 1974.0 1969.3 1978.7 2.833292e-03 0.0512160229 0.0512160229
    ## 7   226   226 1983.4 1978.7 1988.1 3.577229e-03 0.0646638054 0.0646638054
    ## 8  1290  1290 1992.8 1988.1 1997.5 2.041869e-02 0.3690987124 0.3690987124
    ## 9  1437  1437 2002.2 1997.5 2006.9 2.274548e-02 0.4111587983 0.4111587983
    ## 10 3495  3495 2011.6 2006.9 2016.3 5.532042e-02 1.0000000000 1.0000000000
    ## 11    3     3 2021.0 2016.3 2025.7 4.748533e-05 0.0008583691 0.0008583691
    ##    flipped_aes PANEL group ymin ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0    2  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0    9  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0   78  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0  179  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0  226  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0 1290  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0 1437  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0 3495  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0    3  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-13.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Kajikia audax`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #FDE725FF 10  2     1     2  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #FDE725FF 10  3     1     2  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #FDE725FF 10  4     1     2  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #FDE725FF 10  5     1     2  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #FDE725FF 10  6     1     2  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #FDE725FF 10  7     1     2  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #FDE725FF 10  8     1     2  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1     2  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     2  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-14.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Kajikia audax`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-15.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Makaira nigricans`
    ## $`Makaira nigricans`$yearHistogram
    ## $data
    ## $data[[1]]
    ##      y count      x    xmin    xmax      density      ncount    ndensity
    ## 1    1     1 1935.5 1931.55 1939.45 0.0003148813 0.005494505 0.005494505
    ## 2    0     0 1943.4 1939.45 1947.35 0.0000000000 0.000000000 0.000000000
    ## 3    2     2 1951.3 1947.35 1955.25 0.0006297626 0.010989011 0.010989011
    ## 4    9     9 1959.2 1955.25 1963.15 0.0028339316 0.049450549 0.049450549
    ## 5    4     4 1967.1 1963.15 1971.05 0.0012595252 0.021978022 0.021978022
    ## 6    3     3 1975.0 1971.05 1978.95 0.0009446439 0.016483516 0.016483516
    ## 7   43    43 1982.9 1978.95 1986.85 0.0135398955 0.236263736 0.236263736
    ## 8   37    37 1990.8 1986.85 1994.75 0.0116506077 0.203296703 0.203296703
    ## 9   23    23 1998.7 1994.75 2002.65 0.0072422697 0.126373626 0.126373626
    ## 10  98    98 2006.6 2002.65 2010.55 0.0308583664 0.538461538 0.538461538
    ## 11 182   182 2014.5 2010.55 2018.45 0.0573083947 1.000000000 1.000000000
    ##    flipped_aes PANEL group ymin ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0    2  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0    9  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0    4  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0    3  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0   43  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0   37  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0   23  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0   98  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0  182  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-16.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Makaira nigricans`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #FDE725FF 10  6     1     2  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #FDE725FF 10  7     1     2  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #FDE725FF 10  8     1     2  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1     2  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     2  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-17.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Makaira nigricans`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-18.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Tetrapturus angustirostris`
    ## $`Tetrapturus angustirostris`$yearHistogram
    ## $data
    ## $data[[1]]
    ##     y count    x xmin xmax      density     ncount   ndensity flipped_aes PANEL
    ## 1   3     3 1956 1953 1959 0.0028735632 0.05660377 0.05660377       FALSE     1
    ## 2   1     1 1962 1959 1965 0.0009578544 0.01886792 0.01886792       FALSE     1
    ## 3   2     2 1968 1965 1971 0.0019157088 0.03773585 0.03773585       FALSE     1
    ## 4  12    12 1974 1971 1977 0.0114942529 0.22641509 0.22641509       FALSE     1
    ## 5  22    22 1980 1977 1983 0.0210727969 0.41509434 0.41509434       FALSE     1
    ## 6  15    15 1986 1983 1989 0.0143678161 0.28301887 0.28301887       FALSE     1
    ## 7   1     1 1992 1989 1995 0.0009578544 0.01886792 0.01886792       FALSE     1
    ## 8  16    16 1998 1995 2001 0.0153256705 0.30188679 0.30188679       FALSE     1
    ## 9  45    45 2004 2001 2007 0.0431034483 0.84905660 0.84905660       FALSE     1
    ## 10 53    53 2010 2007 2013 0.0507662835 1.00000000 1.00000000       FALSE     1
    ## 11  4     4 2016 2013 2019 0.0038314176 0.07547170 0.07547170       FALSE     1
    ##    group ymin ymax colour  fill size linetype alpha
    ## 1     -1    0    3  white black  0.5        1   0.9
    ## 2     -1    0    1  white black  0.5        1   0.9
    ## 3     -1    0    2  white black  0.5        1   0.9
    ## 4     -1    0   12  white black  0.5        1   0.9
    ## 5     -1    0   22  white black  0.5        1   0.9
    ## 6     -1    0   15  white black  0.5        1   0.9
    ## 7     -1    0    1  white black  0.5        1   0.9
    ## 8     -1    0   16  white black  0.5        1   0.9
    ## 9     -1    0   45  white black  0.5        1   0.9
    ## 10    -1    0   53  white black  0.5        1   0.9
    ## 11    -1    0    4  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-19.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Tetrapturus angustirostris`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #31688EFF  5 10     1     2  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #31688EFF  6  1     1     2  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #31688EFF  6  2     1     2  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #31688EFF  6  3     1     2  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #31688EFF  6  4     1     2  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #31688EFF  6  5     1     2  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #31688EFF  6  6     1     2  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #31688EFF  6  7     1     2  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #31688EFF  6  8     1     2  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #31688EFF  6  9     1     2  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #31688EFF  6 10     1     2  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #31688EFF  7  1     1     2  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #31688EFF  7  2     1     2  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #31688EFF  7  3     1     2  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #31688EFF  7  4     1     2  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #31688EFF  7  5     1     2  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #31688EFF  7  6     1     2  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #31688EFF  7  7     1     2  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #31688EFF  7  8     1     2  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #31688EFF  7  9     1     2  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #31688EFF  7 10     1     2  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #31688EFF  8  1     1     2  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #31688EFF  8  2     1     2  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #31688EFF  8  3     1     2  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #31688EFF  8  4     1     2  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #31688EFF  8  5     1     2  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #31688EFF  8  6     1     2  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #31688EFF  8  7     1     2  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #31688EFF  8  8     1     2  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #31688EFF  8  9     1     2  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #31688EFF  8 10     1     2  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #31688EFF  9  1     1     2  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #31688EFF  9  2     1     2  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #31688EFF  9  3     1     2  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #31688EFF  9  4     1     2  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #31688EFF  9  5     1     2  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #31688EFF  9  6     1     2  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #31688EFF  9  7     1     2  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #31688EFF  9  8     1     2  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #31688EFF  9  9     1     2  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #31688EFF  9 10     1     2  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #31688EFF 10  1     1     2  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #31688EFF 10  2     1     2  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #31688EFF 10  3     1     2  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #35B779FF 10  4     1     3  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #35B779FF 10  5     1     3  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #35B779FF 10  6     1     3  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #FDE725FF 10  7     1     4  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #FDE725FF 10  8     1     4  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1     4  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     4  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-20.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Tetrapturus angustirostris`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-21.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Tetrapturus belone`
    ## $`Tetrapturus belone`$yearHistogram
    ## $data
    ## $data[[1]]
    ##    y count      x   xmin   xmax    density ncount ndensity flipped_aes PANEL
    ## 1  5     5 1960.0 1957.2 1962.8 0.09920635    1.0      1.0       FALSE     1
    ## 2  1     1 1965.6 1962.8 1968.4 0.01984127    0.2      0.2       FALSE     1
    ## 3  0     0 1971.2 1968.4 1974.0 0.00000000    0.0      0.0       FALSE     1
    ## 4  0     0 1976.8 1974.0 1979.6 0.00000000    0.0      0.0       FALSE     1
    ## 5  0     0 1982.4 1979.6 1985.2 0.00000000    0.0      0.0       FALSE     1
    ## 6  0     0 1988.0 1985.2 1990.8 0.00000000    0.0      0.0       FALSE     1
    ## 7  0     0 1993.6 1990.8 1996.4 0.00000000    0.0      0.0       FALSE     1
    ## 8  1     1 1999.2 1996.4 2002.0 0.01984127    0.2      0.2       FALSE     1
    ## 9  1     1 2004.8 2002.0 2007.6 0.01984127    0.2      0.2       FALSE     1
    ## 10 0     0 2010.4 2007.6 2013.2 0.00000000    0.0      0.0       FALSE     1
    ## 11 1     1 2016.0 2013.2 2018.8 0.01984127    0.2      0.2       FALSE     1
    ##    group ymin ymax colour  fill size linetype alpha
    ## 1     -1    0    5  white black  0.5        1   0.9
    ## 2     -1    0    1  white black  0.5        1   0.9
    ## 3     -1    0    0  white black  0.5        1   0.9
    ## 4     -1    0    0  white black  0.5        1   0.9
    ## 5     -1    0    0  white black  0.5        1   0.9
    ## 6     -1    0    0  white black  0.5        1   0.9
    ## 7     -1    0    0  white black  0.5        1   0.9
    ## 8     -1    0    1  white black  0.5        1   0.9
    ## 9     -1    0    1  white black  0.5        1   0.9
    ## 10    -1    0    0  white black  0.5        1   0.9
    ## 11    -1    0    1  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-22.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Tetrapturus belone`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #21908CFF  8  9     1     2  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #21908CFF  8 10     1     2  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #21908CFF  9  1     1     2  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #21908CFF  9  2     1     2  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #21908CFF  9  3     1     2  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #21908CFF  9  4     1     2  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #21908CFF  9  5     1     2  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #21908CFF  9  6     1     2  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #21908CFF  9  7     1     2  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #21908CFF  9  8     1     2  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #21908CFF  9  9     1     2  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #FDE725FF  9 10     1     3  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #FDE725FF 10  1     1     3  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #FDE725FF 10  2     1     3  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #FDE725FF 10  3     1     3  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #FDE725FF 10  4     1     3  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #FDE725FF 10  5     1     3  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #FDE725FF 10  6     1     3  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #FDE725FF 10  7     1     3  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #FDE725FF 10  8     1     3  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1     3  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     3  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-23.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Tetrapturus belone`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-24.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Tetrapturus georgii`
    ## $`Tetrapturus georgii`$yearHistogram
    ## $data
    ## $data[[1]]
    ##     y count      x    xmin    xmax     density     ncount   ndensity
    ## 1   1     1 1959.9 1957.55 1962.25 0.003431709 0.01639344 0.01639344
    ## 2   0     0 1964.6 1962.25 1966.95 0.000000000 0.00000000 0.00000000
    ## 3   0     0 1969.3 1966.95 1971.65 0.000000000 0.00000000 0.00000000
    ## 4   0     0 1974.0 1971.65 1976.35 0.000000000 0.00000000 0.00000000
    ## 5   0     0 1978.7 1976.35 1981.05 0.000000000 0.00000000 0.00000000
    ## 6   0     0 1983.4 1981.05 1985.75 0.000000000 0.00000000 0.00000000
    ## 7   0     0 1988.1 1985.75 1990.45 0.000000000 0.00000000 0.00000000
    ## 8   0     0 1992.8 1990.45 1995.15 0.000000000 0.00000000 0.00000000
    ## 9   0     0 1997.5 1995.15 1999.85 0.000000000 0.00000000 0.00000000
    ## 10  0     0 2002.2 1999.85 2004.55 0.000000000 0.00000000 0.00000000
    ## 11 61    61 2006.9 2004.55 2009.25 0.209334248 1.00000000 1.00000000
    ##    flipped_aes PANEL group ymin ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0   61  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-25.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Tetrapturus georgii`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #21908CFF 10  8     1     2  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #21908CFF 10  9     1     2  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     3  9.5 10.5  9.5 10.5  white    2        1    NA
    ## 101 #FDE725FF 11  1     1     3 10.5 11.5  0.5  1.5  white    2        1    NA
    ## 102 #00000000 11  2     1     4 10.5 11.5  1.5  2.5  white    2        1    NA
    ## 103 #00000000 11  3     1     4 10.5 11.5  2.5  3.5  white    2        1    NA
    ## 104 #00000000 11  4     1     4 10.5 11.5  3.5  4.5  white    2        1    NA
    ## 105 #00000000 11  5     1     4 10.5 11.5  4.5  5.5  white    2        1    NA
    ## 106 #00000000 11  6     1     4 10.5 11.5  5.5  6.5  white    2        1    NA
    ## 107 #00000000 11  7     1     4 10.5 11.5  6.5  7.5  white    2        1    NA
    ## 108 #00000000 11  8     1     4 10.5 11.5  7.5  8.5  white    2        1    NA
    ## 109 #00000000 11  9     1     4 10.5 11.5  8.5  9.5  white    2        1    NA
    ## 110 #00000000 11 10     1     4 10.5 11.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 101    NA     NA
    ## 102    NA     NA
    ## 103    NA     NA
    ## 104    NA     NA
    ## 105    NA     NA
    ## 106    NA     NA
    ## 107    NA     NA
    ## 108    NA     NA
    ## 109    NA     NA
    ## 110    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-26.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Tetrapturus georgii`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-27.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Tetrapturus pfluegeri`
    ## $`Tetrapturus pfluegeri`$yearHistogram
    ## $data
    ## $data[[1]]
    ##      y count      x   xmin   xmax      density      ncount    ndensity
    ## 1    2     2 1954.4 1951.6 1957.2 0.0008732099 0.008403361 0.008403361
    ## 2    1     1 1960.0 1957.2 1962.8 0.0004366050 0.004201681 0.004201681
    ## 3    0     0 1965.6 1962.8 1968.4 0.0000000000 0.000000000 0.000000000
    ## 4    0     0 1971.2 1968.4 1974.0 0.0000000000 0.000000000 0.000000000
    ## 5    0     0 1976.8 1974.0 1979.6 0.0000000000 0.000000000 0.000000000
    ## 6    0     0 1982.4 1979.6 1985.2 0.0000000000 0.000000000 0.000000000
    ## 7    0     0 1988.0 1985.2 1990.8 0.0000000000 0.000000000 0.000000000
    ## 8    0     0 1993.6 1990.8 1996.4 0.0000000000 0.000000000 0.000000000
    ## 9  238   238 1999.2 1996.4 2002.0 0.1039119804 1.000000000 1.000000000
    ## 10 161   161 2004.8 2002.0 2007.6 0.0702933985 0.676470588 0.676470588
    ## 11   7     7 2010.4 2007.6 2013.2 0.0030562347 0.029411765 0.029411765
    ##    flipped_aes PANEL group ymin ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0    2  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0  238  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0  161  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0    7  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-28.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Tetrapturus pfluegeri`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #FDE725FF 10  8     1     2  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1     2  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     2  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-29.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Tetrapturus pfluegeri`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-30.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Trachurus trachurus`
    ## $`Trachurus trachurus`$yearHistogram
    ## $data
    ## $data[[1]]
    ##       y count      x    xmin    xmax      density       ncount     ndensity
    ## 1    11    11 1690.7 1674.75 1706.65 3.477487e-05 0.0019386676 0.0019386676
    ## 2     0     0 1722.6 1706.65 1738.55 0.000000e+00 0.0000000000 0.0000000000
    ## 3     0     0 1754.5 1738.55 1770.45 0.000000e+00 0.0000000000 0.0000000000
    ## 4     0     0 1786.4 1770.45 1802.35 0.000000e+00 0.0000000000 0.0000000000
    ## 5     0     0 1818.3 1802.35 1834.25 0.000000e+00 0.0000000000 0.0000000000
    ## 6     1     1 1850.2 1834.25 1866.15 3.161352e-06 0.0001762425 0.0001762425
    ## 7     8     8 1882.1 1866.15 1898.05 2.529081e-05 0.0014099401 0.0014099401
    ## 8   372   372 1914.0 1898.05 1929.95 1.176023e-03 0.0655622136 0.0655622136
    ## 9  1098  1098 1945.9 1929.95 1961.85 3.471164e-03 0.1935142756 0.1935142756
    ## 10 5674  5674 1977.8 1961.85 1993.75 1.793751e-02 1.0000000000 1.0000000000
    ## 11 2752  2752 2009.7 1993.75 2025.65 8.700040e-03 0.4850193867 0.4850193867
    ##    flipped_aes PANEL group ymin ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0   11  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0    8  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0  372  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0 1098  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0 5674  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0 2752  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-31.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Trachurus trachurus`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     2  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-32.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Trachurus trachurus`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-33.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## 
    ## $`Xiphias gladius`
    ## $`Xiphias gladius`$yearHistogram
    ## $data
    ## $data[[1]]
    ##      y count      x    xmin    xmax      density      ncount    ndensity
    ## 1    2     2 1690.7 1674.75 1706.65 4.452836e-05 0.002688172 0.002688172
    ## 2    0     0 1722.6 1706.65 1738.55 0.000000e+00 0.000000000 0.000000000
    ## 3    0     0 1754.5 1738.55 1770.45 0.000000e+00 0.000000000 0.000000000
    ## 4    1     1 1786.4 1770.45 1802.35 2.226418e-05 0.001344086 0.001344086
    ## 5    1     1 1818.3 1802.35 1834.25 2.226418e-05 0.001344086 0.001344086
    ## 6    1     1 1850.2 1834.25 1866.15 2.226418e-05 0.001344086 0.001344086
    ## 7    2     2 1882.1 1866.15 1898.05 4.452836e-05 0.002688172 0.002688172
    ## 8    7     7 1914.0 1898.05 1929.95 1.558492e-04 0.009408602 0.009408602
    ## 9   29    29 1945.9 1929.95 1961.85 6.456612e-04 0.038978495 0.038978495
    ## 10 621   621 1977.8 1961.85 1993.75 1.382605e-02 0.834677419 0.834677419
    ## 11 744   744 2009.7 1993.75 2025.65 1.656455e-02 1.000000000 1.000000000
    ##    flipped_aes PANEL group ymin ymax colour  fill size linetype alpha
    ## 1        FALSE     1    -1    0    2  white black  0.5        1   0.9
    ## 2        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 3        FALSE     1    -1    0    0  white black  0.5        1   0.9
    ## 4        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 5        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 6        FALSE     1    -1    0    1  white black  0.5        1   0.9
    ## 7        FALSE     1    -1    0    2  white black  0.5        1   0.9
    ## 8        FALSE     1    -1    0    7  white black  0.5        1   0.9
    ## 9        FALSE     1    -1    0   29  white black  0.5        1   0.9
    ## 10       FALSE     1    -1    0  621  white black  0.5        1   0.9
    ## 11       FALSE     1    -1    0  744  white black  0.5        1   0.9
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: TRUE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-34.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Xiphias gladius`$source
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #414487FF  7 10     1     2  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #414487FF  8  1     1     2  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #414487FF  8  2     1     2  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #414487FF  8  3     1     2  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #414487FF  8  4     1     2  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #414487FF  8  5     1     2  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #414487FF  8  6     1     2  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #414487FF  8  7     1     2  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #414487FF  8  8     1     2  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #414487FF  8  9     1     2  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #414487FF  8 10     1     2  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #414487FF  9  1     1     2  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #414487FF  9  2     1     2  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #414487FF  9  3     1     2  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #414487FF  9  4     1     2  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #414487FF  9  5     1     2  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #414487FF  9  6     1     2  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #414487FF  9  7     1     2  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #2A788EFF  9  8     1     3  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #2A788EFF  9  9     1     3  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #2A788EFF  9 10     1     3  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #22A884FF 10  1     1     4  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #22A884FF 10  2     1     4  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #7AD151FF 10  3     1     5  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #7AD151FF 10  4     1     5  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #FDE725FF 10  5     1     6  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #FDE725FF 10  6     1     6  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #FDE725FF 10  7     1     6  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #FDE725FF 10  8     1     6  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #FDE725FF 10  9     1     6  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #FDE725FF 10 10     1     6  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-35.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"
    ## 
    ## $`Xiphias gladius`$aggregator
    ## $data
    ## $data[[1]]
    ##          fill  x  y PANEL group xmin xmax ymin ymax colour size linetype alpha
    ## 1   #440154FF  1  1     1     1  0.5  1.5  0.5  1.5  white    2        1    NA
    ## 2   #440154FF  1  2     1     1  0.5  1.5  1.5  2.5  white    2        1    NA
    ## 3   #440154FF  1  3     1     1  0.5  1.5  2.5  3.5  white    2        1    NA
    ## 4   #440154FF  1  4     1     1  0.5  1.5  3.5  4.5  white    2        1    NA
    ## 5   #440154FF  1  5     1     1  0.5  1.5  4.5  5.5  white    2        1    NA
    ## 6   #440154FF  1  6     1     1  0.5  1.5  5.5  6.5  white    2        1    NA
    ## 7   #440154FF  1  7     1     1  0.5  1.5  6.5  7.5  white    2        1    NA
    ## 8   #440154FF  1  8     1     1  0.5  1.5  7.5  8.5  white    2        1    NA
    ## 9   #440154FF  1  9     1     1  0.5  1.5  8.5  9.5  white    2        1    NA
    ## 10  #440154FF  1 10     1     1  0.5  1.5  9.5 10.5  white    2        1    NA
    ## 11  #440154FF  2  1     1     1  1.5  2.5  0.5  1.5  white    2        1    NA
    ## 12  #440154FF  2  2     1     1  1.5  2.5  1.5  2.5  white    2        1    NA
    ## 13  #440154FF  2  3     1     1  1.5  2.5  2.5  3.5  white    2        1    NA
    ## 14  #440154FF  2  4     1     1  1.5  2.5  3.5  4.5  white    2        1    NA
    ## 15  #440154FF  2  5     1     1  1.5  2.5  4.5  5.5  white    2        1    NA
    ## 16  #440154FF  2  6     1     1  1.5  2.5  5.5  6.5  white    2        1    NA
    ## 17  #440154FF  2  7     1     1  1.5  2.5  6.5  7.5  white    2        1    NA
    ## 18  #440154FF  2  8     1     1  1.5  2.5  7.5  8.5  white    2        1    NA
    ## 19  #440154FF  2  9     1     1  1.5  2.5  8.5  9.5  white    2        1    NA
    ## 20  #440154FF  2 10     1     1  1.5  2.5  9.5 10.5  white    2        1    NA
    ## 21  #440154FF  3  1     1     1  2.5  3.5  0.5  1.5  white    2        1    NA
    ## 22  #440154FF  3  2     1     1  2.5  3.5  1.5  2.5  white    2        1    NA
    ## 23  #440154FF  3  3     1     1  2.5  3.5  2.5  3.5  white    2        1    NA
    ## 24  #440154FF  3  4     1     1  2.5  3.5  3.5  4.5  white    2        1    NA
    ## 25  #440154FF  3  5     1     1  2.5  3.5  4.5  5.5  white    2        1    NA
    ## 26  #440154FF  3  6     1     1  2.5  3.5  5.5  6.5  white    2        1    NA
    ## 27  #440154FF  3  7     1     1  2.5  3.5  6.5  7.5  white    2        1    NA
    ## 28  #440154FF  3  8     1     1  2.5  3.5  7.5  8.5  white    2        1    NA
    ## 29  #440154FF  3  9     1     1  2.5  3.5  8.5  9.5  white    2        1    NA
    ## 30  #440154FF  3 10     1     1  2.5  3.5  9.5 10.5  white    2        1    NA
    ## 31  #440154FF  4  1     1     1  3.5  4.5  0.5  1.5  white    2        1    NA
    ## 32  #440154FF  4  2     1     1  3.5  4.5  1.5  2.5  white    2        1    NA
    ## 33  #440154FF  4  3     1     1  3.5  4.5  2.5  3.5  white    2        1    NA
    ## 34  #440154FF  4  4     1     1  3.5  4.5  3.5  4.5  white    2        1    NA
    ## 35  #440154FF  4  5     1     1  3.5  4.5  4.5  5.5  white    2        1    NA
    ## 36  #440154FF  4  6     1     1  3.5  4.5  5.5  6.5  white    2        1    NA
    ## 37  #440154FF  4  7     1     1  3.5  4.5  6.5  7.5  white    2        1    NA
    ## 38  #440154FF  4  8     1     1  3.5  4.5  7.5  8.5  white    2        1    NA
    ## 39  #440154FF  4  9     1     1  3.5  4.5  8.5  9.5  white    2        1    NA
    ## 40  #440154FF  4 10     1     1  3.5  4.5  9.5 10.5  white    2        1    NA
    ## 41  #440154FF  5  1     1     1  4.5  5.5  0.5  1.5  white    2        1    NA
    ## 42  #440154FF  5  2     1     1  4.5  5.5  1.5  2.5  white    2        1    NA
    ## 43  #440154FF  5  3     1     1  4.5  5.5  2.5  3.5  white    2        1    NA
    ## 44  #440154FF  5  4     1     1  4.5  5.5  3.5  4.5  white    2        1    NA
    ## 45  #440154FF  5  5     1     1  4.5  5.5  4.5  5.5  white    2        1    NA
    ## 46  #440154FF  5  6     1     1  4.5  5.5  5.5  6.5  white    2        1    NA
    ## 47  #440154FF  5  7     1     1  4.5  5.5  6.5  7.5  white    2        1    NA
    ## 48  #440154FF  5  8     1     1  4.5  5.5  7.5  8.5  white    2        1    NA
    ## 49  #440154FF  5  9     1     1  4.5  5.5  8.5  9.5  white    2        1    NA
    ## 50  #440154FF  5 10     1     1  4.5  5.5  9.5 10.5  white    2        1    NA
    ## 51  #440154FF  6  1     1     1  5.5  6.5  0.5  1.5  white    2        1    NA
    ## 52  #440154FF  6  2     1     1  5.5  6.5  1.5  2.5  white    2        1    NA
    ## 53  #440154FF  6  3     1     1  5.5  6.5  2.5  3.5  white    2        1    NA
    ## 54  #440154FF  6  4     1     1  5.5  6.5  3.5  4.5  white    2        1    NA
    ## 55  #440154FF  6  5     1     1  5.5  6.5  4.5  5.5  white    2        1    NA
    ## 56  #440154FF  6  6     1     1  5.5  6.5  5.5  6.5  white    2        1    NA
    ## 57  #440154FF  6  7     1     1  5.5  6.5  6.5  7.5  white    2        1    NA
    ## 58  #440154FF  6  8     1     1  5.5  6.5  7.5  8.5  white    2        1    NA
    ## 59  #440154FF  6  9     1     1  5.5  6.5  8.5  9.5  white    2        1    NA
    ## 60  #440154FF  6 10     1     1  5.5  6.5  9.5 10.5  white    2        1    NA
    ## 61  #440154FF  7  1     1     1  6.5  7.5  0.5  1.5  white    2        1    NA
    ## 62  #440154FF  7  2     1     1  6.5  7.5  1.5  2.5  white    2        1    NA
    ## 63  #440154FF  7  3     1     1  6.5  7.5  2.5  3.5  white    2        1    NA
    ## 64  #440154FF  7  4     1     1  6.5  7.5  3.5  4.5  white    2        1    NA
    ## 65  #440154FF  7  5     1     1  6.5  7.5  4.5  5.5  white    2        1    NA
    ## 66  #440154FF  7  6     1     1  6.5  7.5  5.5  6.5  white    2        1    NA
    ## 67  #440154FF  7  7     1     1  6.5  7.5  6.5  7.5  white    2        1    NA
    ## 68  #440154FF  7  8     1     1  6.5  7.5  7.5  8.5  white    2        1    NA
    ## 69  #440154FF  7  9     1     1  6.5  7.5  8.5  9.5  white    2        1    NA
    ## 70  #440154FF  7 10     1     1  6.5  7.5  9.5 10.5  white    2        1    NA
    ## 71  #440154FF  8  1     1     1  7.5  8.5  0.5  1.5  white    2        1    NA
    ## 72  #440154FF  8  2     1     1  7.5  8.5  1.5  2.5  white    2        1    NA
    ## 73  #440154FF  8  3     1     1  7.5  8.5  2.5  3.5  white    2        1    NA
    ## 74  #440154FF  8  4     1     1  7.5  8.5  3.5  4.5  white    2        1    NA
    ## 75  #440154FF  8  5     1     1  7.5  8.5  4.5  5.5  white    2        1    NA
    ## 76  #440154FF  8  6     1     1  7.5  8.5  5.5  6.5  white    2        1    NA
    ## 77  #440154FF  8  7     1     1  7.5  8.5  6.5  7.5  white    2        1    NA
    ## 78  #440154FF  8  8     1     1  7.5  8.5  7.5  8.5  white    2        1    NA
    ## 79  #440154FF  8  9     1     1  7.5  8.5  8.5  9.5  white    2        1    NA
    ## 80  #440154FF  8 10     1     1  7.5  8.5  9.5 10.5  white    2        1    NA
    ## 81  #440154FF  9  1     1     1  8.5  9.5  0.5  1.5  white    2        1    NA
    ## 82  #440154FF  9  2     1     1  8.5  9.5  1.5  2.5  white    2        1    NA
    ## 83  #440154FF  9  3     1     1  8.5  9.5  2.5  3.5  white    2        1    NA
    ## 84  #440154FF  9  4     1     1  8.5  9.5  3.5  4.5  white    2        1    NA
    ## 85  #440154FF  9  5     1     1  8.5  9.5  4.5  5.5  white    2        1    NA
    ## 86  #440154FF  9  6     1     1  8.5  9.5  5.5  6.5  white    2        1    NA
    ## 87  #440154FF  9  7     1     1  8.5  9.5  6.5  7.5  white    2        1    NA
    ## 88  #440154FF  9  8     1     1  8.5  9.5  7.5  8.5  white    2        1    NA
    ## 89  #440154FF  9  9     1     1  8.5  9.5  8.5  9.5  white    2        1    NA
    ## 90  #440154FF  9 10     1     1  8.5  9.5  9.5 10.5  white    2        1    NA
    ## 91  #440154FF 10  1     1     1  9.5 10.5  0.5  1.5  white    2        1    NA
    ## 92  #440154FF 10  2     1     1  9.5 10.5  1.5  2.5  white    2        1    NA
    ## 93  #440154FF 10  3     1     1  9.5 10.5  2.5  3.5  white    2        1    NA
    ## 94  #440154FF 10  4     1     1  9.5 10.5  3.5  4.5  white    2        1    NA
    ## 95  #440154FF 10  5     1     1  9.5 10.5  4.5  5.5  white    2        1    NA
    ## 96  #440154FF 10  6     1     1  9.5 10.5  5.5  6.5  white    2        1    NA
    ## 97  #440154FF 10  7     1     1  9.5 10.5  6.5  7.5  white    2        1    NA
    ## 98  #440154FF 10  8     1     1  9.5 10.5  7.5  8.5  white    2        1    NA
    ## 99  #440154FF 10  9     1     1  9.5 10.5  8.5  9.5  white    2        1    NA
    ## 100 #440154FF 10 10     1     1  9.5 10.5  9.5 10.5  white    2        1    NA
    ##     width height
    ## 1      NA     NA
    ## 2      NA     NA
    ## 3      NA     NA
    ## 4      NA     NA
    ## 5      NA     NA
    ## 6      NA     NA
    ## 7      NA     NA
    ## 8      NA     NA
    ## 9      NA     NA
    ## 10     NA     NA
    ## 11     NA     NA
    ## 12     NA     NA
    ## 13     NA     NA
    ## 14     NA     NA
    ## 15     NA     NA
    ## 16     NA     NA
    ## 17     NA     NA
    ## 18     NA     NA
    ## 19     NA     NA
    ## 20     NA     NA
    ## 21     NA     NA
    ## 22     NA     NA
    ## 23     NA     NA
    ## 24     NA     NA
    ## 25     NA     NA
    ## 26     NA     NA
    ## 27     NA     NA
    ## 28     NA     NA
    ## 29     NA     NA
    ## 30     NA     NA
    ## 31     NA     NA
    ## 32     NA     NA
    ## 33     NA     NA
    ## 34     NA     NA
    ## 35     NA     NA
    ## 36     NA     NA
    ## 37     NA     NA
    ## 38     NA     NA
    ## 39     NA     NA
    ## 40     NA     NA
    ## 41     NA     NA
    ## 42     NA     NA
    ## 43     NA     NA
    ## 44     NA     NA
    ## 45     NA     NA
    ## 46     NA     NA
    ## 47     NA     NA
    ## 48     NA     NA
    ## 49     NA     NA
    ## 50     NA     NA
    ## 51     NA     NA
    ## 52     NA     NA
    ## 53     NA     NA
    ## 54     NA     NA
    ## 55     NA     NA
    ## 56     NA     NA
    ## 57     NA     NA
    ## 58     NA     NA
    ## 59     NA     NA
    ## 60     NA     NA
    ## 61     NA     NA
    ## 62     NA     NA
    ## 63     NA     NA
    ## 64     NA     NA
    ## 65     NA     NA
    ## 66     NA     NA
    ## 67     NA     NA
    ## 68     NA     NA
    ## 69     NA     NA
    ## 70     NA     NA
    ## 71     NA     NA
    ## 72     NA     NA
    ## 73     NA     NA
    ## 74     NA     NA
    ## 75     NA     NA
    ## 76     NA     NA
    ## 77     NA     NA
    ## 78     NA     NA
    ## 79     NA     NA
    ## 80     NA     NA
    ## 81     NA     NA
    ## 82     NA     NA
    ## 83     NA     NA
    ## 84     NA     NA
    ## 85     NA     NA
    ## 86     NA     NA
    ## 87     NA     NA
    ## 88     NA     NA
    ## 89     NA     NA
    ## 90     NA     NA
    ## 91     NA     NA
    ## 92     NA     NA
    ## 93     NA     NA
    ## 94     NA     NA
    ## 95     NA     NA
    ## 96     NA     NA
    ## 97     NA     NA
    ## 98     NA     NA
    ## 99     NA     NA
    ## 100    NA     NA
    ## 
    ## 
    ## $layout
    ## <ggproto object: Class Layout, gg>
    ##     coord: <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##         aspect: function
    ##         backtransform_range: function
    ##         clip: on
    ##         default: FALSE
    ##         distance: function
    ##         expand: TRUE
    ##         is_free: function
    ##         is_linear: function
    ##         labels: function
    ##         limits: list
    ##         modify_scales: function
    ##         range: function
    ##         ratio: 1
    ##         render_axis_h: function
    ##         render_axis_v: function
    ##         render_bg: function
    ##         render_fg: function
    ##         setup_data: function
    ##         setup_layout: function
    ##         setup_panel_guides: function
    ##         setup_panel_params: function
    ##         setup_params: function
    ##         train_panel_guides: function
    ##         transform: function
    ##         super:  <ggproto object: Class CoordFixed, CoordCartesian, Coord, gg>
    ##     coord_params: list
    ##     facet: <ggproto object: Class FacetNull, Facet, gg>
    ##         compute_layout: function
    ##         draw_back: function
    ##         draw_front: function
    ##         draw_labels: function
    ##         draw_panels: function
    ##         finish_data: function
    ##         init_scales: function
    ##         map_data: function
    ##         params: list
    ##         setup_data: function
    ##         setup_params: function
    ##         shrink: TRUE
    ##         train_scales: function
    ##         vars: function
    ##         super:  <ggproto object: Class FacetNull, Facet, gg>
    ##     facet_params: list
    ##     finish_data: function
    ##     get_scales: function
    ##     layout: data.frame
    ##     map_position: function
    ##     panel_params: list
    ##     panel_scales_x: list
    ##     panel_scales_y: list
    ##     render: function
    ##     render_labels: function
    ##     reset_scales: function
    ##     setup: function
    ##     setup_panel_guides: function
    ##     setup_panel_params: function
    ##     train_position: function
    ##     xlabel: function
    ##     ylabel: function
    ##     super:  <ggproto object: Class Layout, gg>
    ## 
    ## $plot

![](README_files/figure-markdown_github/summary%20figures%20by%20species-36.png)

    ## 
    ## attr(,"class")
    ## [1] "ggplot_built"

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
