## Update
This is a package update. In this version, I have:

* Removed a package dependency that was causing warnings on some systems.
* Adjusted function behaviors to more gracefully handle species with no occurrences returned from a search.

## Test environments
* local OS X 10.15.5 install, R 4.0.2
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
