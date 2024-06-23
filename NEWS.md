# occCite 0.5.7

* Fixed warning in `occCitation()` when getting GBIF citations
* Updated date formatting using `format()` instead of `as.character()`
* Updated test files to incorporate rgbif 3.8.0 output changes, make more efficient
* In occResults, renamed "Dataset", "DatasetKey", and "DataService" to "datasetName", "datasetKey", "dataService", respectively.
* Made an option for removing package citations

# occCite 0.5.6

* Added "coordinateUncertaintyInMeters" column in processed occurrence results table.

# occCite 0.5.5

* Further adjustment in testing to be CRAN-compatible

# occCite 0.5.4

* Adjustment to testing strategy to comply with CRAN policies.
* Links changed to reflect inclusion on ROpenSci.

# occCite 0.5.2

* Resubmission after archiving due to dependency archiving.
* Functions that rely on getting data from servers via an internet connection now behave more gracefully and informatively when the server cannot be reached.

# occCite 0.5.1

* Minor update to fix a server connection timeout error.

# occCite 0.5.0

* Legends for source waffle plots are now wrapped to enhance readability.
* Now fails more gracefully if servers cannot be reached.

# occCite 0.4.9

* In gbifRetriever, changed rgbif::name_suggests to rgbif::name_backbone. More robust for our purposes.
* Now fills in "Dataset" column in GBIF search results from GBIF citation information.
* No longer throws out GBIF occurrences with missing day and month information.

# occCite 0.4.8

* Fixed problem with occCitation that caused an error when dataset keys had no associated BIEN data.

# occCite 0.4.7

* Internal logic made more robust to various error scenarios.
* Now warns user if no taxonomic matches exist for a given name (but doesn't crash!).

# occCite 0.4.6

* Taxonomic sources were renamed in the Global Names Resolver.

# occCite 0.4.5

* sumFig() function is now a `plot` method for objects of class `occCiteData`.
* `map.occCite()` has been renamed `occCiteMap()` to avoid confusion with existing method naming conventions.

# occCite 0.4.0

* Removed a package dependency that was causing warnings on some systems.
* Adjusted function behaviors to more gracefully handle species with no occurrences returned from a search.

# occCite 0.3.0

* Updated to meet CRAN reviewer guidelines
* Citations now include packages used.

# occCite 0.2.0

* Updated to reflect new object structures returned by searches with update `rgbif`, version 3.1.
* Examples updated to permit testing when possible.

# occCite 0.1.0

* Version submitted for evaluation in Ebbe Nielsen Challenge.

# occCite 0.0.0

* The package now works.
