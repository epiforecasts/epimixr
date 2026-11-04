# Project immunity from a baseline

Project immunity from a baseline via vaccination coverage rates

## Usage

``` r
project_immunity(
  baseline_immunity,
  baseline_time,
  time,
  coverage,
  schedule,
  maternal_immunity,
  efficacy,
  time_unit = c("year", "month", "week", "day"),
  baseline_year = deprecated(),
  year = deprecated()
)
```

## Arguments

- baseline_immunity:

  baseline immunity, as a named vector; the names correspond to lower
  limits of the age groups (in `time_unit`), and the vector itself to
  the corresponding levels of immunity.

- baseline_time:

  time at which baseline immunity is taken (corresponding to a column in
  the `coverage` argument)

- time:

  time to project to

- coverage:

  coverage with multiple vaccine doses, given as a matrix in which each
  row is a dose and each (named) column a time

- schedule:

  the ages at which vaccines are given (in `time_unit`).

- maternal_immunity:

  the proportion maternally immune.

- efficacy:

  vaccine efficacy.

- time_unit:

  the unit of time and age; one of "year" (default), "month", "week" or
  "day".

- baseline_year:

  deprecated, use `baseline_time` instead

- year:

  deprecated, use `time` instead

## Value

a data frame of immunity levels by age group (as in
`baseline_immunity`).

## Details

The projection proceeds in steps of one `time_unit`, with everyone
ageing by one `time_unit` at each step. Ages, the vaccination schedule
and all times are therefore given in the same unit, set by `time_unit`:
years by default, but months or any other supported unit work in the
same way.

Times (`baseline_time`, `time` and the column names of `coverage`) can
be given as numbers counted in `time_unit` (e.g. calendar years), as
`Date` objects, or as character strings holding either of these, with
`"YYYY-MM"` taken to mean the first day of that month.

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

## the same projection on a monthly time scale
monthly_immunity <- c(`24` = 0.85, `60` = 0.9, `120` = 0.95)
monthly_coverage <- matrix(rep(0.9, 120), nrow = 2)
colnames(monthly_coverage) <- format(
  seq(as.Date("2015-01-01"), as.Date("2019-12-01"), by = "month"), "%Y-%m"
)
project_immunity(
  monthly_immunity, "2018-01", "2019-01", coverage = monthly_coverage,
  schedule = c(12, 24), 0.5, 0.95, time_unit = "month"
)
#>         0        24        60       120 
#> 0.6775000 0.8929917 0.8900000 0.9500000 
```
