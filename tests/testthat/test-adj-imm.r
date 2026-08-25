context("Adjusting immunity levels")

library("socialmixr")

mixing <- contact_matrix(survey = polymod, age.limits = c(0, 5, 10))

test_that("immunity levels can be projected", {
  baseline_immunity <- c(`2` = 0.85, `5` = 0.9, `10` = 0.95)
  coverage <- matrix(rep(0.9, 10), nrow = 2)
  colnames(coverage) <- as.character(seq(2015, 2019))
  expect_equal(unname(round(
    project_immunity(
      baseline_immunity, 2018, 2019,
      coverage = coverage, schedule = c(1, 2),
      0.5, 0.95
    ), 2
  )), c(0.68, 0.89, 0.89, 0.95))
  expect_equal(unname(round(
    project_immunity(
      baseline_immunity, 2018, 2019,
      maternal_immunity = 0.5
    ), 2
  )), c(0.50, 0.85, 0.90, 0.95))
})

test_that("errors are thrown correctly", {
  coverage_1_dose <- matrix(rep(0.9, 5), nrow = 1)
  colnames(coverage_1_dose) <- as.character(seq(2015, 2019))

  expect_error(project_immunity(), "baseline immunity")
  expect_error(project_immunity(0.9), "baseline time")
  expect_error(project_immunity(0.9, 2000), "'time'")
  expect_error(project_immunity(0.9, 2000, 1998), "must be greater")
  expect_error(project_immunity(0.9, 2000, 2004), "maternal immunity")
  expect_error(project_immunity(
    0.9, 2000, 2004, matrix(c(0.9, 0.9), nrow = 1)
  ), "'schedule' must be given")
  expect_error(project_immunity(
    0.9, 2000, 2004, matrix(c(0.9, 0.9), nrow = 1), c(1, 5)
  ), "a row for each element")
  expect_error(project_immunity(
    0.9, 2000, 2004, matrix(c(0.9, 0.9), nrow = 1), c(1), 0.5
  ), "efficacy")
  expect_error(project_immunity(
    0.9, 2000, 2004, matrix(c(0.9, 0.9), nrow = 1), c(1), 0.5, 0.95
  ), "column names")
  expect_error(project_immunity(
    0.9, 2000, 2004, coverage_1_dose, c(1), 0.5, 0.95
  ), "must be named")
  expect_error(project_immunity(
    c(`2` = 0.9), "not a time", 2004, coverage_1_dose, c(1), 0.5, 0.95
  ), "could not interpret")
  expect_error(project_immunity(
    c(`2` = 0.9), 2000, 2004, coverage_1_dose, c(1), 0.5, 0.95
  ), "no column for year")

  ## monthly columns with the time unit left at its default of years would
  ## otherwise silently use January and discard the other eleven months
  monthly_columns <- matrix(rep(0.9, 24), nrow = 1)
  colnames(monthly_columns) <- format(
    seq(as.Date("2015-01-01"), as.Date("2016-12-01"), by = "month"), "%Y-%m"
  )
  expect_error(project_immunity(
    c(`2` = 0.9), 2015, 2016, monthly_columns, c(1), 0.5, 0.95
  ), "must be distinct years")
})

test_that("adjusted immunity levels can be calculated", {
  expect_equal(round(adjust_immunity(
    mixing$matrix,
    immunity = c(0, 0.5, 0.8)
  ), 1), 0.7)
  expect_equal(round(adjust_immunity(
    mixing$matrix,
    immunity = c(0, 0.5, 0.8)
  ), 1), 0.7)
})

test_that("immunity can be projected on other time scales", {
  yearly_immunity <- c(`2` = 0.85, `5` = 0.9, `10` = 0.95)
  yearly_coverage <- matrix(rep(0.9, 10), nrow = 2)
  colnames(yearly_coverage) <- as.character(seq(2015, 2019))
  yearly <- project_immunity(
    yearly_immunity, 2018, 2019,
    coverage = yearly_coverage, schedule = c(1, 2), 0.5, 0.95
  )

  monthly_immunity <- c(`24` = 0.85, `60` = 0.9, `120` = 0.95)
  monthly_coverage <- matrix(rep(0.9, 120), nrow = 2)
  colnames(monthly_coverage) <- format(
    seq(as.Date("2015-01-01"), as.Date("2019-12-01"), by = "month"), "%Y-%m"
  )
  monthly <- project_immunity(
    monthly_immunity, "2018-01", "2019-01",
    coverage = monthly_coverage, schedule = c(12, 24), 0.5, 0.95,
    time_unit = "month"
  )

  ## with constant coverage, ageing in months over a year gives the same
  ## immunity profile as ageing in years
  expect_equal(unname(monthly), unname(yearly))
  expect_equal(names(monthly), c("0", "24", "60", "120"))

  ## dates and month numbers are interchangeable ways of giving the time
  expect_equal(
    project_immunity(
      monthly_immunity, as.Date("2018-01-01"), as.Date("2019-01-01"),
      coverage = monthly_coverage, schedule = c(12, 24), 0.5, 0.95,
      time_unit = "month"
    ),
    monthly
  )

  ## months at a finer resolution than the yearly schedule
  fine <- project_immunity(
    monthly_immunity, "2018-01", "2018-07",
    coverage = monthly_coverage, schedule = c(9, 18), 0.5, 0.95,
    time_unit = "month"
  )
  expect_named(fine, c("0", "24", "60", "120"))
  expect_true(all(fine >= 0 & fine <= 1))
})

test_that("deprecated year arguments still work", {
  yearly_immunity <- c(`2` = 0.85, `5` = 0.9, `10` = 0.95)
  expect_warning(
    projected <- project_immunity(
      yearly_immunity,
      baseline_year = 2018, year = 2019, maternal_immunity = 0.5
    ),
    "deprecated"
  )
  expect_equal(
    unname(projected),
    unname(project_immunity(
      yearly_immunity, 2018, 2019, maternal_immunity = 0.5
    ))
  )
})
