## Update
This is a package update. In this version, I have:

* Made internal logic made more robust to various error scenarios.
* Written in warnings to user if no taxonomic matches exist for a given name
* If at least one search name has a valid taxonomic match, a search loop will not crash

## Test environments
* local OS X 10.15.7 install, R 4.0.2
* win-builder (devel and release)
* ubuntu 20.04 (devel and release; on GitHub Actions), R 4.0.5
* rhub

## R CMD check results
0 errors | 0 warnings | 1 note | 2 preperrors

* A NOTE occurred on x86_64-pc-linux-gnu (64-bit):

Examples with CPU (user + system) or elapsed time > 5s
                user system elapsed
studyTaxonList 0.523  0.046   7.083

studyTaxonList() example requires an API response. It is generally complete in < 5s, but this is somewhat dependent on connection and traffic.

* A PREPERROR failure occurred when using rhub to check the Fedora Linux, R-devel, clang, gfortran platform. The message reads: "Error: Bioconductor version '3.13' requires R version '4.1'; R version is too new;". Bioconductor is not a downstream dependency of occCite, so I am unsure how to proceed.
* A PREPERROR was also signaled for the rhub checks of the Ubuntu Linux 20.04.1 LTS, R-release, GCC platform, but the checks still completed successfully with no errors, warnings, or notes.

## CRAN reviewer comments addressed

* LICENSE file deleted

## Downstream dependencies
I ran tools::check_packages_in_dir() check on downstream dependencies of 
occCite. 

All packages that I could install passed with no ERRORs or WARNINGs.
