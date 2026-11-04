# epimixr (development version)

- `project_immunity()` now works on any time scale via the new `time_unit`
  argument, with ages, the vaccination schedule and all times given in months,
  weeks or days as well as years. Times can be given as `Date`s or as
  `"YYYY-MM"`/`"YYYY-MM-DD"` strings.
- The `baseline_year` and `year` arguments of `project_immunity()` have been
  renamed to `baseline_time` and `time`; the old names still work but warn.

# epimixr 0.1.0

Initial release

