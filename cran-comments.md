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
0 errors | 0 warnings | 2 notes | 1 preperror

* A NOTE occurred on win-builder devel:

R Under development (unstable) (2021-06-07 r80458)

* A NOTE occurred on win-builder release and windows-latest on GitHub Actions:
  
Version contains large components (0.4.8)

"Very large components" are necessary for checks, testthat, and vignettes to run in reasonable time.

* A PREPERROR failure occurred when using rhub to check the Windows Server 2008 R2 SP1, R-devel, 32/64 bit and Fedora Linux, R-devel, clang, gfortran platforms. The message reads: "Error: Bioconductor does not yet build and check packages for R version 4.2; see https://bioconductor.org/install". Bioconductor is not a downstream dependency of occCite, so I am unsure how to proceed.

* A PREPERROR was signaled when using rhub to check the Ubuntu Linux 20.04.1 LTS, R-release, GCCv platform, but the check still ran successfully.

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
