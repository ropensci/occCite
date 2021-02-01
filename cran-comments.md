## Update
This is a package update. In this version, I have:

* Changed the names of taxonomic resources in examples, tests, and vignettes to reflect changes made in the Global Names Resolver.

## Test environments
* local OS X 10.15.7 install, R 4.0.2
* win-builder (devel and release)
* r-hub

## R CMD check results
There were no WARNINGs. 

There was 1 NOTE when using r-hub and local OS X.

* checking dependencies in R code ... NOTE
  almost never needs to use ::: for its own objects:
There are ::: calls to the package's namespace in its code. A package
     almost never needs to use ::: for its own objects:
     ‘GBIFtableCleanup’ ‘tabGBIF’
     
These internal functions are used by several package functions, and it was not feasible from an organizational perspective to put the helper functions in the same file as all the functions that use them.
  
There was 1 NOTE when using r-hub.

* checking examples ... NOTE
Examples with CPU (user + system) or elapsed time > 5s
studyTaxonList 0.95   0.14    5.28
               user system elapsed
               
This example uses an API. Usually it is faster than 5s.

## Downstream dependencies
I also ran tools::check_packages_in_dir check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
