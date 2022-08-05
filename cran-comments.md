## Update
This is a package update. In this version, I have:

* Added "coordinateUncertaintyInMeters" column in processed occurrence results table.

## Test environments
* local OS X 10.15.7 install, R 4.1.2 (with and without internet connection)
* win-builder (devel and release)
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.1.3
* windows-latest (on GitHub Actions), R 4.1.3
* macOS-latest (on GitHub Actions), R 4.1.3
* Apple Silicon (M1), macOS 11.6 Big Sur, R-release (rhub), R 4.1.2
* Fedora Linux, R-devel, clang, gfortran (rhub)
* Ubuntu Linux 20.04.1 LTS, R-release, GCC (rhub)
* Windows Server 2022, R-devel, 64 bit (rhub)

## R CMD check results
0 errors | 0 warnings | 0 notes

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
