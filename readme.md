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
sumFig.occCite(myPhyOccCiteObject, 
               bySpecies = F, 
               plotTypes = c("yearHistogram", "source", "aggregator"))
```

<img src="README_files/figure-markdown_github/summary figures overall-1.png" width="32%" /><img src="README_files/figure-markdown_github/summary figures overall-2.png" width="32%" /><img src="README_files/figure-markdown_github/summary figures overall-3.png" width="32%" />

We can also generate plots for each species in the `occCiteData` object
individually. Since GBIF is the only aggregator we used for the query,
I’ll skip generating the aggregator plot.

``` r
sumFig.occCite(myPhyOccCiteObject, 
               bySpecies = T, 
               plotTypes = c("yearHistogram", "source"))
```

<img src="README_files/figure-markdown_github/summary figures by species-1.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-2.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-3.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-4.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-5.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-6.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-7.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-8.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-9.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-10.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-11.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-12.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-13.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-14.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-15.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-16.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-17.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-18.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-19.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-20.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-21.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-22.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-23.png" width="50%" /><img src="README_files/figure-markdown_github/summary figures by species-24.png" width="50%" />

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
