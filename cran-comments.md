## Update
This is a package update. In this version, I have:

* Adjustment to testing strategy to comply with CRAN policies.

## Test environments
* local OS X 10.15.7 install, R 4.1.2 (with and without internet connection)
* win-builder (devel and release)
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.1.0
* windows-latest (on GitHub Actions), R 4.1.0
* macOS-latest (on GitHub Actions), R 4.1.0
* rhub

## R CMD check results
0 errors | 0 warnings | 1 note

* A NOTE occurred on Windows Server 2008 R2 SP1, R-devel, 32/64 bit on Rhub, and x86_64-w64-mingw32 (64-bit):

NOTE: Maintainer: 'Hannah L. Owens <hannah.owens@gmail.com>'
  
  New submission
  
  Package was archived on CRAN
  
  CRAN repository db overrides:
    X-CRAN-Comment: Archived on 2021-10-22 for policy violation.
  
    On Internet access: site has broken CA trust chain.

I have revised the package to fail gracefully in cases such as these.

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
