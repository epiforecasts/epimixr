##' Project immunity from a baseline via vaccination coverage rates
##'
##' The projection proceeds in steps of one \code{time_unit}, with everyone
##' ageing by one \code{time_unit} at each step. Ages, the vaccination schedule
##' and all times are therefore given in the same unit, set by
##' \code{time_unit}: years by default, but months or any other supported unit
##' work in the same way.
##'
##' Times (\code{baseline_time}, \code{time} and the column names of
##' \code{coverage}) can be given as numbers counted in \code{time_unit} (e.g.
##' calendar years), as \code{Date} objects, or as character strings holding
##' either of these, with \code{"YYYY-MM"} taken to mean the first day of that
##' month.
##'
##' @title Project immunity from a baseline
##' @param baseline_immunity baseline immunity, as a named vector; the names
##'   correspond to lower limits of the age groups (in \code{time_unit}), and
##'   the vector itself to the corresponding levels of immunity.
##' @param baseline_time time at which baseline immunity is taken
##'   (corresponding to a column in the \code{coverage} argument)
##' @param time time to project to
##' @param coverage coverage with multiple vaccine doses, given as a matrix in
##'   which each row is a dose and each (named) column a time
##' @param schedule the ages at which vaccines are given (in \code{time_unit}).
##' @param maternal_immunity the proportion maternally immune.
##' @param efficacy vaccine efficacy.
##' @param time_unit the unit of time and age; one of "year" (default),
##'   "month", "week" or "day".
##' @param baseline_year deprecated, use \code{baseline_time} instead
##' @param year deprecated, use \code{time} instead
##' @return a data frame of immunity levels by age group (as in
##'   \code{baseline_immunity}).
##' @author Sebastian Funk <sebastian.funk@lshtm.ac.uk>
##' @importFrom stats na.omit
##' @importFrom socialmixr reduce_agegroups
##' @importFrom lifecycle deprecated is_present deprecate_warn
##' @export
##' @examples
##' baseline_immunity <- c(`2` = 0.85, `5` = 0.9, `10` = 0.95)
##' coverage <- matrix(rep(0.9, 10), nrow = 2)
##' colnames(coverage) <- as.character(seq(2015, 2019))
##' project_immunity(
##'   baseline_immunity, 2018, 2019, coverage = coverage,
##'   schedule = c(1, 2), 0.5, 0.95
##' )
##'
##' ## the same projection on a monthly time scale
##' monthly_immunity <- c(`24` = 0.85, `60` = 0.9, `120` = 0.95)
##' monthly_coverage <- matrix(rep(0.9, 120), nrow = 2)
##' colnames(monthly_coverage) <- format(
##'   seq(as.Date("2015-01-01"), as.Date("2019-12-01"), by = "month"), "%Y-%m"
##' )
##' project_immunity(
##'   monthly_immunity, "2018-01", "2019-01", coverage = monthly_coverage,
##'   schedule = c(12, 24), 0.5, 0.95, time_unit = "month"
##' )
project_immunity <- function(baseline_immunity, baseline_time, time, coverage,
                             schedule, maternal_immunity, efficacy,
                             time_unit = c("year", "month", "week", "day"),
                             baseline_year = deprecated(),
                             year = deprecated()) {
  time_unit <- match.arg(time_unit)

  ## deprecated arguments
  if (is_present(baseline_year)) {
    deprecate_warn(
      "0.2.0", "project_immunity(baseline_year)",
      "project_immunity(baseline_time)"
    )
    if (missing(baseline_time)) baseline_time <- baseline_year
  }
  if (is_present(year)) {
    deprecate_warn(
      "0.2.0", "project_immunity(year)", "project_immunity(time)"
    )
    if (missing(time)) time <- year
  }

  ## checks
  if (missing(baseline_immunity)) stop("baseline immunity must be provided")
  if (missing(baseline_time)) stop("baseline time must be provided")
  if (missing(time)) stop("'time' argument must be provided")
  baseline_step <- time_steps(baseline_time, time_unit, "baseline_time")
  end_step <- time_steps(time, time_unit, "time")
  if (length(baseline_step) != 1 || length(end_step) != 1) {
    stop("'baseline_time' and 'time' must each be a single time")
  }
  if (!(end_step > baseline_step)) {
    stop("'time' must be greater than 'baseline_time'")
  }
  if (!missing(coverage)) {
    if (missing(schedule)) stop("'schedule' must be given if 'coverage' is")
    if (dim(coverage)[1] != length(schedule)) {
      stop("'coverage' must have a row for each element of 'schedule'")
    }
    if (missing(efficacy)) stop("'efficacy' must be provided if 'coverage' is")
    if (is.null(colnames(coverage))) {
      stop("'coverage' must have column names giving the time of each column")
    }
    schedule <- age_steps(schedule, time_unit, "schedule")
    coverage_steps <- time_steps(colnames(coverage), time_unit, "coverage")
    if (anyDuplicated(coverage_steps)) {
      clashes <- duplicated(coverage_steps) |
        duplicated(coverage_steps, fromLast = TRUE)
      clashing <- colnames(coverage)[clashes]
      first_few <- clashing[seq_len(min(4, length(clashing)))]
      shown <- paste(first_few, collapse = ", ")
      if (length(clashing) > 4) {
        shown <- paste0(shown, ", ... (", length(clashing), " columns in all)")
      }
      stop(
        "columns of 'coverage' must be distinct ", time_unit, "s, but these ",
        "fall in the same ", time_unit, ": ", shown,
        "; set 'time_unit' to the resolution of the columns"
      )
    }
  }
  if (missing(maternal_immunity)) stop("maternal immunity must be provided")
  if (is.null(names(baseline_immunity))) {
    stop("'baseline_immunity' must be named with the lower age limits")
  }

  ## look up coverage with a given dose at a given time
  dose_coverage <- function(dose, step) {
    column <- match(step, coverage_steps)
    if (is.na(column)) {
      stop(
        "'coverage' has no column for ", time_unit, " ", step, "; columns run ",
        "from ", colnames(coverage)[1], " to ",
        colnames(coverage)[ncol(coverage)]
      )
    }
    unname(coverage[dose, column])
  }

  ## convert baseline to immunity by single unit of age
  lower_age_limits <- age_steps(
    names(baseline_immunity), time_unit, "baseline_immunity"
  )
  bdf <- data.frame(
    lower_age_limit = lower_age_limits,
    immunity = baseline_immunity
  )
  df <- data.frame(
    lower_age_limit =
      do.call(seq, as.list(range(lower_age_limits)))
  )
  df[df$lower_age_limit %in% bdf$lower_age_limit, "immunity"] <- bdf$immunity
  ## fill
  df$immunity <- c(NA, na.omit(df$immunity))[cumsum(!is.na(df$immunity)) + 1]

  if (missing(coverage)) {
    df <- df[!(df$lower_age_limit == 0), ]
    df <- rbind(t(c(lower_age_limit = 0, immunity = maternal_immunity)), df)
  } else {
    oldest <- df[nrow(df), ]
    min_age <- min(df$lower_age_limit)

    ## fill missing age groups with vaccination data
    while (min_age > schedule[1]) {
      min_age <- min_age - 1
      df <- rbind(t(c(
        lower_age_limit = min_age,
        immunity = dose_coverage(1, baseline_step - min_age + 1) * efficacy
      )), df)
    }

    scaling_factor <- min(
      df[df$lower_age_limit == schedule[1], "immunity"] /
        dose_coverage(1, baseline_step),
      1
    )

    if (dim(coverage)[2] > 1) {
      for (calc_step in seq(baseline_step + 1, end_step)) {
        ## move all one age group up
        df$lower_age_limit <- df$lower_age_limit + 1
        ## implement vaccination schedule
        df <- df[df$lower_age_limit > schedule[1] + 1, ]
        first_ages <- data.frame(
          lower_age_limit = seq(0, schedule[1] + 1),
          immunity = c(
            rep(maternal_immunity, schedule[1]),
            dose_coverage(1, calc_step) * scaling_factor,
            dose_coverage(1, calc_step - 1) * efficacy
          )
        )
        df <- rbind(first_ages, df)
        if (dim(coverage)[1] > 1) {
          for (j in seq(2, dim(coverage)[1])) {
            immunised <- 0
            for (k in seq(1, j - 1)) {
              old_coverage <- dose_coverage(
                k, calc_step - schedule[j] + schedule[k]
              )
              immunised <- immunised +
                (1 - immunised) * old_coverage * efficacy
            }
            df[df$lower_age_limit == schedule[j], "immunity"] <- min(
              1,
              df[df$lower_age_limit == schedule[j], "immunity"] +
                (1 - immunised) * dose_coverage(j, calc_step) *
                  efficacy
            )
          }
        }
      }
    }
    df <- df[df$lower_age_limit < oldest$lower_age_limit, ]
    df <- rbind(df, oldest)
    rownames(df) <- seq_len(nrow(df))
  }

  ## aggregate by age groups
  df$lower_age_limit <- reduce_agegroups(
    df$lower_age_limit, union(0, lower_age_limits)
  )

  summarised <- by(df, list(df$lower_age_limit), function(x) {
    c(
      lower_age_limit = unique(x$lower_age_limit),
      immunity = mean(x$immunity)
    )
  })
  df <- as.data.frame(do.call(rbind, summarised))
  ret <- df$immunity
  names(ret) <- df$lower_age_limit
  ret
}
