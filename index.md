# Epidemiological analysis using mixing matrices in R

[epimixr](https://github.com/epiforecasts/epimixr) is an `R` package
that uses social mixing matrices to conduct epidemiological analysis. It
contains the functions `adjust_immunity` (to adjust population-level
immunity by mixing patterns as described in [Funk et al.,
2019](https://doi.org/10.1186/s12916-019-1413-7)), `project_immunity`
(to estimate immunity based on vaccination data by projecting forward
from a given starting point of age-specific susceptibility) and
`epidemic_age_dist` (to estimate the age distribution of an epidemic,
see also the [finalsize](https://epiverse-trace.github.io/finalsize/)
package which implements more functionality to perform the same task).

# Installation

The current development version can be installed using the `remotes`
package

``` r

remotes::install_github("epiforecasts/epimixr")
```
