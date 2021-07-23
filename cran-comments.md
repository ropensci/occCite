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
1 error | 0 warnings | 0 notes | 1 preperror

* An ERROR occurred on Fedora Linux, R-devel, clang, gfortran on RHub:

ERROR: Bioconductor does not yet build and check packages for R version 4.2; see https://bioconductor.org/install.

This appears to be a setup error, not a problem with occCite, so I am unsure how to proceed.

* A PREPERROR occurred on Ubuntu Linux 20.04.1 LTS, R-release, GCC on RHub:

Error: No such container: occCite_0.4.9.tar.gz-cdaf7baecae8454a9f6c7a13314760e6-3

Build result was still SUCCESS.

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
