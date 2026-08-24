# Project immunity from a baseline

Project immunity from a baseline via vaccination coverage rates

## Usage

``` r
project_immunity(
  baseline_immunity,
  baseline_year,
  year,
  coverage,
  schedule,
  maternal_immunity,
  efficacy
)
```

## Arguments

- baseline_immunity:

  baseline immunity, as a named vector; the names correspond to lower
  limits of the age groups, and the vector itself to the corresponding
  levels of immunity.

- baseline_year:

  year at which baseline immunity is taken (corresponding to a column in
  the `coverage` argument)

- year:

  year to project to

- coverage:

  coverage with multiple vaccine doses, given as a matrix in which each
  row is a dose and each (named) column a year

- schedule:

  the ages at which vaccines are given (in years).

- maternal_immunity:

  the proportion maternally immune.

- efficacy:

  vaccine efficacy.

## Value

a data frame of immunity levels by age group (as in
`baseline_immunity`).

## Author

Sebastian Funk \<sebastian.funk@lshtm.ac.uk\>

## Examples

``` r
baseline_immunity <- c(`2` = 0.85, `5` = 0.9, `10` = 0.95)
coverage <- matrix(rep(0.9, 10), nrow = 2)
colnames(coverage) <- as.character(seq(2015, 2019))
project_immunity(
  baseline_immunity, 2018, 2019, coverage = coverage,
  schedule = c(1, 2), 0.5, 0.95
)
#> Warning: `reduce_agegroups()` was deprecated in socialmixr 0.7.0.
#> ℹ Please use `reduce_age_groups()` instead.
#> ℹ The deprecated feature was likely used in the epimixr package.
#>   Please report the issue to the authors.
#>         0         2         5        10 
#> 0.6775000 0.8929917 0.8900000 0.9500000 
```
