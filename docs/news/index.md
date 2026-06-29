# Changelog

## occCite 0.6.2

- Bug fix to how `taxize` results are handled by
  `occCite::taxonomicRectification()`.
- Documentation now specifies how `taxize` results are handled more
  explicitly.
- Test files edited to ensure stability after above bug fix.
- Removed `waffle` from Suggests, made `waffle` utilization more
  optional.

## occCite 0.6.1

CRAN release: 2025-09-29

- Moved `waffle` to Suggested package, as it is now orphaned.
- [`plot.occCiteData()`](https://docs.ropensci.org/occCite/reference/plot.occCiteData.md)
  now automatically skips source and aggregator plots if `waffle` is
  unavailable.
- Small bug fixes.

## occCite 0.6.0

CRAN release: 2025-06-16

- Updated for compatibility with major `ggplot2` update;
  back-compatibility maintained.
- Restored `taxize` functionality as a Suggested package.
- Improved test coverage.

## occCite 0.5.9

CRAN release: 2024-10-28

- Commented out dependencies on `taxize` package. Taxonomic
  rectification no longer works. It will be reinstated if taxize becomes
  available on CRAN.

## occCite 0.5.8

CRAN release: 2024-09-05

- Moved `taxize` package to `Suggests`, as it is now orphaned.
- [`studyTaxonList()`](https://docs.ropensci.org/occCite/reference/studyTaxonList.md)
  allows user to skip taxonomic rectification, which relies on functions
  from `taxize` package.
  [`studyTaxonList()`](https://docs.ropensci.org/occCite/reference/studyTaxonList.md)
  automatically skips taxonomic rectification if `taxize` is
  unavailable.

## occCite 0.5.7

CRAN release: 2024-06-23

- Fixed warning in
  [`occCitation()`](https://docs.ropensci.org/occCite/reference/occCitation.md)
  when getting GBIF citations
- Updated date formatting using
  [`format()`](https://rdrr.io/r/base/format.html) instead of
  [`as.character()`](https://rdrr.io/r/base/character.html)
- Updated test files to incorporate rgbif 3.8.0 output changes, make
  more efficient
- In occResults, renamed “Dataset”, “DatasetKey”, and “DataService” to
  “datasetName”, “datasetKey”, “dataService”, respectively.
- Made an option for removing package citations

## occCite 0.5.6

CRAN release: 2022-08-05

- Added “coordinateUncertaintyInMeters” column in processed occurrence
  results table.

## occCite 0.5.5

- Further adjustment in testing to be CRAN-compatible

## occCite 0.5.4

CRAN release: 2022-03-21

- Adjustment to testing strategy to comply with CRAN policies.
- Links changed to reflect inclusion on ROpenSci.

## occCite 0.5.2

CRAN release: 2022-03-04

- Resubmission after archiving due to dependency archiving.
- Functions that rely on getting data from servers via an internet
  connection now behave more gracefully and informatively when the
  server cannot be reached.

## occCite 0.5.1

CRAN release: 2021-11-01

- Minor update to fix a server connection timeout error.

## occCite 0.5.0

CRAN release: 2021-10-13

- Legends for source waffle plots are now wrapped to enhance
  readability.
- Now fails more gracefully if servers cannot be reached.

## occCite 0.4.9

CRAN release: 2021-07-23

- In gbifRetriever, changed rgbif::name_suggests to
  rgbif::name_backbone. More robust for our purposes.
- Now fills in “Dataset” column in GBIF search results from GBIF
  citation information.
- No longer throws out GBIF occurrences with missing day and month
  information.

## occCite 0.4.8

CRAN release: 2021-06-11

- Fixed problem with occCitation that caused an error when dataset keys
  had no associated BIEN data.

## occCite 0.4.7

CRAN release: 2021-04-27

- Internal logic made more robust to various error scenarios.
- Now warns user if no taxonomic matches exist for a given name (but
  doesn’t crash!).

## occCite 0.4.6

CRAN release: 2021-02-21

- Taxonomic sources were renamed in the Global Names Resolver.

## occCite 0.4.5

CRAN release: 2020-11-28

- sumFig() function is now a `plot` method for objects of class
  `occCiteData`.
- `map.occCite()` has been renamed
  [`occCiteMap()`](https://docs.ropensci.org/occCite/reference/occCiteMap.md)
  to avoid confusion with existing method naming conventions.

## occCite 0.4.0

CRAN release: 2020-10-21

- Removed a package dependency that was causing warnings on some
  systems.
- Adjusted function behaviors to more gracefully handle species with no
  occurrences returned from a search.

## occCite 0.3.0

CRAN release: 2020-10-06

- Updated to meet CRAN reviewer guidelines
- Citations now include packages used.

## occCite 0.2.0

- Updated to reflect new object structures returned by searches with
  update `rgbif`, version 3.1.
- Examples updated to permit testing when possible.

## occCite 0.1.0

- Version submitted for evaluation in Ebbe Nielsen Challenge.

## occCite 0.0.0

- The package now works.
