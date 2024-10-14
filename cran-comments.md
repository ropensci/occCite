## Update
This is a package update. In this version, I have:

* Fix tests to be robust to suggested package `taxize` if not present.

## Test environments
* local OS X 14.6.1, R 4.4.1
* mac-latest (release), R 4.4.1
* win-builder (devel and release), R 4.4.1
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.4.1
* macOS-latest (on GitHub Actions), R 4.4.1

## R CMD check results
0 errors | 0 warnings | 1 notes

Note: Suggests orphaned package: ‘taxize’
- Use is conditional on presence of package. If `taxize` is absent, taxonomic rectification is skipped. This is noted in metadata and does not affect downstream processes.

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
