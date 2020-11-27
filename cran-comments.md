## Update
This is a package update. In this version, I have:

* Renamed several functions to be more in line with naming conventions for methods.
* Custom plot method defined for `occCiteData` class.

## Test environments
* local OS X 10.15.7 install, R 4.0.2
* win-builder (devel and release)
* r-hub

## R CMD check results
There were no WARNINGs. 

There was 1 NOTE when using r-hub, win-builder devel, and win-builder release.

* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Hannah L. Owens <hannah.owens@gmail.com>'
New submission


Package was archived on CRAN

CRAN repository db overrides:
  X-CRAN-Comment: Archived on 2020-11-04 as check problems were not
    corrected in time.
    
The check problems were corrected.

## Downstream dependencies
I also ran tools::check_packages_in_dir check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
