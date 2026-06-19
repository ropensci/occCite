# GBIFLogin Data Class

A class for managing GBIF login data.

## Slots

- `username`:

  A vector of type character specifying a GBIF username.

- `email`:

  A vector of type character specifying the email associated with a GBIF
  username.

- `pwd`:

  A vector of type character containing the user's password for logging
  in to GBIF.

## Examples

``` r
# \donttest{
GBIFLogin <- GBIFLoginManager(
  user = "occCiteTester",
  email = "****@yahoo.com",
  pwd = "12345"
)
#> Warning: GBIF unreachable; please try again later. 
# }
```
