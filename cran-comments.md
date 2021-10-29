## Update
This is a package update. In this version, I have:

* Fix server connection-based ERRORs that led to the package's removal from CRAN.

## Test environments
* local OS X 10.15.7 install, R 4.0.2
* win-builder (devel and release)
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.1.0
* windows-latest (on GitHub Actions), R 4.1.0
* mac-latest (on GitHub Actions), R 4.1.0
* rhub

## R CMD check results
0 errors | 0 warnings | 1 note | 2 preperrors

* A NOTE occurred on Windows Server 2008 R2 SP1, R-devel, 32/64 bit on Rhub, and Ubuntu Linux 20.04.1 LTS, R-release, GCC on Rhub, and x86_64-w64-mingw32 (64-bit):

NOTE: Maintainer: 'Hannah L. Owens <hannah.owens@gmail.com>'
  
  New submission
  
  Package was archived on CRAN
  
  CRAN repository db overrides:
    X-CRAN-Comment: Archived on 2021-10-22 for policy violation.
  
    On Internet access: site has broken CA trust chain.

I have revised the package to fail gracefully in cases such as these.

* A PREPERROR occurred on Fedora Linux, R-devel, clang, gfortran on RHub:

ERROR : dependencies ‘BIEN’, ‘RPostgreSQL’ are not available for package ‘occCite’

This is not a problem with the package. These packages are available on CRAN.

* A PREPERROR occurred on Ubuntu Linux 20.04.1 LTS, R-release, GCC on RHub:

Failed with error: ‘there is no package called ‘shiny’’.

The package still built successfully.

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
