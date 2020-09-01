## Test environments
* local OS X 10.15.5 install, R 4.0.2
* win-builder (devel and release)
* r-hub

## R CMD check results
There were no ERRORs or WARNINGs. 

There were 2 NOTEs.

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Hannah L. Owens <hannah.owens@gmail.com>'

This is correct, and an email that is permanent.

* checking dependencies in R code ... NOTE
  Unexported object imported by a ':::' call: 'BIEN:::.BIEN_sql'

BIEN:::.BIEN_sql is a function that was designed to be internal for the BIEN package, but is necessary in order for the occCite package to access the BIEN database.

## Downstream dependencies
I also ran tools::check_packages_in_dir check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
