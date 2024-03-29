% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{myOccCiteObject}
\alias{myOccCiteObject}
\title{Results of an occCite search for *Protea cynaroides*}
\format{
An `occCiteData` object with the following slots:
\describe{
 \item{userQueryType}{What kind of query was made}
 \item{userSpecTaxonomy}{A vector of taxonomic sources specified}
 \item{cleanedTaxonomy}{A data frame with results of taxonomic cleanup}
 \item{occSources}{A vector of which databases were queried
 (i.e. GBIF and BIEN)}
 \item{occCiteSearchDate}{When the search was made}
 \item{occResults}{A list of length 1 named "Protea cynaroides".
 Contains a list of length 2 with results from each database, GBIF and BIEN}
}
}
\source{
Global Biodiversity Information Facility,
GBIF (\url{https://www.gbif.org/}) and
Botanical Information and Ecology Network,
BIEN (\url{https://bien.nceas.ucsb.edu/bien/})
data aggregators.
}
\usage{
myOccCiteObject
}
\description{
Results of an occCite search for *Protea cynaroides*
}
\examples{
\donttest{
myOccCiteObject
}
}
\keyword{datasets}
