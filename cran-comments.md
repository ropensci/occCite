## Test environments
* local OS X 10.15.5 install, R 4.0.2
* win-builder (devel and release)
* r-hub

## R CMD check results
There were no ERRORs or WARNINGs. 

There were 2 NOTEs.

* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Hannah L. Owens <hannah.owens@gmail.com>'

This is accurate, and a permanent email address.

* checking for future file timestamps ... NOTE
  unable to verify current time
  
This appears to be a check function issue and only results from running checks using Mac OS X 10.5.5 install.

## Downstream dependencies
I also ran tools::check_packages_in_dir check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
