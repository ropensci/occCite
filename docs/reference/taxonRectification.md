# Taxon Rectification

An function that takes an input taxonomic name, checks against taxonomic
database, returns vector for use in database queries, as well as
warnings if the name is invalid.

## Usage

``` r
taxonRectification(taxName = NULL, datasources = NULL, skipTaxize = FALSE)
```

## Arguments

- taxName:

  A string that, ideally, is a taxonomic name

- datasources:

  A vector of taxonomic data sources implemented in
  [`taxize::gna_verifier()`](https://docs.ropensci.org/taxize/reference/gna_verifier.html).
  See the [Global Names
  Verifier](http://verifier.globalnames.org/data_sources) for more
  information.

- skipTaxize:

  If `skipTaxize = TRUE`, occCite will skip taxonomic rectification
  using taxize. Setting this option to \`TRUE\` will result in a check
  for the `taxize` package before taxonomic rectification is attempted.
  The name returned corresponds to the \`matchedCanonicalSimple\`, with
  no author or date.

## Value

A string with the closest match according to
[`taxize::gna_verifier()`](https://docs.ropensci.org/taxize/reference/gna_verifier.html),
and a list of taxonomic data sources that contain the matching name.

## Examples

``` r
# Inputting taxonomic name and specifying what taxonomic sources to search
taxonRectification(
  taxName = "Buteo buteo hartedi",
  datasources = "National Center for Biotechnology Information",
  skipTaxize = TRUE
)
#>            Input Name          Best Match
#> 1 Buteo buteo hartedi Buteo buteo hartedi
#>   Searched Taxonomic Databases w/ Matches
#> 1                          Not rectified.
```
