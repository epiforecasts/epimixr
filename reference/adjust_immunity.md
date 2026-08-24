# Estimate reproduction number from contact information and immunity profile

This takes a contact survey to derive a contact matrix and rescales
contacts to represent contacts with susceptibles. This is then combined
with information on the basic reproduction number R0 to calculate the
effective or net reproduction number.

## Usage

``` r
adjust_immunity(mixing_matrix, immunity, vector = FALSE)
```

## Arguments

- mixing_matrix:

  A mixing matrix, as returned by
  [`socialmixr::contact_matrix`](https://epiforecasts.io/socialmixr/reference/contact_matrix.html)

- immunity:

  immunity profile; this should be given as a vector of the same length
  as the number of rows/columns of the mixing matrix; each element of
  the vector should contain a value \<1 representing the proportion of
  the population immune in the corresponding age group; any element set
  to "herd" will be set to 1-1/R0

- vector:

  if TRUE, will return the eigenvector corresponding to the dominant
  eigenvector instead of adjusted immunity; this corresponds to the
  expected stable age distribution of infections in case of an outbreak

## Value

a list contain vectors of adjusted immunities

## Author

Sebastian Funk

## Examples

``` r
library("socialmixr")
mixing <- contact_matrix(survey = polymod, age.limits
  = c(0, 5, 10))
#> Warning: The `age.limits` argument of `contact_matrix()` is deprecated as of socialmixr
#> 0.5.0.
#> ℹ Please use the `age_limits` argument instead.
#> ℹ The deprecated feature was likely used in the socialmixr package.
#>   Please report the issue at
#>   <https://github.com/epiforecasts/socialmixr/issues>.
adjust_immunity(mixing$matrix, immunity = c(0, 0.5, 0.8))
#> [1] 0.7069723
```
