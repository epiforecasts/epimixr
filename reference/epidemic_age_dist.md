# Calculates the age distribution of an epidemic

calculates the age distribution in an epidemic setting using the
iterative method of: J Wallinga, P Teunis, M Kretschmar (2006) Using
Data on Social Contacts to Estimate Age-specific Transmission Parameters
for Respiratory-spread Infectious Agents. Am J Epidemiol 164(10),
945-946.

## Usage

``` r
epidemic_age_dist(
  mixing_matrix,
  r_0,
  immunity = 0,
  final_size_start = 0.01,
  tol = 1e-05
)
```

## Arguments

- mixing_matrix:

  A mixing matrix or set of mixing matrices, as returned by
  [`socialmixr::contact_matrix`](https://epiforecasts.io/socialmixr/reference/contact_matrix.html)

- r_0:

  basic reproduction number

- immunity:

  proportion immune before the epidemic

- final_size_start:

  starting value for inidence

- tol:

  tolerance for stopping the iteration

## Value

A matrix of the final size(s) (proportion of susceptibles infected) in
each age group (one row per matrix contained in `mixing`)

## Examples

``` r
library("socialmixr")
mixing <- contact_matrix(survey = polymod, age.limits = c(0, 5, 10))
epidemic_age_dist(mixing$matrix, r_0 = 5, immunity = 0.50)
#>        [0,5)    [5,10) [10,Inf)
#> [1,] 0.18991 0.4972204 0.959609
```
