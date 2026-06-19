# GBIF Login Manager

Takes users GBIF login particulars and turns it into a
[`GBIFLogin`](https://docs.ropensci.org/occCite/reference/GBIFLogin-class.md)
for use in downloading data from GBIF. You MUST ALREADY HAVE AN ACCOUNT
at [GBIF](http://gbif.org/).

## Usage

``` r
GBIFLoginManager(user = NULL, email = NULL, pwd = NULL)
```

## Arguments

- user:

  A vector of type character specifying a GBIF username.

- email:

  A vector of type character specifying the email associated with a GBIF
  username.

- pwd:

  A vector of type character containing the user's password for logging
  in to GBIF.

## Value

An object of class
[`GBIFLogin`](https://docs.ropensci.org/occCite/reference/GBIFLogin-class.md)
containing the user's GBIF login data.

## Examples

``` r
## Inputting user particulars
if (FALSE) { # \dontrun{
myLogin <- GBIFLoginManager(
  user = "theWoman",
  email = "ireneAdler@laScala.org",
  pwd = "sh3r"
)
} # }

if (FALSE) { # \dontrun{
## Can also be mined from your system environment
myLogin <- GBIFLoginManager(
  user = NULL,
  email = NULL, pwd = NULL
)
} # }
```
