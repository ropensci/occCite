% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/occCiteData.R
\docType{class}
\name{occCiteData-class}
\alias{occCiteData-class}
\alias{occCiteData}
\title{occCite Data Class}
\description{
A class for managing metadata associated with occCite
queries and data manipulation.
}
\section{Slots}{

\describe{
\item{\code{userQueryType}}{A vector of type character specifying whether the
user made their original taxonomic query based on a vector of taxon names
or a phylogeny.}

\item{\code{userSpecTaxonomy}}{A vector of type character that presents a
list of taxonomic sources for cleaning taxonomy of queries. This can be
user-specified or default.}

\item{\code{cleanedTaxonomy}}{A data frame with containing input taxon names, the
closest match according to \code{\link[taxize]{gnr_resolve}}, and a list of
taxonomic data sources that contain the matching name, generated
by \code{\link{studyTaxonList}}.}

\item{\code{occSources}}{A vector of class "character" containing a list of
occurrence data sources, generated when passing a \code{\link{occCiteData}}
object through \code{\link{occQuery}}.}

\item{\code{occCiteSearchDate}}{The date on which the occurrence search query
was conducted via occCite.}

\item{\code{occResults}}{The results of an \code{\link{occQuery}} search, stored
as a named list, each of the items named after a searched taxon and
containing a data frame with occurrence information.}
}}

