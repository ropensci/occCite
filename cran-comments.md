## Update
This is a package update. In this version, I have:

* In gbifRetriever, changed rgbif::name_suggests to rgbif::name_backbone. More robust for our purposes.
* Now fills in "Dataset" column in GBIF search results from GBIF citation information.
* No longer throws out GBIF occurrences with missing day and month information.

## Test environments
* local OS X 10.15.7 install, R 4.0.2
* win-builder (devel and release)
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.1.0
* windows-latest (on GitHub Actions), R 4.1.0
* mac-latest (on GitHub Actions), R 4.1.0
* rhub

## R CMD check results
2 errors | 0 warnings | 0 notes | 1 preperror

* A NOTE occurred on ubuntu-20.04 (devel) on Github Actions:

ERROR: dependencies ‘BIEN’, ‘taxize’, ‘RPostgreSQL’ are not available for package ‘occCite’

I have verified these packages are available on CRAN.

* An ERROR occurred on Fedora Linux, R-devel, clang, gfortran on RHub:

ERROR: Bioconductor does not yet build and check packages for R version 4.2; see https://bioconductor.org/install.

This appears to be a setup error, not a problem with occCite, so I am unsure how to proceed.

* A PREPERROR occurred on Ubuntu Linux 20.04.1 LTS, R-release, GCC on RHub:

Checking re-building of vignette outputs ...Build timed out (after 20 minutes). Marking the build as failed. Build was aborted.

This appears to be a setup error, not a problem with occCite, so I am unsure how to proceed.

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
