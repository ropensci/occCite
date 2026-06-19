# Download occurrences from GBIF

Downloads GBIF occurrence points and useful related information for
processing within other occCite functions

## Usage

``` r
getGBIFpoints(
  taxon,
  GBIFLogin = GBIFLogin,
  GBIFDownloadDirectory = NULL,
  checkPreviousGBIFDownload = T
)
```

## Arguments

- taxon:

  A string with a single species name

- GBIFLogin:

  An object of class
  [`GBIFLogin`](https://docs.ropensci.org/occCite/reference/GBIFLogin-class.md)
  to log in to GBIF to begin the download.

- GBIFDownloadDirectory:

  An optional argument that specifies the local directory where GBIF
  downloads will be saved. If this is not specified, the downloads will
  be saved to your current working directory.

- checkPreviousGBIFDownload:

  A logical operator specifying whether the user wishes to check their
  existing prepared downloads on the GBIF website.

## Value

A list containing

1.  a data frame of occurrence data;

2.  GBIF search metadata;

3.  a data frame containing the raw results of a query to
    \`rgbif::occ_download_get()\`.

## Details

\`getGBIFpoints\` only returns records from GBIF that have coordinates,
aren't flagged as having geospatial issues, and have an occurrence
status flagged as "PRESENT".

## Examples

``` r
if (FALSE) { # \dontrun{
getGBIFpoints(
  taxon = "Gadus morhua",
  GBIFLogin = myGBIFLogin,
  GBIFDownloadDirectory = NULL
)
} # }
```
