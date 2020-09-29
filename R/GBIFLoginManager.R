#' @title GBIF Login Manager
#'
#' @description Takes users GBIF login particulars and turns it
#' into a \code{\link{GBIFLogin}} for use in downloading data from
#' GBIF. You MUST ALREADY HAVE AN ACCOUNT at \href{http://gbif.org/}{GBIF}.
#'
#' @param user A vector of type character specifying a GBIF username.
#'
#' @param email A vector of type character specifying the email associated
#' with a GBIF username.
#'
#' @param pwd A vector of type character containing the user's password for
#' logging in to GBIF.
#'
#' @return An object of class \code{\link{GBIFLogin}} containing the user's
#'  GBIF login data.
#'
#' @examples
#' ## Inputting user particulars
#'\donttest{
#' myLogin <- GBIFLoginManager(user = "theWoman",
#'                             email = "ireneAdler@@laScala.org",
#'                             pwd = "sh3r")
#'}
#'
#'\donttest{
#' ## Can also be mined from your system environment
#' myLogin <- GBIFLoginManager(user = NULL,
#'                             email = NULL, pwd = NULL)
#'}
#'
#' @export
GBIFLoginManager <- function(user = NULL, email = NULL, pwd = NULL) {
  #Error checking inputs
  if (!is.null(user) && class(user)!="character"){
    warning("Input user name is invalid; it must be a vector of class 'character'.\n")
    return(NULL)
  }

  if (!is.null(email) && class(email)!="character"){
    warning("Input email is invalid; it must be a vector of class 'character'.\n")
    return(NULL)
  }

  if (!is.null(pwd) && class(pwd)!="character"){
    warning("Input password is invalid; it must be a vector of class 'character'.\n")
    return(NULL)
  }

  #Checking for system login information if not supplied by user
  user <- check_user(user)
  email <- check_email(email)
  pwd <- check_pwd(pwd)

  #Test login
  test <- try(rgbif::occ_download(user=user, email = email, pwd = pwd, rgbif::pred("catalogNumber", 217880)), silent = T)
  if(class(test) != 'occ_download'){
    warning("GBIF user login data incorrect.\n")
    return(NULL)
  }

  #Populating an instance of class occCiteData
  loginInstance <- methods::new("GBIFLogin", username = user, email = email, pwd = pwd)
  return(loginInstance)
}

#Functions for checking for login information in system environment(adapted from \code{\link{occ_download}} in \code{\link{rgbif}})
check_user <- function(x) {
  z <- if (is.null(x)) Sys.getenv("GBIF_USER", "") else x
  if (z == "") getOption("gbif_user", stop("supply a username")) else z
}

check_pwd <- function(x) {
  z <- if (is.null(x)) Sys.getenv("GBIF_PWD", "") else x
  if (z == "") getOption("gbif_pwd", stop("supply a password")) else z
}

check_email <- function(x) {
  z <- if (is.null(x)) Sys.getenv("GBIF_EMAIL", "") else x
  if (z == "") getOption("gbif_email", stop("supply an email address")) else z
}
