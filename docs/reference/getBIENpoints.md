# Download occurrence points from BIEN

Downloads occurrence points and useful related information for
processing within other occCite functions

## Usage

``` r
getBIENpoints(taxon)
```

## Arguments

- taxon:

  A single plant species or vector of plant species

## Value

A list containing

1.  a data frame of occurrence data;

2.  a list containing: i notes on usage, ii bibtex citations, and iii
    acknowledgment information;

3.  a data frame containing the raw results of a query to
    \`BIEN::BIEN_occurrence_species()\`.

## Details

\`getBIENpoints\` only returns all BIEN records, including non- native
and cultivated occurrences.

## Examples

``` r
if (FALSE) { # \dontrun{
getBIENpoints(taxon = "Protea cynaroides")
} # }
```
