## Update
This is a package update. In this version, I have:

* Fixed warning in `occCitation()` when getting GBIF citations
* Updated date formatting using `format()` instead of `as.character()`
* Updated test files to incorporate rgbif 3.8.0 output changes, make more efficient
* In occResults, renamed "Dataset", "DatasetKey", and "DataService" to "datasetName", "datasetKey", "dataService", respectively.

## Test environments
* local OS X 14.5 install, R 4.3.2 (with and without internet connection)
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.4.1
* windows-latest (on GitHub Actions), R 4.4.1
* macOS-latest (on GitHub Actions), R 4.4.1

## R CMD check results
0 errors | 0 warnings | 0 notes

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
