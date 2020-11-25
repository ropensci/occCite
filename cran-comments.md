## Update
This is a package update. In this version, I have:

* Renamed several functions to be more in line with naming conventions for methods.
* Custom plot method defined for `occCiteData` class.

## Test environments
* local OS X 10.15.7 install, R 4.0.2
* win-builder (devel and release)
* r-hub

## R CMD check results
There were no WARNINGs or NOTEs. 

There was 1 ERROR when using r-hub.

* checking examples with --run-donttest ... ERROR
  Running examples in 'occCite-Ex.R' failed

This example should not be tested, as it requires confidential user information to proceed.

## Downstream dependencies
I also ran tools::check_packages_in_dir check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
