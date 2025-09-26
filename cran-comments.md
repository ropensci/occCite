## Update
This is a package update. In this version, I have:

* Updated for compatibility with major `ggplot2` update; back-compatibility maintained.
* Restored `taxize` functionality as a Suggested package.
* Improved test coverage.
* Moved `waffle` to Suggested package, as it is now orphaned.
* `plot.occCiteData()` now automatically skips source and aggregator plots if `waffle` is unavailable.
* Small bug fixes.

## Test environments
* local OS X 15.6.1, R 4.4.1
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
