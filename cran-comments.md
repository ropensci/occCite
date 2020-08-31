## Test environments
* local OS X 10.15.5 install, R 4.0.2
* win-builder (devel and release)
* r-hub

## R CMD check results
There were no ERRORs or WARNINGs. 

There was 1 NOTE.

* checking dependencies in R code ... NOTE
  Unexported object imported by a ':::' call: 'BIEN:::.BIEN_sql'

This is an object that was designed to be internal for the BIEN package, but was necessary for occCite to access the database.

## Downstream dependencies
I also ran tools::check_packages_in_dir check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
