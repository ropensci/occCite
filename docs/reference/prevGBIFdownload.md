# Download previously-prepared GBIF data sets

Searches the list of a user's most recent 1000 downloads on the GBIF
servers and returns the data set key for the most recently prepared
download.

## Usage

``` r
prevGBIFdownload(taxonKey, GBIFLogin)
```

## Arguments

- taxonKey:

  A taxon key as returned from \`rgbif::name_suggest()\`.

- GBIFLogin:

  An object of class
  [`GBIFLogin`](https://docs.ropensci.org/occCite/reference/GBIFLogin-class.md)
  to log in to GBIF to begin the download.

## Value

A GBIF download key, if one is available

## Examples

``` r
if (FALSE) { # \dontrun{
GBIFLogin <- GBIFLoginManager(
  user = "theWoman",
  email = "ireneAdler@laScala.org",
  pwd = "sh3r"
)
taxKey <- rgbif::name_suggest(
  q = "Protea cynaroides",
  rank = "species"
)$key[1]
prevGBIFdownload(
  taxonKey = taxKey,
  GBIFLogin = myGBIFLogin
)
} # }
```
