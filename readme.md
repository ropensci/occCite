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

    ## Registered S3 method overwritten by 'httr':
    ##   method                 from
    ##   as.character.form_file crul

Here is what the GBIF results look like:

``` r
# GBIF search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);
```

    ##       gbifID              name longitude  latitude day month year Dataset
    ## 1 2273313855 Protea cynaroides  18.40540 -33.95891   4     1 2015        
    ## 2 2273260085 Protea cynaroides  18.42350 -33.96619  20     6 2019        
    ## 3 2273226338 Protea cynaroides  22.99340 -34.05478  16     6 2019        
    ## 4 2265902358 Protea cynaroides  18.40232 -34.08405   9     6 2019        
    ## 5 2265901204 Protea cynaroides  19.44807 -34.52123  13     6 2019        
    ## 6 2265862297 Protea cynaroides  18.39757 -34.07418   9     6 2019        
    ##                             DatasetKey DataService
    ## 1 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 2 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 3 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 4 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 5 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 6 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF

And here are the BIEN results:

``` r
#BIEN search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$BIEN$OccurrenceTable);
```

    ##                name longitude latitude day month year     Dataset
    ## 1 Protea cynaroides  18.42100 -34.0920  24     9 2013 iNaturalist
    ## 2 Protea cynaroides  18.96570 -34.0970   1     3 2014 iNaturalist
    ## 3 Protea cynaroides  18.42114 -34.0908   8    10 2008 naturgucker
    ## 4 Protea cynaroides  22.87500 -33.8750  20     8 1973       SANBI
    ## 5 Protea cynaroides  25.12500 -33.8750   3     7 1934       SANBI
    ## 6 Protea cynaroides  20.37500 -33.8750  16     8 1952       SANBI
    ##   DatasetKey DataService
    ## 1       3123        BIEN
    ## 2       3123        BIEN
    ## 3       2082        BIEN
    ## 4       2249        BIEN
    ## 5       2249        BIEN
    ## 6       2249        BIEN

There is also a summary method for `occCite` objects with some basic
information about your search.

``` r
summary(mySimpleOccCiteObject)
```

    ##  
    ##  OccCite query occurred on: 10 October, 2019
    ##  
    ##  User query type: User-supplied list of taxa.
    ##  
    ##  Sources for taxonomic rectification: NCBI, EOL
    ##      
    ##  
    ##  Taxonomic cleaning results:     
    ## 
    ##          Input Name        Best Match Taxonomic Databases w/ Matches
    ## 1 Protea cynaroides Protea cynaroides                      NCBI; EOL
    ##  
    ##  Sources for occurrence data: gbif, bien
    ##      
    ##             Species Occurrences Sources
    ## 1 Protea cynaroides        1054      19
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

    ## iNaturalist.org (2019). iNaturalist Research-grade Observations. Occurrence dataset https://doi.org/10.15468/ab3s5x  Accessed via  GBIF  on  2019-07-15 .
    ## naturgucker.de. naturgucker. Occurrence dataset https://doi.org/10.15468/uc1apo  Accessed via  GBIF  on  2019-07-15 .
    ## Ranwashe F (2019). BODATSA: Botanical Collections. Version 1.4. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/2aki0q  Accessed via  GBIF  on  2019-07-15 .
    ## Cameron E, Auckland Museum A M (2019). Auckland Museum Botany Collection. Version 1.40. Auckland War Memorial Museum. Occurrence dataset https://doi.org/10.15468/mnjkvv  Accessed via  GBIF  on  2019-07-15 .
    ## Tela Botanica. Carnet en Ligne. Occurrence dataset https://doi.org/10.15468/rydcn2  Accessed via  GBIF  on  2019-07-15 .
    ## Senckenberg. African Plants - a photo guide. Occurrence dataset https://doi.org/10.15468/r9azth  Accessed via  GBIF  on  2019-07-15 .
    ## Magill B, Solomon J, Stimmel H (2019). Tropicos Specimen Data. Missouri Botanical Garden. Occurrence dataset https://doi.org/10.15468/hja69f  Accessed via  GBIF  on  2019-07-15 .
    ## Capers R (2014). CONN. University of Connecticut. Occurrence dataset https://doi.org/10.15468/w35jmd  Accessed via  GBIF  on  2019-07-15 .
    ## South African National Biodiversity Institute (2018). PRECIS. Occurrence dataset https://doi.org/10.15468/rckmn2  Accessed via  GBIF  on  2019-07-15 .
    ## MNHN - Museum national d'Histoire naturelle (2019). The vascular plants collection (P) at the Herbarium of the Muséum national d'Histoire Naturelle (MNHN - Paris). Version 69.137. Occurrence dataset https://doi.org/10.15468/nc6rxy  Accessed via  GBIF  on  2019-07-15 .
    ## Missouri Botanical Garden,Herbarium  Accessed via  BIEN  on  NA .
    ## NSW  Accessed via  BIEN  on  2018-08-14 .
    ## MNHN  Accessed via  BIEN  on  2018-08-14 .
    ## naturgucker  Accessed via  BIEN  on  2018-08-14 .
    ## FR  Accessed via  BIEN  on  2018-08-14 .
    ## http://www.tela-botanica.org  Accessed via  BIEN  on  2018-08-14 .
    ## iNaturalist  Accessed via  BIEN  on  2018-08-14 .
    ## SANBI  Accessed via  BIEN  on  2018-08-14 .
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
    ## 1 Protea cynaroides Protea cynaroides                      NCBI; EOL

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

    ##       gbifID              name longitude  latitude day month year Dataset
    ## 1 2273313855 Protea cynaroides  18.40540 -33.95891   4     1 2015        
    ## 2 2273260085 Protea cynaroides  18.42350 -33.96619  20     6 2019        
    ## 3 2273226338 Protea cynaroides  22.99340 -34.05478  16     6 2019        
    ## 4 2265902358 Protea cynaroides  18.40232 -34.08405   9     6 2019        
    ## 5 2265901204 Protea cynaroides  19.44807 -34.52123  13     6 2019        
    ## 6 2265862297 Protea cynaroides  18.39757 -34.07418   9     6 2019        
    ##                             DatasetKey DataService
    ## 1 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 2 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 3 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 4 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 5 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF
    ## 6 50c9509d-22c7-4a22-a47d-8c48425ef4a7        GBIF

``` r
#The full summary
summary(myOldOccCiteObject)
```

    ##  
    ##  OccCite query occurred on: 10 October, 2019
    ##  
    ##  User query type: User-supplied list of taxa.
    ##  
    ##  Sources for taxonomic rectification: NCBI, EOL
    ##      
    ##  
    ##  Taxonomic cleaning results:     
    ## 
    ##          Input Name        Best Match Taxonomic Databases w/ Matches
    ## 1 Protea cynaroides Protea cynaroides                      NCBI; EOL
    ##  
    ##  Sources for occurrence data: gbif, bien
    ##      
    ##             Species Occurrences Sources
    ## 1 Protea cynaroides        1054      19
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

    ## iNaturalist.org (2019). iNaturalist Research-grade Observations. Occurrence dataset https://doi.org/10.15468/ab3s5x Accessed via GBIF on 2019-07-15.
    ## naturgucker.de. naturgucker. Occurrence dataset https://doi.org/10.15468/uc1apo Accessed via GBIF on 2019-07-15.
    ## Ranwashe F (2019). BODATSA: Botanical Collections. Version 1.4. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/2aki0q Accessed via GBIF on 2019-07-15.
    ## Cameron E, Auckland Museum A M (2019). Auckland Museum Botany Collection. Version 1.40. Auckland War Memorial Museum. Occurrence dataset https://doi.org/10.15468/mnjkvv Accessed via GBIF on 2019-07-15.
    ## Tela Botanica. Carnet en Ligne. Occurrence dataset https://doi.org/10.15468/rydcn2 Accessed via GBIF on 2019-07-15.
    ## Senckenberg. African Plants - a photo guide. Occurrence dataset https://doi.org/10.15468/r9azth Accessed via GBIF on 2019-07-15.
    ## Magill B, Solomon J, Stimmel H (2019). Tropicos Specimen Data. Missouri Botanical Garden. Occurrence dataset https://doi.org/10.15468/hja69f Accessed via GBIF on 2019-07-15.
    ## Capers R (2014). CONN. University of Connecticut. Occurrence dataset https://doi.org/10.15468/w35jmd Accessed via GBIF on 2019-07-15.
    ## South African National Biodiversity Institute (2018). PRECIS. Occurrence dataset https://doi.org/10.15468/rckmn2 Accessed via GBIF on 2019-07-15.
    ## MNHN - Museum national d'Histoire naturelle (2019). The vascular plants collection (P) at the Herbarium of the Muséum national d'Histoire Naturelle (MNHN - Paris). Version 69.137. Occurrence dataset https://doi.org/10.15468/nc6rxy Accessed via GBIF on 2019-07-15.
    ## Missouri Botanical Garden,Herbarium Accessed via BIEN on NA.
    ## NSW Accessed via BIEN on 2018-08-14.
    ## MNHN Accessed via BIEN on 2018-08-14.
    ## naturgucker Accessed via BIEN on 2018-08-14.
    ## FR Accessed via BIEN on 2018-08-14.
    ## http://www.tela-botanica.org Accessed via BIEN on 2018-08-14.
    ## iNaturalist Accessed via BIEN on 2018-08-14.
    ## SANBI Accessed via BIEN on 2018-08-14.
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

``` r
# What does a multispecies query look like?
summary(myPhyOccCiteObject)
```

    ##  
    ##  OccCite query occurred on: 10 October, 2019
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

    ## Uchifune Y, Yamamoto H (2019). Asia-Pacific Dataset. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/vjeh1p  Accessed via  GBIF  on  2019-07-04 .
    ## The International Barcode of Life Consortium (2016). International Barcode of Life project (iBOL). Occurrence dataset https://doi.org/10.15468/inygc6  Accessed via  GBIF  on  2019-07-04 .
    ## iNaturalist.org (2019). iNaturalist Research-grade Observations. Occurrence dataset https://doi.org/10.15468/ab3s5x  Accessed via  GBIF  on  2019-07-04 .
    ## Raiva R, Viador R, Santana P (2019). Diversidade e ocorrência de peixes na Zambézia (2003-2016). National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/mrz36h  Accessed via  GBIF  on  2019-07-04 .
    ## European Nucleotide Archive (EMBL-EBI) (2019). Geographically tagged INSDC sequences. Occurrence dataset https://doi.org/10.15468/cndomv  Accessed via  GBIF  on  2019-07-04 .
    ## Pozo de la Tijera M D C, Comisión nacional para el conocimiento y uso de la biodiversidad C (2018). Fortalecimiento de las colecciones de ECOSUR. Primera fase. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/orx3mk  Accessed via  GBIF  on  2019-07-04 .
    ## Elías Gutiérrez M, Comisión nacional para el conocimiento y uso de la biodiversidad C (2018). Códigos de barras de la vida en peces y zooplancton de México. Version 1.5. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/xmbkgo  Accessed via  GBIF  on  2019-07-04 .
    ## Raiva R, Santana P (2019). Diversidade e ocorrência de peixes em Inhambane (2009-2017). Version 1.4. National Institute of Fisheries Research (IIP) – Mozambique. Occurrence dataset https://doi.org/10.15468/4fj2tq  Accessed via  GBIF  on  2019-07-04 .
    ## J. Barde N (2018). Programme Ecoscope: données d'observations des écosystèmes marins exploités (Réunion). UMS PatriNat (AFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/elttrd  Accessed via  GBIF  on  2019-07-04 .
    ## Shane G (2018). Pelagic fish food web linkages, Queensland, Australia (2003-2005). CSIRO Oceans and Atmosphere. Occurrence dataset https://doi.org/10.15468/yy5wdp  Accessed via  GBIF  on  2019-07-04 .
    ## Mackay K (2018). New Zealand research tagging database. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. Occurrence dataset https://doi.org/10.15468/i66xdm  Accessed via  GBIF  on  2019-07-04 .
    ## Sánchez González S, Comisión nacional para el conocimiento y uso de la biodiversidad C (2018). Taxonomía y sistemática de la Ictiofauna de la Bahía de Banderas del Estado de Nayarit, México. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/uhrwsl  Accessed via  GBIF  on  2019-07-04 .
    ## Museums Victoria (2018). Museums Victoria provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lp1ctu  Accessed via  GBIF  on  2019-07-04 .
    ## CSIRO Oceans and Atmosphere (2018). CSIRO, Rachel Cruises, Shark Data, Arafura Sea, North Australia, 1984. Version 6.1. Occurrence dataset https://doi.org/10.15468/yickr6  Accessed via  GBIF  on  2019-07-04 .
    ## Australian Museum (2018). Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/e7susi  Accessed via  GBIF  on  2019-07-04 .
    ## Museum and Art Gallery of the Northern Territory (2018). Northern Territory Museum and Art Gallery provider for OZCAM. Occurrence dataset https://doi.org/10.15468/giro3a  Accessed via  GBIF  on  2019-07-04 .
    ## Cauquil P, Barde J (2011). observe_tuna_bycatch_ecoscope. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/23m361  Accessed via  GBIF  on  2019-07-04 .
    ## Queensland Museum (2018). Queensland Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/lotsye  Accessed via  GBIF  on  2019-07-04 .
    ## Feeney R (2019). LACM Vertebrate Collection. Version 18.6. Natural History Museum of Los Angeles County. Occurrence dataset https://doi.org/10.15468/77rmwd  Accessed via  GBIF  on  2019-07-04 .
    ## Western Australian Museum (2019). Western Australian Museum provider for OZCAM. Occurrence dataset https://doi.org/10.15468/5qt0dm  Accessed via  GBIF  on  2019-07-04 .
    ## Robins R (2019). UF FLMNH Ichthyology. Version 117.228. Florida Museum of Natural History. Occurrence dataset https://doi.org/10.15468/8mjsel  Accessed via  GBIF  on  2019-07-04 .
    ## Barde J (2011). ecoscope_observation_database. IRD - Institute of Research for Development. Occurrence dataset https://doi.org/10.15468/dz1kk0  Accessed via  GBIF  on  2019-07-04 .
    ## Catania D, Fong J (2019). CAS Ichthyology (ICH). Version 150.193. California Academy of Sciences. Occurrence dataset https://doi.org/10.15468/efh2ib  Accessed via  GBIF  on  2019-07-04 .
    ## Vanreusel W, Gielen K, Van den Neucker T, Jooris R, Desmet P (2019). Waarnemingen.be - Fish occurrences in Flanders and the Brussels Capital Region, Belgium. Version 1.6. Natuurpunt. Occurrence dataset https://doi.org/10.15468/7reil0  Accessed via  GBIF  on  2019-07-04 .
    ## Orrell T (2019). NMNH Extant Specimen Records. Version 1.23. National Museum of Natural History, Smithsonian Institution. Occurrence dataset https://doi.org/10.15468/hnhrg3  Accessed via  GBIF  on  2019-07-04 .
    ## Millen B (2019). Ichthyology Collection - Royal Ontario Museum. Version 18.7. Royal Ontario Museum. Occurrence dataset https://doi.org/10.15468/syisbx  Accessed via  GBIF  on  2019-07-04 .
    ## Harvard University M, Morris P J (2019). Museum of Comparative Zoology, Harvard University. Version 162.174. Museum of Comparative Zoology, Harvard University. Occurrence dataset https://doi.org/10.15468/p5rupv  Accessed via  GBIF  on  2019-07-04 .
    ## Prestridge H (2019). Biodiversity Research and Teaching Collections - TCWC Vertebrates. Version 9.3. Texas A&M University Biodiversity Research and Teaching Collections. Occurrence dataset https://doi.org/10.15468/szomia  Accessed via  GBIF  on  2019-07-04 .
    ## Grant S, Swagel K (2019). Field Museum of Natural History (Zoology) Fish Collection. Version 13.11. Field Museum. Occurrence dataset https://doi.org/10.15468/alz7wu  Accessed via  GBIF  on  2019-07-04 .
    ## National Museum of Nature and Science, Japan (2019). Fish specimens of Kagoshima University Museum. Occurrence dataset https://doi.org/10.15468/vcj3j8  Accessed via  GBIF  on  2019-07-04 .
    ## González Acosta A F, Comisión nacional para el conocimiento y uso de la biodiversidad C (2018). Ampliación de la base de datos de la ictiofauna insular del Golfo de California. Version 1.5. Comisión nacional para el conocimiento y uso de la biodiversidad. Occurrence dataset https://doi.org/10.15468/p5ovq7  Accessed via  GBIF  on  2019-07-04 .
    ## University of Michigan Museum of Zoology (2019). University of Michigan Museum of Zoology, Division of Fishes. Version 1.16. Occurrence dataset https://doi.org/10.15468/8cxijb  Accessed via  GBIF  on  2019-07-04 .
    ## Frable B (2019). SIO Marine Vertebrate Collection. Version 1.6. Scripps Institution of Oceanography. Occurrence dataset https://doi.org/10.15468/ad1ovc  Accessed via  GBIF  on  2019-07-04 .
    ## J. Barde N (2018). Programme Ecoscope: données d'observations des écosystèmes marins exploités. UMS PatriNat (AFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/gdrknh  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Dry Tortugas Reef Visual Census 2012. Version 1.3. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/adis7b  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Dry Tortugas Reef Visual Census 1999. Version 1.3. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/g8q8ey  Accessed via  GBIF  on  2019-07-04 .
    ## Citizen Science - ALA Website (2019). ALA species sightings and OzAtlas. Occurrence dataset https://doi.org/10.15468/jayxmn  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 1994. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/rdkfyf  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 1996. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/gaekez  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 1995. Version 1.4. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/uzpt9m  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 1998. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/kfnaep  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 1999. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/dwxlan  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 1997. Version 1.3. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/419say  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2001. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/t0r3vt  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2000. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/1pyhh5  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2002. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/pcikkj  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2003. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/es1iso  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Dry Tortugas Reef Visual Census 2004. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/jlkkrw  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2004. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/nuqkih  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2005. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/zq1ep2  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Dry Tortugas Reef Visual Census 2006. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/rexjmu  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2006. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/dple14  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2007. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/dfyb57  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Dry Tortugas Reef Visual Census 2008. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/oomxex  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Dry Tortugas Reef Visual Census 2010. Version 1.4. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/7dnpl0  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2009. Version 1.1. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/tnn5ra  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2010. Version 1.3. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/6chrsz  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2008. Version 1.2. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/7zofww  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2012. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/vnvtmr  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Florida Keys Reef Visual Census 2011. Version 1.3. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/06aqle  Accessed via  GBIF  on  2019-07-04 .
    ## Ault J, Bohnsack J, Benson A (2017). Dry Tortugas Reef Visual Census 2014. Version 1.3. United States Geological Survey. Sampling event dataset https://doi.org/10.15468/nawlft  Accessed via  GBIF  on  2019-07-04 .
    ## Wimer M, Benson A (2016). USGS Patuxent Wildlife Research Center Seabirds Compendium. Version 1.1. United States Geological Survey. Occurrence dataset https://doi.org/10.15468/w2vk7x  Accessed via  GBIF  on  2019-07-04 .
    ## Commonwealth Scientific and Industrial Research Organisation (2018). CSIRO Ichthyology provider for OZCAM. Occurrence dataset https://doi.org/10.15468/azp1pf  Accessed via  GBIF  on  2019-07-04 .
    ## Dillman C (2018). CUMV Fish Collection. Version 28.16. Cornell University Museum of Vertebrates. Occurrence dataset https://doi.org/10.15468/jornbc  Accessed via  GBIF  on  2019-07-04 .
    ## Casassovici A, Brosens D (2019). Diveboard - Scuba diving citizen science observations. Version 54.17. Diveboard. Occurrence dataset https://doi.org/10.15468/tnjrgy  Accessed via  GBIF  on  2019-07-04 .
    ## Sidlauskas B (2017). Oregon State Ichthyology Collection. Oregon State University. Occurrence dataset https://doi.org/10.15468/b7htot  Accessed via  GBIF  on  2019-07-04 .
    ## Pugh W (2017). UAIC Ichthyological Collection. Version 3.2. University of Alabama Biodiversity and Systematics. Occurrence dataset https://doi.org/10.15468/a2laag  Accessed via  GBIF  on  2019-07-04 .
    ## Norton B (2019). NCSM Ichthyology Collection. Version 22.4. North Carolina State Museum of Natural Sciences. Occurrence dataset https://doi.org/10.15468/7et8cq  Accessed via  GBIF  on  2019-07-04 .
    ## Norén M, Shah M (2017). Fishbase. FishBase. Occurrence dataset https://doi.org/10.15468/wk3zk7  Accessed via  GBIF  on  2019-07-04 .
    ## Chiang W (2014). Taiwan Fisheries Research Institute – Digital archives of coastal and offshore specimens. TELDAP. Occurrence dataset https://doi.org/10.15468/xvxngy  Accessed via  GBIF  on  2019-07-04 .
    ## Shao K, Lin H (2014). The Fish Database of Taiwan. TELDAP. Occurrence dataset https://doi.org/10.15468/zavxg7  Accessed via  GBIF  on  2019-07-04 .
    ## Miya M (2019). Fish Collection of Natural History Museum and Institute, Chiba. National Museum of Nature and Science, Japan. Occurrence dataset https://doi.org/10.15468/p2eb5z  Accessed via  GBIF  on  2019-07-04 .
    ## Pyle R (2016). Bernice P. Bishop Museum. Version 8.1. Bernice Pauahi Bishop Museum. Occurrence dataset https://doi.org/10.15468/s6ctus  Accessed via  GBIF  on  2019-07-04 .
    ## Bentley A (2019). KUBI Ichthyology Collection. Version 17.56. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/mgjasg  Accessed via  GBIF  on  2019-07-04 .
    ## Bentley A (2019). KUBI Ichthyology Tissue Collection. Version 18.44. University of Kansas Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/jmsnwg  Accessed via  GBIF  on  2019-07-04 .
    ## Mackay K (2019). Marine biological observation data from coastal and offshore surveys around New Zealand. Version 1.7. The National Institute of Water and Atmospheric Research (NIWA). Occurrence dataset https://doi.org/10.15468/pzpgop  Accessed via  GBIF  on  2019-07-04 .
    ## Maslenikov K (2019). UWFC Ichthyology Collection. University of Washington Burke Museum. Occurrence dataset https://doi.org/10.15468/vvp7gr  Accessed via  GBIF  on  2019-07-04 .
    ## Machete M (2019). POPA- Fisheries Observer Program of the Azores: Accessory species caught in the Azores tuna fishery between 2000 and 2013. Version 1.1. Institute of Marine Research. Occurrence dataset https://doi.org/10.14284/211  Accessed via  GBIF  on  2019-07-04 .
    ## Machete M (2019). POPA- Fisheries Observer Program of the Azores: Discards in the Azores tuna fishery from 1998 to 2013. Version 1.1. Institute of Marine Research. Occurrence dataset https://doi.org/10.14284/20  Accessed via  GBIF  on  2019-07-04 .
    ## UMS PatriNat (AFB-CNRS-MNHN), Paris (2018). Données d'occurrences Espèces issues de l'inventaire des ZNIEFF. Occurrence dataset https://doi.org/10.15468/ikshke  Accessed via  GBIF  on  2019-07-04 .
    ## Emery P (2017). DFO Maritimes Region Cetacean Sightings. Canadian node of the Ocean Biogeographic Information System (OBIS Canada). Occurrence dataset https://doi.org/10.15468/2khlz1  Accessed via  GBIF  on  2019-07-04 .
    ## Natural History Museum (2019). Natural History Museum (London) Collection Specimens. Occurrence dataset https://doi.org/10.5519/0002965  Accessed via  GBIF  on  2019-07-04 .
    ## Pinheiro H (2017). Fish biodiversity of the Vitória-Trindade Seamount Chain, Southwestern Atlantic: an updated database. Version 2.11. Brazilian Marine Biodiversity Database. Occurrence dataset https://doi.org/10.15468/o5jdnr  Accessed via  GBIF  on  2019-07-04 .
    ## South Australian Museum (2018). South Australian Museum Australia provider for OZCAM. Occurrence dataset https://doi.org/10.15468/wz4rrh  Accessed via  GBIF  on  2019-07-04 .
    ## Ranz J (2017). Banco de Datos de la Biodiversidad de la Comunitat Valenciana. Biodiversity data bank of Generalitat Valenciana. Occurrence dataset https://doi.org/10.15468/b4yqdy  Accessed via  GBIF  on  2019-07-04 .
    ## Shah M, Ericson Y (2019). SLU Aqua Institute of Coastal Research Database for Coastal Fish - KUL. GBIF-Sweden. Occurrence dataset https://doi.org/10.15468/bp9w9y  Accessed via  GBIF  on  2019-07-04 .
    ## Creuwels J (2019). Naturalis Biodiversity Center (NL) - Pisces. Naturalis Biodiversity Center. Occurrence dataset https://doi.org/10.15468/evijly  Accessed via  GBIF  on  2019-07-04 .
    ## The Norwegian Biodiversity Information Centre ., Hoem S (2019). Norwegian Species Observation Service. Version 1.65. The Norwegian Biodiversity Information Centre (NBIC). Occurrence dataset https://doi.org/10.15468/zjbzel  Accessed via  GBIF  on  2019-07-04 .
    ## Institute for Agricultural and Fisheries Research; Bio-Environmental Research Group (2019). Zooplankton monitoring in the Belgian Part of the North Sea between 2009 and 2010. Version 1.1. Occurrence dataset https://doi.org/10.14284/55  Accessed via  GBIF  on  2019-07-04 .
    ## Flanders Marine Institute (2019). Trawl-survey data from the “expedition Hvar” in the Adriatic Sea (Mediterranean) collected in 1948-1949. Version 1.1. Occurrence dataset https://doi.org/10.14284/285  Accessed via  GBIF  on  2019-07-04 .
    ## Institute for Agricultural and Fisheries Research; Bio-Environmental Research Group (2019). Epibenthos and demersal fish monitoring data in function of wind energy development in the Belgian part of the North Sea. Version 1.1. Occurrence dataset https://doi.org/10.14284/53  Accessed via  GBIF  on  2019-07-04 .
    ## Institute for Agricultural and Fisheries Research; Bio-Environmental Research Group (2019). Epibenthos and demersal fish monitoring at long-term monitoring stations in the Belgian part of the North Sea. Version 1.1. Occurrence dataset https://doi.org/10.14284/54  Accessed via  GBIF  on  2019-07-04 .
    ## Institute for Agricultural and Fisheries Research; Bio-Environmental Research Group (2019). Epibenthos and demersal fish monitoring in function of dredge disposal monitoring in the Belgian part of the North Sea. Version 1.1. Occurrence dataset https://doi.org/10.14284/198  Accessed via  GBIF  on  2019-07-04 .
    ## Institute for Agricultural and Fisheries Research; Bio-Environmental Research Group (2019). Epibenthos and demersal fish monitoring in function of aggregate extraction in the Belgian part of the North Sea. Version 1.1. Occurrence dataset https://doi.org/10.14284/197  Accessed via  GBIF  on  2019-07-04 .
    ## Flanders Marine Institute (2019). Trawl survey data from the Jabuka Pit area (central-eastern Adriatic Sea, Mediterranean) collected between 1956 and 1971. Version 1.0. Occurrence dataset https://doi.org/10.14284/287  Accessed via  GBIF  on  2019-07-04 .
    ## Flanders Marine Institute (2019). Trawl-survey data in the central-eastern Adriatic Sea (Mediterranean) collected in 1957 and 1958. Version 1.1. Occurrence dataset https://doi.org/10.14284/286  Accessed via  GBIF  on  2019-07-04 .
    ## Gall L (2019). Vertebrate Zoology Division - Ichthyology, Yale Peabody Museum. Yale University Peabody Museum. Occurrence dataset https://doi.org/10.15468/mgyhok  Accessed via  GBIF  on  2019-07-04 .
    ## de Vries H (2018). Observation.org, Nature data from the Netherlands. Observation.org. Occurrence dataset https://doi.org/10.15468/5nilie  Accessed via  GBIF  on  2019-07-04 .
    ## The Wildlife Trusts (2018). Marine Data from The Wildlife Trusts (TWT) Dive Team; 2014-2017. Occurrence dataset https://doi.org/10.15468/aqr7zv  Accessed via  GBIF  on  2019-07-04 .
    ## Seasearch (2018). Seasearch Marine Surveys in England. Occurrence dataset https://doi.org/10.15468/kywx6m  Accessed via  GBIF  on  2019-07-04 .
    ## Pierre NOEL N (2018). Données naturalistes de Pierre NOEL (stage). UMS PatriNat (AFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/if4ism  Accessed via  GBIF  on  2019-07-04 .
    ## Riutort Jean-Jacques N (2018). Données naturalistes de Jean-Jacques RIUTORT. UMS PatriNat (AFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/97bvs0  Accessed via  GBIF  on  2019-07-04 .
    ## n/a N, Laurent Colombet N (2018). Données BioObs - Base pour l’Inventaire des Observations Subaquatiques de la FFESSM. UMS PatriNat (AFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/ldch7a  Accessed via  GBIF  on  2019-07-04 .
    ## Chic Giménez Ò, Lombarte Carrera A (2018). Colección de referencia de otolitos, Instituto de Ciencias del Mar-CSIC. Institute of Marine Sciences (ICM-CSIC). Occurrence dataset https://doi.org/10.15468/wdwxid  Accessed via  GBIF  on  2019-07-04 .
    ## Staatliche Naturwissenschaftliche Sammlungen Bayerns. The Pisces Collection at the Staatssammlung für Anthropologie und Paläoanatomie München. Occurrence dataset https://doi.org/10.15468/uxag7k  Accessed via  GBIF  on  2019-07-04 .
    ## Malzahn A M (2006). Larval fish at time series station Helgoland Roads, North Sea, in 2003. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.733539  Accessed via  GBIF  on  2019-07-04 .
    ## Malzahn A M (2006). Larval fish at time series station Helgoland Roads, North Sea, in 2004. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.733540  Accessed via  GBIF  on  2019-07-04 .
    ## Malzahn A M (2006). Larval fish at time series station Helgoland Roads, North Sea, in 2005. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.733541  Accessed via  GBIF  on  2019-07-04 .
    ## Schiphouwer M (2018). RAVON (NL) - Fish observations extracted from Redeke (1907). Reptile, Amphibian and Fish Conservation Netherlands (RAVON). Occurrence dataset https://doi.org/10.15468/edt24y  Accessed via  GBIF  on  2019-07-04 .
    ## naturgucker.de. naturgucker. Occurrence dataset https://doi.org/10.15468/uc1apo  Accessed via  GBIF  on  2019-07-04 .
    ## Hårsaker K, Daverdin M (2019). Fish collection NTNU University Museum. Version 1.354. NTNU University Museum. Occurrence dataset https://doi.org/10.15468/q909ac  Accessed via  GBIF  on  2019-07-04 .
    ## National Biodiversity Data Centre. Marine sites, habitats and species data collected during the BioMar survey of Ireland.. Occurrence dataset https://doi.org/10.15468/nwlt7a  Accessed via  GBIF  on  2019-07-04 .
    ## Van Guelpen L (2016). Atlantic Reference Centre Museum of Canadian Atlantic Organisms - Invertebrates and Fishes Data. Canadian node of the Ocean Biogeographic Information System (OBIS Canada). Occurrence dataset https://doi.org/10.15468/wsxvo6  Accessed via  GBIF  on  2019-07-04 .
    ## Shah M, Coulson S (2019). Artportalen (Swedish Species Observation System). Version 92.160. ArtDatabanken. Occurrence dataset https://doi.org/10.15468/kllkyl  Accessed via  GBIF  on  2019-07-04 .
    ## Olivas González F J (2018). Biological Reference Collections ICM CSIC. Version 1.23. Institute of Marine Sciences (ICM-CSIC). Occurrence dataset https://doi.org/10.15470/qlqqdx  Accessed via  GBIF  on  2019-07-04 .
    ## Environment Agency (2017). Environment Agency Rare and Protected Species Records. Occurrence dataset https://doi.org/10.15468/awfvnp  Accessed via  GBIF  on  2019-07-04 .
    ## Scottish Natural Heritage (2017). Species data for Scottish waters held and managed by Scottish Natural Heritage,  derived from benthic surveys 1993 to 2014. Occurrence dataset https://doi.org/10.15468/faxvgd  Accessed via  GBIF  on  2019-07-04 .
    ## Natural Resources Wales (2018). Marine Records from Pembrokeshire Marine Species Atlas. Occurrence dataset https://doi.org/10.15468/42yudm  Accessed via  GBIF  on  2019-07-04 .
    ## Merseyside BioBank (2018). Merseyside BioBank (unverified). Occurrence dataset https://doi.org/10.15468/iou2ld  Accessed via  GBIF  on  2019-07-04 .
    ## Marine Biological Association (2017). Verified Marine records from Indicia-based surveys. Occurrence dataset https://doi.org/10.15468/yfyeyg  Accessed via  GBIF  on  2019-07-04 .
    ## Marine Biological Association (2017). DASSH Data Archive Centre volunteer survey data. Occurrence dataset https://doi.org/10.15468/pjowth  Accessed via  GBIF  on  2019-07-04 .
    ## Joint Nature Conservation Committee (2018). Marine Nature Conservation Review (MNCR) and associated benthic marine data held and managed by JNCC. Occurrence dataset https://doi.org/10.15468/kcx3ca  Accessed via  GBIF  on  2019-07-04 .
    ## Kent & Medway Biological Records Centre (2017). Fish:  Records for Kent.. Occurrence dataset https://doi.org/10.15468/kd1utk  Accessed via  GBIF  on  2019-07-04 .
    ## Silva A S (2018). Ichthyological Collection of the Museu Oceanográfico D. Carlos I. Version 1.7. Aquário Vasco da Gama. Occurrence dataset https://doi.org/10.15468/dkxpqt  Accessed via  GBIF  on  2019-07-04 .
    ## Flanders Marine Institute (2019). Data collected during the expeditions of the e-learning projects Expedition Zeeleeuw and Planet Ocean. Version 1.1. Occurrence dataset https://doi.org/10.14284/4  Accessed via  GBIF  on  2019-07-04 .
    ## National Biodiversity Data Centre. Marine sites, habitats and species data collected during the BioMar survey of Ireland.. Occurrence dataset https://doi.org/10.15468/cr7gvs  Accessed via  GBIF  on  2019-07-04 .
    ## Atkinson L, Ranwashe F (2017). FBIP:SAEON: Historical Research Survey Database (1897-1949). Version 1.2. South African National Biodiversity Institute. Occurrence dataset https://doi.org/10.15468/sfwehq  Accessed via  GBIF  on  2019-07-04 .
    ## Edgar G J, Stuart-Smith R D (2016). Reef Life Survey: Global reef fish dataset. Version 2.1. Reef Life Survey. Sampling event dataset https://doi.org/10.15468/qjgwba  Accessed via  GBIF  on  2019-07-04 .
    ## Staatliche Naturwissenschaftliche Sammlungen Bayerns. The Fish Collection at the Zoologische Staatssammlung München. Occurrence dataset https://doi.org/10.15468/fzn9sv  Accessed via  GBIF  on  2019-07-04 .
    ## Coetzer W (2017). Occurrence records of southern African aquatic biodiversity. Version 1.10. The South African Institute for Aquatic Biodiversity. Occurrence dataset https://doi.org/10.15468/pv7vds  Accessed via  GBIF  on  2019-07-04 .
    ## Blindheim T (2019). BioFokus. Version 1.1171. BioFokus. Occurrence dataset https://doi.org/10.15468/jxbhqx  Accessed via  GBIF  on  2019-07-04 .
    ## Telenius A, Ekström J (2019). Lund Museum of Zoology (MZLU). GBIF-Sweden. Occurrence dataset https://doi.org/10.15468/mw39rb  Accessed via  GBIF  on  2019-07-04 .
    ## Breine J, Verreycken H, De Boeck T, Brosens D, Desmet P (2016). VIS - Fishes in estuarine waters in Flanders, Belgium. Version 9.4. Research Institute for Nature and Forest (INBO). Occurrence dataset https://doi.org/10.15468/estwpt  Accessed via  GBIF  on  2019-07-04 .
    ## Van der Veer H W, De Bruin T (2019). Royal Netherlands Institute for Sea Research (NIOZ) - Kom Fyke Mokbaai. Version 3.2. NIOZ Royal Netherlands Institute for Sea Research. Occurrence dataset https://doi.org/10.15468/ztbuho  Accessed via  GBIF  on  2019-07-04 .
    ## Quesada Lara J, Agulló Villaronga J (2019). Museu de Ciències Naturals de Barcelona: MCNB-Cord. Museu de Ciències Naturals de Barcelona. Occurrence dataset https://doi.org/10.15468/yta7zj  Accessed via  GBIF  on  2019-07-04 .
    ## van der Es H (2019). Natural History Museum Rotterdam (NL) - Chordata collection. Version 13.20. Natural History Museum Rotterdam. Occurrence dataset https://doi.org/10.15468/5rtmkg  Accessed via  GBIF  on  2019-07-04 .
    ## MNHN - Museum national d'Histoire naturelle (2019). The fishes collection (IC) of the Muséum national d'Histoire naturelle (MNHN - Paris). Version 57.134. Occurrence dataset https://doi.org/10.15468/tm7whu  Accessed via  GBIF  on  2019-07-04 .
    ## Prince P (2011). Abundance of benthic infauna in surface sediments from the North Sea sampled during cruise Dana00/5. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.756781  Accessed via  GBIF  on  2019-07-04 .
    ## Craeymeersch J A, Duineveld G C A (2011). Abundance of benthic infauna in surface sediments from the North Sea sampled during cruise Tridens00/5. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.756784  Accessed via  GBIF  on  2019-07-04 .
    ## Boon T, Zühlke R (2011). Abundance of benthic infauna in surface sediments from the North Sea sampled during cruise Cirolana00/5. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.756782  Accessed via  GBIF  on  2019-07-04 .
    ## Ehrich S, Kröncke I (2011). Abundance of benthic infauna in surface sediments from the North Sea sampled during Walther Herwig cruise WH220. PANGAEA - Publishing Network for Geoscientific and Environmental Data. Occurrence dataset https://doi.org/10.1594/pangaea.756783  Accessed via  GBIF  on  2019-07-04 .
    ## Senckenberg. Collection Pisces SMF. Occurrence dataset https://doi.org/10.15468/xaofbe  Accessed via  GBIF  on  2019-07-04 .
    ## Natural History Museum, University of Oslo (2019). Fish collection, Natural History Museum, University of Oslo. Version 1.178. Occurrence dataset https://doi.org/10.15468/4vqytb  Accessed via  GBIF  on  2019-07-04 .
    ## Mackay K (2019). Soviet Trawl Fishery Data (New Zealand Waters) 1964-1987. Version 1.5. Southwestern Pacific Ocean Biogeographic Information System (OBIS) Node. Occurrence dataset https://doi.org/10.15468/yqk5jg  Accessed via  GBIF  on  2019-07-04 .
    ## Menezes G (2019). Demersais survey in the Azores between 1996 and 2013. Version 1.1. Institute of Marine Research. Occurrence dataset https://doi.org/10.14284/22  Accessed via  GBIF  on  2019-07-04 .
    ## n/a N, VONG Lilita N, DIMEGLIO Tristan N (2018). Programme national de science participative sur la Biodiversité Littorale (BioLit). UMS PatriNat (AFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/xmv4ik  Accessed via  GBIF  on  2019-07-04 .
    ## n/a N (2018). Parc_National_des_Calanques_2017_12_18. UMS PatriNat (AFB-CNRS-MNHN), Paris. Occurrence dataset https://doi.org/10.15468/g0ds6l  Accessed via  GBIF  on  2019-07-04 .
    ## Khidas K, Shorthouse D (2019). Canadian Museum of Nature Fish Collection. Version 1.42. Canadian Museum of Nature. Occurrence dataset https://doi.org/10.15468/bm8amw  Accessed via  GBIF  on  2019-07-04 .
    ## Clark D, Hayden H, Fanning P, Smith S (2017). DFO Maritimes Research Vessel Trawl Surveys Fish Observations. Canadian node of the Ocean Biogeographic Information System (OBIS Canada). Occurrence dataset https://doi.org/10.15468/hlhopd  Accessed via  GBIF  on  2019-07-04 .
    ## Atlas of Life in the Coastal Wilderness (2018). Atlas of Life in the Coastal Wilderness - Sightings. Occurrence dataset https://doi.org/10.15468/rtxjkt  Accessed via  GBIF  on  2019-07-04 .
    ## South East Wales Biodiversity Records Centre (2018). SEWBReC Fish (South East Wales). Occurrence dataset https://doi.org/10.15468/htsfiy  Accessed via  GBIF  on  2019-07-04 .
    ## Mackay K (2018). New Zealand fish and squid distributions from research bottom trawls 1964-2008. Version 1.1. The National Institute of Water and Atmospheric Research (NIWA). Occurrence dataset https://doi.org/10.15468/ti5yah  Accessed via  GBIF  on  2019-07-04 .
    ## Kiki P, Ganglo J (2017). Census of the threatened species of Benin.. Version 1.5. GBIF Benin. Occurrence dataset https://doi.org/10.15468/fbbbfl  Accessed via  GBIF  on  2019-07-04 .
    ## Williams A (2018). CSIRO, Soviet Fishery Data, Australia, 1965-1978. Version 6.1. CSIRO Oceans and Atmosphere. Occurrence dataset https://doi.org/10.15468/ttcx7v  Accessed via  GBIF  on  2019-07-04 .
    ## European Molecular Biology Laboratory Australia (2018). European Molecular Biology Laboratory Australian Mirror. Occurrence dataset https://doi.org/10.15468/ypsvix  Accessed via  GBIF  on  2019-07-04 .
    ## National Biodiversity Data Centre. Rare marine fishes taken in Irish waters from 1786 to 2008. Occurrence dataset https://doi.org/10.15468/yvsxdp  Accessed via  GBIF  on  2019-07-04 .
    ## Fahy K (2016). SBMNH Vertebrate Zoology. Version 5.1. Santa Barbara Museum of Natural History. Occurrence dataset https://doi.org/10.15468/amfnkq  Accessed via  GBIF  on  2019-07-04 .
    ## Canadian node of the Ocean Biogeographic Information System (OBIS Canada). Canada Maritimes Regional Cetacean Sightings (OBIS Canada). Occurrence dataset https://doi.org/10.15468/orwtwi  Accessed via  GBIF  on  2019-07-04 .
