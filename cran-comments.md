## Update
This is a package update. In this version, I have:

* Adjustment to testing strategy to comply with CRAN policies.
* Updated metadata to reflect occCite joining ROpenSci.

## Test environments
* local OS X 10.15.7 install, R 4.1.2 (with and without internet connection)
* win-builder (devel and release)
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.1.3
* windows-latest (on GitHub Actions), R 4.1.3
* macOS-latest (on GitHub Actions), R 4.1.3
* rhub

## R CMD check results
0 errors | 0 warnings | 1 note

* A NOTE occurred on Windows Server 2008 R2 SP1, R-devel, 32/64 bit on Rhub, and x86_64-w64-mingw32 (64-bit):



The additional comment in Authors@R acknowledges reviewer contributions.

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
