##' Convert times to whole numbers of time units
##'
##' Times can be given as numbers already counted in \code{time_unit} (e.g.
##' calendar years if \code{time_unit} is \code{"year"}), as \code{Date} objects
##' or as character strings holding either of these. Strings of the form
##' \code{"YYYY-MM"} are taken to mean the first day of that month.
##' @param x times to convert
##' @param time_unit unit of time; one of "year", "month", "week" or "day"
##' @param name name of the argument being converted, used in error messages
##' @return an integer vector of times counted in \code{time_unit}
##' @author Sebastian Funk
##' @noRd
time_steps <- function(x, time_unit, name = "time") {
  if (inherits(x, "Date")) return(date_steps(x, time_unit))
  if (is.factor(x)) x <- as.character(x)
  if (is.character(x)) {
    num <- suppressWarnings(as.numeric(x))
    if (anyNA(num)) return(date_steps(as_date(x, name), time_unit))
    x <- num
  }
  if (!is.numeric(x)) {
    stop("'", name, "' must be numeric, a date or a character string")
  }
  if (any(is.na(x)) || any(x != round(x))) {
    stop("'", name, "' must be given as whole ", time_unit, "s or as dates")
  }
  as.integer(round(x))
}

##' Interpret character strings as dates
##'
##' @param x character vector of dates, either "YYYY-MM-DD" or "YYYY-MM"
##' @inheritParams time_steps
##' @return a vector of \code{Date}s
##' @author Sebastian Funk
##' @noRd
as_date <- function(x, name = "time") {
  month_only <- grepl("^[0-9]{4}-[0-9]{1,2}$", x)
  x[month_only] <- paste0(x[month_only], "-01")
  dates <- as.Date(x, format = "%Y-%m-%d")
  if (anyNA(dates)) {
    stop(
      "could not interpret '", name, "' as numbers or dates: ",
      paste(unique(x[is.na(dates)]), collapse = ", ")
    )
  }
  dates
}

##' Count dates in whole time units
##'
##' @param x a vector of \code{Date}s
##' @inheritParams time_steps
##' @return an integer vector of times counted in \code{time_unit}
##' @author Sebastian Funk
##' @noRd
date_steps <- function(x, time_unit) {
  parts <- as.POSIXlt(x)
  switch(time_unit,
    year = parts$year + 1900L,
    month = (parts$year + 1900L) * 12L + parts$mon,
    week = as.integer(floor(as.integer(x) / 7)),
    day = as.integer(x)
  )
}

##' Convert ages to whole numbers of time units
##'
##' @param x ages, in units of \code{time_unit}
##' @inheritParams time_steps
##' @return an integer vector of ages counted in \code{time_unit}
##' @author Sebastian Funk
##' @noRd
age_steps <- function(x, time_unit, name = "age") {
  if (is.character(x) || is.factor(x)) {
    x <- suppressWarnings(as.numeric(as.character(x)))
  }
  if (!is.numeric(x) || any(is.na(x)) || any(x != round(x)) || any(x < 0)) {
    stop("'", name, "' must be given as non-negative whole ", time_unit, "s")
  }
  as.integer(round(x))
}
