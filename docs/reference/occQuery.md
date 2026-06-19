# Query from Taxon List

Takes rectified list of specimens from
[`studyTaxonList`](https://docs.ropensci.org/occCite/reference/studyTaxonList.md)
and returns point data from
[`rgbif`](https://docs.ropensci.org/rgbif/reference/rgbif-package.html)
with metadata.

## Usage

``` r
occQuery(
  x = NULL,
  datasources = c("gbif", "bien"),
  GBIFLogin = NULL,
  GBIFDownloadDirectory = NULL,
  loadLocalGBIFDownload = F,
  checkPreviousGBIFDownload = T,
  options = NULL
)
```

## Arguments

- x:

  An object of class
  [`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)
  (the results of a
  [`studyTaxonList`](https://docs.ropensci.org/occCite/reference/studyTaxonList.md)
  search) OR a vector with a list of species names. Note: If the latter,
  taxonomic rectification uses NCBI taxonomies. If you want more control
  than this, use
  [`studyTaxonList`](https://docs.ropensci.org/occCite/reference/studyTaxonList.md)
  to create a
  [`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)
  object first.

- datasources:

  A vector of occurrence data sources to search. This is currently
  limited to GBIF and BIEN, but may expand in the future.

- GBIFLogin:

  An object of class
  [`GBIFLogin`](https://docs.ropensci.org/occCite/reference/GBIFLogin-class.md)
  to log in to GBIF to begin the download.

- GBIFDownloadDirectory:

  An optional argument that specifies the local directory where GBIF
  downloads will be saved. If this is not specified, the downloads will
  be saved to your current working directory.

- loadLocalGBIFDownload:

  If `loadLocalGBIFDownload = T`, then occCite will load occurrences for
  the specified species that have been downloaded by the user and stored
  in the directory specified by `GBIFDownloadDirectory`.

- checkPreviousGBIFDownload:

  If `loadLocalGBIFDownload = T`, occCite will check for
  previously-prepared GBIF downloads on the user's GBIF account. Setting
  this option to \`TRUE\` can significantly speed up query time if the
  user has previously queried GBIF for the same taxa.

- options:

  A vector of options to pass to
  [`occ_download`](https://docs.ropensci.org/rgbif/reference/occ_download.html).

## Value

The object of class
[`occCiteData`](https://docs.ropensci.org/occCite/reference/occCiteData-class.md)
supplied by the user as an argument, with occurrence data search
results, as well as metadata on the occurrence sources queried.

## Details

If you are querying GBIF, note that \`occQuery()\` only returns records
from GBIF that have coordinates, aren't flagged as having geospatial
issues, and have an occurrence status flagged as "PRESENT".

## Examples

``` r
if (FALSE) { # \dontrun{
## If you have already created a occCite object, and have not previously
## downloaded GBIF data.
occQuery(
  x = myOccCiteObject,
  datasources = c("gbif", "bien"),
  GBIFLogin = myLogin,
  GBIFDownloadDirectory = "./Desktop",
  loadLocalGBIFDownload = F
)

## If you don't have an occCite object yet
occQuery(
  x = c("Buteo buteo", "Protea cynaroides"),
  datasources = c("gbif", "bien"),
  GBIFLogin = myLogin,
  GBIFDownloadDirectory = "./Desktop",
  loadLocalGBIFDownload = F
)

## If you have previously downloaded occurrence data from GBIF
## and saved it in a folder called "GBIFDownloads".
occQuery(
  x = c("Buteo buteo", "Protea cynaroides"),
  datasources = c("gbif", "bien"),
  GBIFLogin = myLogin,
  GBIFDownloadDirectory = "./Desktop/GBIFDownloads",
  loadLocalGBIFDownload = T
)
} # }
```
