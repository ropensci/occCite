## Update
This is a package update. In this version, I have:

* Moved `taxize` package to `Suggests`, as it is now orphaned.
* `studyTaxonList()` allows user to skip taxonomic rectification, which relies on functions from `taxize` package. `studyTaxonList()` automatically skips taxonomic rectification if `taxize` is unavailable.

## Test environments
* local OS X 14.5 install, R 4.3.2 (with and without internet connection)
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.4.1
* windows-latest (on GitHub Actions), R 4.4.1
* macOS-latest (on GitHub Actions), R 4.4.1

## R CMD check results
0 errors | 0 warnings | 1 notes

Note: Suggests orphaned package: ‘taxize’
- Use is conditional on presence of package. If taxize is absent, taxonomic rectification is skipped. This is noted in metadata and does not affect downstream processes.

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
