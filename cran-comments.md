## Update
This is a package update. In this version, I have:

* Updated `taxonRectification()` to catch user-supplied full titles from the GNA and convert to short titles (leftover problem from major `taxize` update).
* Updated example data downloads and GBIF-related functions to encompass new alphanumeric `rgbif` taxon keys in impeding update. These fixes are not breaking changes for packages that depend on occCite.

## Test environments
* local macOS X 26.3.1, R 4.5.2
* windows-latest (release; on GitHub Actions), R 4.6.0
* macOS-latest (release; on GitHub Actions), R 4.6.0
* Ubuntu 24.04.4 (devel; on GitHub Actions), R Under development (unstable)
* Ubuntu 24.04.4 (release; on GitHub Actions), R 4.6.0
* Ubuntu 24.04.4 (old-rel-1; on GitHub Actions), R 4.5.3

## R CMD check results
0 errors | 0 warnings | 0 notes

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
