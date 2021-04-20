## Update
This is a package update. In this version, I have:

* Made internal logic made more robust to various error scenarios.
* Written in warnings to user if no taxonomic matches exist for a given name
* If at least one search name has a valid taxonomic match, a search loop will not crash

## Test environments
* local OS X 10.15.7 install, R 4.0.2
* win-builder (devel and release)
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.0.5

## R CMD check results
0 errors | 0 warnings | 0 notes

## Downstream dependencies
I also ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
