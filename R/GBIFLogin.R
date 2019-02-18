library(methods);

#' @title GBIFLogin Data Class
#'
#' @description A class for managing GBIF login data.
#'
#' @slot username A vector of type character specifying a GBIF username.
#'
#' @slot email A vector of type character specifying the email associated with a GBIF username.
#'
#' @slot pwd A vector of type character containing the user's password for logging in to GBIF.
#'
#' @export

GBIFLogin <- methods::setClass("GBIFLogin",
                           slots = c(username = "vector",
                                     email = "vector",
                                     pwd = "vector"));
