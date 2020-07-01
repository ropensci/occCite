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

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon Protea
    ## cynaroides could not be resolved.

Here is what the GBIF results look like:

``` r
# GBIF search results
head(mySimpleOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);
```

    ## NULL

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
    ##  OccCite query occurred on: 01 July, 2020
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
    ## 1 Protea cynaroides         148       5

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

    ## Error in strsplit(x@occResults[[1]]$GBIF$Metadata$modified, "T"): non-character argument

Here is a simple way of generating a formatted citation document from
the results of `occCitation()`.

``` r
cat(paste(mySimpleOccCitations$Citation, 
          " Accessed via ", mySimpleOccCitations$occSearch, 
          " on ", mySimpleOccCitations$`Accession Date`, "."), 
    sep = "\n");
```

    ## Error in paste(mySimpleOccCitations$Citation, " Accessed via ", mySimpleOccCitations$occSearch, : object 'mySimpleOccCitations' not found

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

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon Protea
    ## cynaroides could not be resolved.

Here is the result. Look familiar?

``` r
#GBIF search results
head(myOldOccCiteObject@occResults$`Protea cynaroides`$GBIF$OccurrenceTable);
```

    ## NULL

``` r
#The full summary
summary(myOldOccCiteObject)
```

    ##  
    ##  OccCite query occurred on: 01 July, 2020
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
    ## 1 Protea cynaroides         148       5

Getting citation data works the exact same way with
previously-downloaded data as it does from a fresh dataset.

``` r
#Get citations
myOldOccCitations <- occCitation(myOldOccCiteObject);
```

    ## Error in strsplit(x@occResults[[1]]$GBIF$Metadata$modified, "T"): non-character argument

``` r
cat(paste0(mySimpleOccCitations$Citation, " Accessed via ", mySimpleOccCitations$occSearch, " on ", mySimpleOccCitations$`Accession Date`, "."), sep = "\n");
```

    ## Error in paste0(mySimpleOccCitations$Citation, " Accessed via ", mySimpleOccCitations$occSearch, : object 'mySimpleOccCitations' not found

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

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon
    ## Istiompax indica could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon
    ## Istiophorus albicans could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon
    ## Istiophorus platypterus could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon Kajikia
    ## albida could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon Kajikia
    ## audax could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon Makaira
    ## nigricans could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon
    ## Tetrapturus angustirostris could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon
    ## Tetrapturus belone could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon
    ## Tetrapturus georgii could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon
    ## Tetrapturus pfluegeri could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon
    ## Trachurus trachurus could not be resolved.

    ## Warning in gbifRetriever(GBIFDownloadDirectory, searchTaxa[[i]]): Taxon Xiphias
    ## gladius could not be resolved.

``` r
# What does a multispecies query look like?
summary(myPhyOccCiteObject)
```

    ##  
    ##  OccCite query occurred on: 01 July, 2020
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
    ## 1            Istiompax indica           0       0
    ## 2        Istiophorus albicans           0       0
    ## 3     Istiophorus platypterus           0       0
    ## 4              Kajikia albida           0       0
    ## 5               Kajikia audax           0       0
    ## 6           Makaira nigricans           0       0
    ## 7  Tetrapturus angustirostris           0       0
    ## 8          Tetrapturus belone           0       0
    ## 9         Tetrapturus georgii           0       0
    ## 10      Tetrapturus pfluegeri           0       0
    ## 11        Trachurus trachurus           0       0
    ## 12            Xiphias gladius           0       0

``` r
#Get citations
myPhyOccCitations <- occCitation(myPhyOccCiteObject);
```

    ## Error in strsplit(x@occResults[[1]]$GBIF$Metadata$modified, "T"): non-character argument

``` r
#Print citations as text with accession dates.
cat(paste(myPhyOccCitations$Citation, 
           " Accessed via ", myPhyOccCitations$occSearch, 
           " on ", myPhyOccCitations$`Accession Date`, "."), sep = "\n");
```

    ## Error in paste(myPhyOccCitations$Citation, " Accessed via ", myPhyOccCitations$occSearch, : object 'myPhyOccCitations' not found

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

    ## Error: Aesthetics must be valid data columns. Problematic aesthetic(s): x = year. 
    ## Did you mistype the name of a data column or forget to add after_stat()?

We can also generate plots for each species in the `occCiteData` object
individually. Since GBIF is the only aggregator we used for the query,
I’ll skip generating the aggregator plot.

``` r
sumFig.occCite(myPhyOccCiteObject, 
               bySpecies = T, 
               plotTypes = c("yearHistogram", "source"))
```

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
