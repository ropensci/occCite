## Update
This is a package update. In this version, I have:

* Reinstated functionality using the `taxize` package, making it version specific.
* Updated plotting functions and tests to be robust to impending `ggplot2` update.

## Test environments
* local OS X 15.5, R 4.4.1
* windows-latest (release; on GitHub Actions), R 4.5.1
* macOS-latest (release; on GitHub Actions), R 4.5.1
* Ubuntu 24.04.2 (devel; on GitHub Actions), R Under development (unstable)
* Ubuntu 24.04.2 (release; on GitHub Actions), R 4.5.1
* Ubuntu 24.04.2 (old-rel-1; on GitHub Actions), R 4.4.3

## R CMD check results
0 errors | 0 warnings | 0 notes

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
