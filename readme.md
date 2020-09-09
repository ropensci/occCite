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
    ##  OccCite query occurred on: 09 September, 2020
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

    ## Cameron E, Auckland Museum A M (2020). Auckland Museum Botany Collection. Version 1.51. Auckland War Memorial Museum. https://doi.org/10.15468/mnjkvv. Accessed via GBIF on 2019-07-15.
    ## Capers R (2014). CONN. University of Connecticut. https://doi.org/10.15468/w35jmd. Accessed via GBIF on 2019-07-15.
    ## Fatima Parker-Allie, Ranwashe F (2018). PRECIS. South African National Biodiversity Institute. https://doi.org/10.15468/rckmn2. Accessed via GBIF on 2019-07-15.
    ## Magill B, Solomon J, Stimmel H (2020). Tropicos Specimen Data. Missouri Botanical Garden. https://doi.org/10.15468/hja69f. Accessed via GBIF on 2019-07-15.
    ## Missouri Botanical Garden,Herbarium. Accessed via BIEN on NA.
    ## MNHN, Chagnoux S (2020). The vascular plants collection (P) at the Herbarium of the Muséum national d'Histoire Naturelle (MNHN - Paris). Version 69.180. MNHN - Museum national d'Histoire naturelle. https://doi.org/10.15468/nc6rxy. Accessed via GBIF on 2019-07-15.
    ## MNHN. https://doi.org/10.15468/dl.fpwlzt. Accessed via BIEN on 2018-08-14.
    ## naturgucker.de. naturgucker. https://doi.org/10.15468/uc1apo. Accessed via GBIF on 2019-07-15.
    ## NSW. https://doi.org/10.15468/dl.fpwlzt. Accessed via BIEN on 2018-08-14.
    ## Ranwashe F (2019). BODATSA: Botanical Collections. Version 1.4. South African National Biodiversity Institute. https://doi.org/10.15468/2aki0q. Accessed via GBIF on 2019-07-15.
    ## SANBI. https://doi.org/10.15468/dl.fpwlzt. Accessed via BIEN on 2018-08-14.
    ## Senckenberg (2020). African Plants - a photo guide. https://doi.org/10.15468/r9azth. Accessed via GBIF on 2019-07-15.
    ## Tela Botanica. Carnet en Ligne. https://doi.org/10.15468/rydcn2. Accessed via GBIF on 2019-07-15.
    ## UConn. https://doi.org/10.15468/dl.fpwlzt. Accessed via BIEN on 2018-08-14.
    ## Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. https://doi.org/10.15468/ab3s5x. Accessed via GBIF on 2019-07-15.

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
    ##  OccCite query occurred on: 09 September, 2020
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

    ## Cameron E, Auckland Museum A M (2020). Auckland Museum Botany Collection. Version 1.51. Auckland War Memorial Museum. https://doi.org/10.15468/mnjkvv. Accessed via GBIF on 2019-07-15.
    ## Capers R (2014). CONN. University of Connecticut. https://doi.org/10.15468/w35jmd. Accessed via GBIF on 2019-07-15.
    ## Fatima Parker-Allie, Ranwashe F (2018). PRECIS. South African National Biodiversity Institute. https://doi.org/10.15468/rckmn2. Accessed via GBIF on 2019-07-15.
    ## Magill B, Solomon J, Stimmel H (2020). Tropicos Specimen Data. Missouri Botanical Garden. https://doi.org/10.15468/hja69f. Accessed via GBIF on 2019-07-15.
    ## Missouri Botanical Garden,Herbarium. Accessed via BIEN on NA.
    ## MNHN, Chagnoux S (2020). The vascular plants collection (P) at the Herbarium of the Muséum national d'Histoire Naturelle (MNHN - Paris). Version 69.180. MNHN - Museum national d'Histoire naturelle. https://doi.org/10.15468/nc6rxy. Accessed via GBIF on 2019-07-15.
    ## MNHN. https://doi.org/10.15468/dl.fpwlzt. Accessed via BIEN on 2018-08-14.
    ## naturgucker.de. naturgucker. https://doi.org/10.15468/uc1apo. Accessed via GBIF on 2019-07-15.
    ## NSW. https://doi.org/10.15468/dl.fpwlzt. Accessed via BIEN on 2018-08-14.
    ## Ranwashe F (2019). BODATSA: Botanical Collections. Version 1.4. South African National Biodiversity Institute. https://doi.org/10.15468/2aki0q. Accessed via GBIF on 2019-07-15.
    ## SANBI. https://doi.org/10.15468/dl.fpwlzt. Accessed via BIEN on 2018-08-14.
    ## Senckenberg (2020). African Plants - a photo guide. https://doi.org/10.15468/r9azth. Accessed via GBIF on 2019-07-15.
    ## Tela Botanica. Carnet en Ligne. https://doi.org/10.15468/rydcn2. Accessed via GBIF on 2019-07-15.
    ## UConn. https://doi.org/10.15468/dl.fpwlzt. Accessed via BIEN on 2018-08-14.
    ## Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. https://doi.org/10.15468/ab3s5x. Accessed via GBIF on 2019-07-15.

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
    ##  OccCite query occurred on: 09 September, 2020
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

    ## Australian Museum (2020). Australian Museum provider for OZCAM. https://doi.org/10.15468/e7susi. Accessed via GBIF on 2019-07-04.
    ## Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. https://doi.org/10.15468/dz1kk0. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/elttrd. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/gdrknh. Accessed via GBIF on 2019-07-04.
    ## Bentley A (2020). KUBI Ichthyology Collection. Version 17.67. University of Kansas Biodiversity Institute. https://doi.org/10.15468/mgjasg. Accessed via GBIF on 2019-07-04.
    ## Bentley A (2020). KUBI Ichthyology Tissue Collection. Version 18.55. University of Kansas Biodiversity Institute. https://doi.org/10.15468/jmsnwg. Accessed via GBIF on 2019-07-04.
    ## Casassovici A, Brosens D (2020). Diveboard - Scuba diving citizen science observations. Version 54.28. Diveboard. https://doi.org/10.15468/tnjrgy. Accessed via GBIF on 2019-07-04.
    ## Catania D, Fong J (2020). CAS Ichthyology (ICH). Version 150.239. California Academy of Sciences. https://doi.org/10.15468/efh2ib. Accessed via GBIF on 2019-07-04.
    ## Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. https://doi.org/10.15468/23m361. Accessed via GBIF on 2019-07-04.
    ## Chiang W (2014). Taiwan Fisheries Research Institute – Digital archives of coastal and offshore specimens. TELDAP. https://doi.org/10.15468/xvxngy. Accessed via GBIF on 2019-07-04.
    ## Commonwealth Scientific and Industrial Research Organisation (2020). CSIRO Ichthyology provider for OZCAM. https://doi.org/10.15468/azp1pf. Accessed via GBIF on 2019-07-04.
    ## CSIRO Oceans and Atmosphere (2020). CSIRO, Rachel Cruises, Shark Data, Arafura Sea, North Australia, 1984. Version 6.2. https://doi.org/10.15468/yickr6. Accessed via GBIF on 2019-07-04.
    ## Elías Gutiérrez M, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Códigos de barras de la vida en peces y zooplancton de México. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/xmbkgo. Accessed via GBIF on 2019-07-04.
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. https://doi.org/10.15468/cndomv. Accessed via GBIF on 2019-07-04.
    ## Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. https://doi.org/10.15468/77rmwd. Accessed via GBIF on 2019-07-04.
    ## Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. https://doi.org/10.15468/ad1ovc. Accessed via GBIF on 2019-07-04.
    ## González Acosta A F, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Ampliación de la base de datos de la ictiofauna insular del Golfo de California. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/p5ovq7. Accessed via GBIF on 2019-07-04.
    ## Grant S, McMahan C (2020). Field Museum of Natural History (Zoology) Fish Collection. Version 13.12. Field Museum. https://doi.org/10.15468/alz7wu. Accessed via GBIF on 2019-07-04.
    ## Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.225. Museum of Comparative Zoology, Harvard University. https://doi.org/10.15468/p5rupv. Accessed via GBIF on 2019-07-04.
    ## Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. https://doi.org/10.15468/i66xdm. Accessed via GBIF on 2019-07-04.
    ## Mackay K (2019). Marine biological observation data from coastal and offshore surveys around New Zealand. Version 1.8. The National Institute of Water and Atmospheric Research (NIWA). https://doi.org/10.15468/pzpgop. Accessed via GBIF on 2019-07-04.
    ## Maslenikov K (2019). UWFC Ichthyology Collection. University of Washington Burke Museum. https://doi.org/10.15468/vvp7gr. Accessed via GBIF on 2019-07-04.
    ## Millen B (2019). Ichthyology Collection - Royal Ontario Museum. Version 18.7. Royal Ontario Museum. https://doi.org/10.15468/syisbx. Accessed via GBIF on 2019-07-04.
    ## Museum and Art Gallery of the Northern Territory (2019). Northern Territory Museum and Art Gallery provider for OZCAM. https://doi.org/10.15468/giro3a. Accessed via GBIF on 2019-07-04.
    ## Museums Victoria (2020). Museums Victoria provider for OZCAM. https://doi.org/10.15468/lp1ctu. Accessed via GBIF on 2019-07-04.
    ## National Museum of Nature and Science, Japan (2020). Fish specimens of Kagoshima University Museum. https://doi.org/10.15468/vcj3j8. Accessed via GBIF on 2019-07-04.
    ## Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. https://doi.org/10.15468/hnhrg3. Accessed via GBIF on 2019-07-04.
    ## Pozo de la Tijera M D C, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Fortalecimiento de las colecciones de ECOSUR. Primera fase (Ictioplancton Chetumal). Version 1.3. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/orx3mk. Accessed via GBIF on 2019-07-04.
    ## Queensland Museum (2020). Queensland Museum provider for OZCAM. https://doi.org/10.15468/lotsye. Accessed via GBIF on 2019-07-04.
    ## Raiva R, Santana P (2019). Diversidade e ocorrência de peixes em Inhambane (2009-2017). Version 1.4. National Institute of Fisheries Research (IIP) – Mozambique. https://doi.org/10.15468/4fj2tq. Accessed via GBIF on 2019-07-04.
    ## Raiva R, Viador R, Santana P (2019). Diversidade e ocorrência de peixes na Zambézia (2003-2016). National Institute of Fisheries Research (IIP) – Mozambique. https://doi.org/10.15468/mrz36h. Accessed via GBIF on 2019-07-04.
    ## Ranz J (2017). Banco de Datos de la Biodiversidad de la Comunitat Valenciana. Biodiversity data bank of Generalitat Valenciana. https://doi.org/10.15468/b4yqdy. Accessed via GBIF on 2019-07-04.
    ## Robins R (2020). UF FLMNH Ichthyology. Version 117.278. Florida Museum of Natural History. https://doi.org/10.15468/8mjsel. Accessed via GBIF on 2019-07-04.
    ## Sánchez González S, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Taxonomía y sistemática de la Ictiofauna de la Bahía de Banderas del Estado de Nayarit, México. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/uhrwsl. Accessed via GBIF on 2019-07-04.
    ## Shane G (2018). Pelagic fish food web linkages, Queensland, Australia (2003-2005). CSIRO Oceans and Atmosphere. https://doi.org/10.15468/yy5wdp. Accessed via GBIF on 2019-07-04.
    ## South Australian Museum (2020). South Australian Museum Australia provider for OZCAM. https://doi.org/10.15468/wz4rrh. Accessed via GBIF on 2019-07-04.
    ## The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). https://doi.org/10.15468/inygc6. Accessed via GBIF on 2019-07-04.
    ## Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. https://doi.org/10.15468/vjeh1p. Accessed via GBIF on 2019-07-04.
    ## Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. https://doi.org/10.15468/ab3s5x. Accessed via GBIF on 2019-07-04.
    ## UMS PatriNat (OFB-CNRS-MNHN), Paris (2020). Données d'occurrences Espèces issues de l'inventaire des ZNIEFF. Version 1.1. https://doi.org/10.15468/ikshke. Accessed via GBIF on 2019-07-04.
    ## Western Australian Museum (2019). Western Australian Museum provider for OZCAM. https://doi.org/10.15468/5qt0dm. Accessed via GBIF on 2019-07-04.

It is also possible to print citations separated by species.

``` r
print(myPhyOccCitations, bySpecies = T)
```

    ## Species: Istiompax indica 
    ## 
    ## Australian Museum (2020). Australian Museum provider for OZCAM. https://doi.org/10.15468/e7susi. Accessed via GBIF on 2019-07-04.
    ## Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. https://doi.org/10.15468/dz1kk0. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/elttrd. Accessed via GBIF on 2019-07-04.
    ## Catania D, Fong J (2020). CAS Ichthyology (ICH). Version 150.239. California Academy of Sciences. https://doi.org/10.15468/efh2ib. Accessed via GBIF on 2019-07-04.
    ## Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. https://doi.org/10.15468/23m361. Accessed via GBIF on 2019-07-04.
    ## CSIRO Oceans and Atmosphere (2020). CSIRO, Rachel Cruises, Shark Data, Arafura Sea, North Australia, 1984. Version 6.2. https://doi.org/10.15468/yickr6. Accessed via GBIF on 2019-07-04.
    ## Elías Gutiérrez M, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Códigos de barras de la vida en peces y zooplancton de México. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/xmbkgo. Accessed via GBIF on 2019-07-04.
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. https://doi.org/10.15468/cndomv. Accessed via GBIF on 2019-07-04.
    ## Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. https://doi.org/10.15468/77rmwd. Accessed via GBIF on 2019-07-04.
    ## Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. https://doi.org/10.15468/i66xdm. Accessed via GBIF on 2019-07-04.
    ## Museum and Art Gallery of the Northern Territory (2019). Northern Territory Museum and Art Gallery provider for OZCAM. https://doi.org/10.15468/giro3a. Accessed via GBIF on 2019-07-04.
    ## Museums Victoria (2020). Museums Victoria provider for OZCAM. https://doi.org/10.15468/lp1ctu. Accessed via GBIF on 2019-07-04.
    ## Pozo de la Tijera M D C, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Fortalecimiento de las colecciones de ECOSUR. Primera fase (Ictioplancton Chetumal). Version 1.3. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/orx3mk. Accessed via GBIF on 2019-07-04.
    ## Queensland Museum (2020). Queensland Museum provider for OZCAM. https://doi.org/10.15468/lotsye. Accessed via GBIF on 2019-07-04.
    ## Raiva R, Santana P (2019). Diversidade e ocorrência de peixes em Inhambane (2009-2017). Version 1.4. National Institute of Fisheries Research (IIP) – Mozambique. https://doi.org/10.15468/4fj2tq. Accessed via GBIF on 2019-07-04.
    ## Raiva R, Viador R, Santana P (2019). Diversidade e ocorrência de peixes na Zambézia (2003-2016). National Institute of Fisheries Research (IIP) – Mozambique. https://doi.org/10.15468/mrz36h. Accessed via GBIF on 2019-07-04.
    ## Robins R (2020). UF FLMNH Ichthyology. Version 117.278. Florida Museum of Natural History. https://doi.org/10.15468/8mjsel. Accessed via GBIF on 2019-07-04.
    ## Sánchez González S, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Taxonomía y sistemática de la Ictiofauna de la Bahía de Banderas del Estado de Nayarit, México. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/uhrwsl. Accessed via GBIF on 2019-07-04.
    ## Shane G (2018). Pelagic fish food web linkages, Queensland, Australia (2003-2005). CSIRO Oceans and Atmosphere. https://doi.org/10.15468/yy5wdp. Accessed via GBIF on 2019-07-04.
    ## The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). https://doi.org/10.15468/inygc6. Accessed via GBIF on 2019-07-04.
    ## Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. https://doi.org/10.15468/vjeh1p. Accessed via GBIF on 2019-07-04.
    ## Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. https://doi.org/10.15468/ab3s5x. Accessed via GBIF on 2019-07-04.
    ## Western Australian Museum (2019). Western Australian Museum provider for OZCAM. https://doi.org/10.15468/5qt0dm. Accessed via GBIF on 2019-07-04.
    ## 
    ## Species: Kajikia albida 
    ## 
    ## Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. https://doi.org/10.15468/dz1kk0. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/gdrknh. Accessed via GBIF on 2019-07-04.
    ## Bentley A (2020). KUBI Ichthyology Collection. Version 17.67. University of Kansas Biodiversity Institute. https://doi.org/10.15468/mgjasg. Accessed via GBIF on 2019-07-04.
    ## Bentley A (2020). KUBI Ichthyology Tissue Collection. Version 18.55. University of Kansas Biodiversity Institute. https://doi.org/10.15468/jmsnwg. Accessed via GBIF on 2019-07-04.
    ## Casassovici A, Brosens D (2020). Diveboard - Scuba diving citizen science observations. Version 54.28. Diveboard. https://doi.org/10.15468/tnjrgy. Accessed via GBIF on 2019-07-04.
    ## Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. https://doi.org/10.15468/23m361. Accessed via GBIF on 2019-07-04.
    ## Elías Gutiérrez M, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Códigos de barras de la vida en peces y zooplancton de México. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/xmbkgo. Accessed via GBIF on 2019-07-04.
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. https://doi.org/10.15468/cndomv. Accessed via GBIF on 2019-07-04.
    ## Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. https://doi.org/10.15468/77rmwd. Accessed via GBIF on 2019-07-04.
    ## Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. https://doi.org/10.15468/ad1ovc. Accessed via GBIF on 2019-07-04.
    ## Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.225. Museum of Comparative Zoology, Harvard University. https://doi.org/10.15468/p5rupv. Accessed via GBIF on 2019-07-04.
    ## Millen B (2019). Ichthyology Collection - Royal Ontario Museum. Version 18.7. Royal Ontario Museum. https://doi.org/10.15468/syisbx. Accessed via GBIF on 2019-07-04.
    ## Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. https://doi.org/10.15468/hnhrg3. Accessed via GBIF on 2019-07-04.
    ## Pozo de la Tijera M D C, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Fortalecimiento de las colecciones de ECOSUR. Primera fase (Ictioplancton Chetumal). Version 1.3. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/orx3mk. Accessed via GBIF on 2019-07-04.
    ## Robins R (2020). UF FLMNH Ichthyology. Version 117.278. Florida Museum of Natural History. https://doi.org/10.15468/8mjsel. Accessed via GBIF on 2019-07-04.
    ## The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). https://doi.org/10.15468/inygc6. Accessed via GBIF on 2019-07-04.
    ## 
    ## Species: Kajikia audax 
    ## 
    ## Australian Museum (2020). Australian Museum provider for OZCAM. https://doi.org/10.15468/e7susi. Accessed via GBIF on 2019-07-04.
    ## Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. https://doi.org/10.15468/dz1kk0. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/elttrd. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/gdrknh. Accessed via GBIF on 2019-07-04.
    ## Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. https://doi.org/10.15468/23m361. Accessed via GBIF on 2019-07-04.
    ## Chiang W (2014). Taiwan Fisheries Research Institute – Digital archives of coastal and offshore specimens. TELDAP. https://doi.org/10.15468/xvxngy. Accessed via GBIF on 2019-07-04.
    ## Commonwealth Scientific and Industrial Research Organisation (2020). CSIRO Ichthyology provider for OZCAM. https://doi.org/10.15468/azp1pf. Accessed via GBIF on 2019-07-04.
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. https://doi.org/10.15468/cndomv. Accessed via GBIF on 2019-07-04.
    ## Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. https://doi.org/10.15468/77rmwd. Accessed via GBIF on 2019-07-04.
    ## Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. https://doi.org/10.15468/ad1ovc. Accessed via GBIF on 2019-07-04.
    ## González Acosta A F, Comisión nacional para el conocimiento y uso de la biodiversidad C (2020). Ampliación de la base de datos de la ictiofauna insular del Golfo de California. Version 1.7. Comisión nacional para el conocimiento y uso de la biodiversidad. https://doi.org/10.15468/p5ovq7. Accessed via GBIF on 2019-07-04.
    ## Grant S, McMahan C (2020). Field Museum of Natural History (Zoology) Fish Collection. Version 13.12. Field Museum. https://doi.org/10.15468/alz7wu. Accessed via GBIF on 2019-07-04.
    ## Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. https://doi.org/10.15468/i66xdm. Accessed via GBIF on 2019-07-04.
    ## Mackay K (2019). Marine biological observation data from coastal and offshore surveys around New Zealand. Version 1.8. The National Institute of Water and Atmospheric Research (NIWA). https://doi.org/10.15468/pzpgop. Accessed via GBIF on 2019-07-04.
    ## Maslenikov K (2019). UWFC Ichthyology Collection. University of Washington Burke Museum. https://doi.org/10.15468/vvp7gr. Accessed via GBIF on 2019-07-04.
    ## Museum and Art Gallery of the Northern Territory (2019). Northern Territory Museum and Art Gallery provider for OZCAM. https://doi.org/10.15468/giro3a. Accessed via GBIF on 2019-07-04.
    ## Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. https://doi.org/10.15468/hnhrg3. Accessed via GBIF on 2019-07-04.
    ## Queensland Museum (2020). Queensland Museum provider for OZCAM. https://doi.org/10.15468/lotsye. Accessed via GBIF on 2019-07-04.
    ## Robins R (2020). UF FLMNH Ichthyology. Version 117.278. Florida Museum of Natural History. https://doi.org/10.15468/8mjsel. Accessed via GBIF on 2019-07-04.
    ## The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). https://doi.org/10.15468/inygc6. Accessed via GBIF on 2019-07-04.
    ## Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. https://doi.org/10.15468/vjeh1p. Accessed via GBIF on 2019-07-04.
    ## Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. https://doi.org/10.15468/ab3s5x. Accessed via GBIF on 2019-07-04.
    ## 
    ## Species: Tetrapturus angustirostris 
    ## 
    ## Australian Museum (2020). Australian Museum provider for OZCAM. https://doi.org/10.15468/e7susi. Accessed via GBIF on 2019-07-04.
    ## Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. https://doi.org/10.15468/dz1kk0. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/elttrd. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/gdrknh. Accessed via GBIF on 2019-07-04.
    ## Catania D, Fong J (2020). CAS Ichthyology (ICH). Version 150.239. California Academy of Sciences. https://doi.org/10.15468/efh2ib. Accessed via GBIF on 2019-07-04.
    ## Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. https://doi.org/10.15468/23m361. Accessed via GBIF on 2019-07-04.
    ## Chiang W (2014). Taiwan Fisheries Research Institute – Digital archives of coastal and offshore specimens. TELDAP. https://doi.org/10.15468/xvxngy. Accessed via GBIF on 2019-07-04.
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. https://doi.org/10.15468/cndomv. Accessed via GBIF on 2019-07-04.
    ## Feeney R (2019). LACM Vertebrate Collection. Version 18.7. Natural History Museum of Los Angeles County. https://doi.org/10.15468/77rmwd. Accessed via GBIF on 2019-07-04.
    ## Frable B (2019). SIO Marine Vertebrate Collection. Version 1.7. Scripps Institution of Oceanography. https://doi.org/10.15468/ad1ovc. Accessed via GBIF on 2019-07-04.
    ## Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.225. Museum of Comparative Zoology, Harvard University. https://doi.org/10.15468/p5rupv. Accessed via GBIF on 2019-07-04.
    ## Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. https://doi.org/10.15468/i66xdm. Accessed via GBIF on 2019-07-04.
    ## National Museum of Nature and Science, Japan (2020). Fish specimens of Kagoshima University Museum. https://doi.org/10.15468/vcj3j8. Accessed via GBIF on 2019-07-04.
    ## Queensland Museum (2020). Queensland Museum provider for OZCAM. https://doi.org/10.15468/lotsye. Accessed via GBIF on 2019-07-04.
    ## Raiva R, Santana P (2019). Diversidade e ocorrência de peixes em Inhambane (2009-2017). Version 1.4. National Institute of Fisheries Research (IIP) – Mozambique. https://doi.org/10.15468/4fj2tq. Accessed via GBIF on 2019-07-04.
    ## Raiva R, Viador R, Santana P (2019). Diversidade e ocorrência de peixes na Zambézia (2003-2016). National Institute of Fisheries Research (IIP) – Mozambique. https://doi.org/10.15468/mrz36h. Accessed via GBIF on 2019-07-04.
    ## Robins R (2020). UF FLMNH Ichthyology. Version 117.278. Florida Museum of Natural History. https://doi.org/10.15468/8mjsel. Accessed via GBIF on 2019-07-04.
    ## South Australian Museum (2020). South Australian Museum Australia provider for OZCAM. https://doi.org/10.15468/wz4rrh. Accessed via GBIF on 2019-07-04.
    ## The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). https://doi.org/10.15468/inygc6. Accessed via GBIF on 2019-07-04.
    ## Uchifune Y, Yamamoto H (2020). Asia-Pacific Dataset. Version 1.33. National Museum of Nature and Science, Japan. https://doi.org/10.15468/vjeh1p. Accessed via GBIF on 2019-07-04.
    ## Ueda K (2020). iNaturalist Research-grade Observations. iNaturalist.org. https://doi.org/10.15468/ab3s5x. Accessed via GBIF on 2019-07-04.
    ## Western Australian Museum (2019). Western Australian Museum provider for OZCAM. https://doi.org/10.15468/5qt0dm. Accessed via GBIF on 2019-07-04.
    ## 
    ## Species: Tetrapturus belone 
    ## 
    ## Bentley A (2020). KUBI Ichthyology Collection. Version 17.67. University of Kansas Biodiversity Institute. https://doi.org/10.15468/mgjasg. Accessed via GBIF on 2019-07-04.
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. https://doi.org/10.15468/cndomv. Accessed via GBIF on 2019-07-04.
    ## Harvard University M, Morris P J (2020). Museum of Comparative Zoology, Harvard University. Version 162.225. Museum of Comparative Zoology, Harvard University. https://doi.org/10.15468/p5rupv. Accessed via GBIF on 2019-07-04.
    ## Ranz J (2017). Banco de Datos de la Biodiversidad de la Comunitat Valenciana. Biodiversity data bank of Generalitat Valenciana. https://doi.org/10.15468/b4yqdy. Accessed via GBIF on 2019-07-04.
    ## Robins R (2020). UF FLMNH Ichthyology. Version 117.278. Florida Museum of Natural History. https://doi.org/10.15468/8mjsel. Accessed via GBIF on 2019-07-04.
    ## UMS PatriNat (OFB-CNRS-MNHN), Paris (2020). Données d'occurrences Espèces issues de l'inventaire des ZNIEFF. Version 1.1. https://doi.org/10.15468/ikshke. Accessed via GBIF on 2019-07-04.
    ## 
    ## Species: Tetrapturus georgii 
    ## 
    ## Bentley A (2020). KUBI Ichthyology Collection. Version 17.67. University of Kansas Biodiversity Institute. https://doi.org/10.15468/mgjasg. Accessed via GBIF on 2019-07-04.
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. https://doi.org/10.15468/cndomv. Accessed via GBIF on 2019-07-04.
    ## Orrell T (2020). NMNH Extant Specimen Records. Version 1.35. National Museum of Natural History, Smithsonian Institution. https://doi.org/10.15468/hnhrg3. Accessed via GBIF on 2019-07-04.
    ## The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). https://doi.org/10.15468/inygc6. Accessed via GBIF on 2019-07-04.
    ## 
    ## Species: Tetrapturus pfluegeri 
    ## 
    ## Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. https://doi.org/10.15468/dz1kk0. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/elttrd. Accessed via GBIF on 2019-07-04.
    ## BARDE Julien N, Inventaire National du Patrimoine Naturel (2019). Programme Ecoscope: données d'observations des écosystèmes marins exploités. Version 1.1. UMS PatriNat (OFB-CNRS-MNHN), Paris. https://doi.org/10.15468/gdrknh. Accessed via GBIF on 2019-07-04.
    ## Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. https://doi.org/10.15468/23m361. Accessed via GBIF on 2019-07-04.
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. https://doi.org/10.15468/cndomv. Accessed via GBIF on 2019-07-04.
    ## Robins R (2020). UF FLMNH Ichthyology. Version 117.278. Florida Museum of Natural History. https://doi.org/10.15468/8mjsel. Accessed via GBIF on 2019-07-04.
    ## The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). https://doi.org/10.15468/inygc6. Accessed via GBIF on 2019-07-04.

------------------------------------------------------------------------

Visualization features
======================

Search result summary figures
-----------------------------

occCite includes a function called `sumFig.occCite()` which is capable
of generating three types of plots from an `occCiteData` object. First,
let’s see how the results of our multiple species query looks.

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
