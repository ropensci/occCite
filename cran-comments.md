## Update
This is a package update. In this version, I have:

* Changed the names of taxonomic resources in examples, tests, and vignettes to reflect changes made in the Global Names Resolver.

## Test environments
* local OS X 10.15.7 install, R 4.0.2
* win-builder (devel and release)
* r-hub

## R CMD check results
There were no ERRORs or WARNINGs. 

There was 1 NOTE when using r-hub.

* checking examples ... NOTE
Examples with CPU (user + system) or elapsed time > 5s
                  user system elapsed
   studyTaxonList  0.8   0.08     5.1
               
This example uses an API. Usually it is faster than 5s.

## Downstream dependencies
I also ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
