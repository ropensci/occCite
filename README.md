
# occCite <img src='man/figures/logo.png' align="right" height="138" />

<!-- badges: start -->

[![R build
status](https://github.com/ropensci/occCite/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/occCite/actions)
[![cran
version](https://www.r-pkg.org/badges/version/occCite)](https://cran.r-project.org/package=occCite)
[![rstudio mirror
downloads](https://cranlogs.r-pkg.org/badges/occCite)](https://github.com/r-hub/cranlogs.app)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Codecov test
coverage](https://codecov.io/gh/ropensci/occCite/branch/main/graph/badge.svg)](https://codecov.io/gh/ropensci/occCite?branch=main)
[![ROpenSci
status](https://badges.ropensci.org/407_status.svg)](https://github.com/ropensci/software-review/issues/407)
[![DOI](https://zenodo.org/badge/151783900.svg)](https://zenodo.org/badge/latestdoi/151783900)

<!-- badges: end -->

## Summary

The `occCite` workflow follows a three-step process. First, the user
inputs one or more taxonomic names (or a phylogeny). `occCite` then
rectifies these names by checking them against one or more taxonomic
databases, which can be specified by the user (see the [Global Names
List](http://gni.globalnames.org/data_sources)). The results of the
taxonomic rectification are then kept in an `occCiteData` object in
local memory. Next, `occCite` takes the `occCiteData` object and
user-defined search parameters to query BIEN (through `rbien`) and/or
GBIF(through `rGBIF`) for records. The results are appended to the
`occCiteData` object, along with metadata on the search. Finally, the
user can pass the `occCiteData` object to `occCitation`, which compiles
citations for the primary providers, database aggregators, and `R`
packages used to build the dataset.

Please cite occCite. Run the following to get the appropriate citation
for the version you’re using:

``` r
citation(package = "occCite")
```

    ## 
    ## Owens H, Merow C, Maitner B, Kass J, Barve V, Guralnick R (2022).
    ## _occCite: Querying and Managing Large Biodiversity Occurrence
    ## Datasets_. doi: 10.5281/zenodo.632770 (URL:
    ## https://doi.org/10.5281/zenodo.632770), R package version 0.5.4,
    ## <URL: https://CRAN.R-project.org/package=occCite>.
    ## 
    ## A BibTeX entry for LaTeX users is
    ## 
    ##   @Manual{,
    ##     title = {occCite: Querying and Managing Large Biodiversity Occurrence Datasets},
    ##     author = {Hannah Owens and Cory Merow and Brian Maitner and Jamie Kass and Vijay Barve and Robert Guralnick},
    ##     year = {2022},
    ##     note = {R package version 0.5.4},
    ##     url = {https://CRAN.R-project.org/package=occCite},
    ##     doi = {10.5281/zenodo.632770},
    ##   }

## Installation:

``` r
install.packages("occCite")
```

Or, install via `r-universe`

``` r
install.packages("occCite", repos = "https://ropensci.r-universe.dev")
```

Or, install github development version:

``` r
devtools::install_github("ropensci/occCite")
```

After using one of these options, you can load the package into your environment using:

``` r
library("occCite")
```

## Getting Started

-   occCite introduction vignette
    (<https://ropensci.github.io/occCite/articles/a_Simple.html>)
-   occCite advanced feature vignette
    (<https://ropensci.github.io/occCite/articles/b_Advanced.html>)
-   Function reference
    <https://ropensci.github.io/occCite/reference/index.html>
-   YouTube tutorial
    (<https://www.youtube.com/watch?v=7qSCULN_VjY&t=17s>)
-   Software note in *Ecography* (<https://doi.org/10.1111/ecog.05618>)

## Meta

-   Please adhere to the [ROpenSci code of 
conduct](<https://ropensci.org/code-of-conduct/>).
-   Please [report any issues or 
bugs](<https://github.com/ropensci/occCite/issues>).
-   We encourage you to contribute to `occCite`! See the 
[contributor guide](<https://ropensci.github.io/occCite/CONTRIBUTING.html>) 
for more information.
-   License: GPL-3
-   Get citation information for `occCite` in R using
    `citation(package = 'occCite')`

------------------------------------------------------------------------
