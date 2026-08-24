## Generates the epimixr hex logo: the age distribution of an epidemic through
## time, simulated with UK POLYMOD mixing.
## Run with `Rscript data-raw/logo.R` (needs socialmixr and inkscape).

library("socialmixr")

## ---- mixing and demography ------------------------------------------------

data(polymod)
survey <- suppressWarnings(contact_matrix(
  polymod,
  countries = "United Kingdom",
  age_limits = c(0, 5, 15, 30, 50, 65),
  symmetric = TRUE
))
mixing <- survey$matrix
pop <- survey$demography$population / sum(survey$demography$population)
n_ages <- nrow(mixing)

## ---- age-structured epidemic ----------------------------------------------

## incidence by age group in generation time, seeded evenly across ages
epidemic <- function(r_0 = 1.9, dt = 0.02, steps = 2200) {
  ngm <- r_0 * mixing / Re(eigen(mixing)$values[1])
  susceptible <- rep(1, n_ages)
  infectious <- rep(2e-4, n_ages)
  incidence <- matrix(0, steps, n_ages)
  for (step in seq_len(steps)) {
    infections <- susceptible * as.vector(ngm %*% infectious) * dt
    incidence[step, ] <- infections * pop
    susceptible <- susceptible - infections
    infectious <- infectious + infections - infectious * dt
  }
  incidence
}

incidence <- epidemic()
## drop the tails so the peak fills the width of the sticker
visible <- which(rowSums(incidence) > max(rowSums(incidence)) * 0.06)
incidence <- incidence[
  round(seq(min(visible), max(visible), length.out = 260)),
]

## ---- geometry -------------------------------------------------------------

width <- 1200
height <- width * 2 / sqrt(3)
cx <- width / 2
cy <- height / 2

hexagon <- function(scale = 1) {
  x <- cx + (c(0, 0.5, 0.5, 0, -0.5, -0.5) * width) * scale
  y <- cy + (c(-0.5, -0.25, 0.25, 0.5, 0.25, -0.25) * height) * scale
  paste0("M ", paste(sprintf("%.2f %.2f", x, y), collapse = " L "), " Z")
}

## ---- colours --------------------------------------------------------------

viridis <- c(
  "#440154", "#46327e", "#365c8d", "#277f8e",
  "#1fa187", "#4ac16d", "#a0da39", "#fde725"
)
ramp <- colorRamp(viridis, space = "Lab")

## the youngest band sits at the bottom; the ramp runs towards whichever end
## of viridis contrasts with the background, so the curve keeps a crisp edge
themes <- list(
  light = list(
    file = "man/figures/logo",
    background = "#ffffff", border = "#1a7f8e",
    axis_col = "#c9d4d8", text_col = "#16212a", stops = c(0.92, 0.10)
  ),
  dark = list(
    file = "man/figures/logo-dark",
    background = "#131a21", border = "#26828e",
    axis_col = "#31424f", text_col = "#f4f7f5", stops = c(0.30, 0.99)
  )
)

## ---- stacked epidemic curve -----------------------------------------------

x_left <- 132
x_right <- 1068
baseline <- 985
peak_height <- 545

stacked <- t(apply(incidence, 1, cumsum))
xs <- seq(x_left, x_right, length.out = nrow(incidence))
scale <- peak_height / max(stacked)

make_bands <- function(age_cols) {
  bands <- character()
  for (age in seq_len(n_ages)) {
    below <- if (age == 1) rep(0, nrow(stacked)) else stacked[, age - 1]
    upper <- sprintf("%.1f %.1f", xs, baseline - stacked[, age] * scale)
    lower <- sprintf("%.1f %.1f", rev(xs), baseline - rev(below) * scale)
    bands <- c(bands, sprintf(
      '<path d="M %s L %s Z" fill="%s"/>',
      paste(upper, collapse = " L "), paste(lower, collapse = " L "),
      age_cols[age]
    ))
  }
  paste(bands, collapse = "\n")
}

## ---- assemble -------------------------------------------------------------

template <- '<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="%.0f" height="%.0f"
     viewBox="0 0 %.0f %.0f">
  <path d="%s" fill="%s"/>
  <path d="%s" fill="%s"/>
%s
  <rect x="%.0f" y="%.0f" width="%.0f" height="9" rx="4.5" fill="%s"/>
  <text x="%.0f" y="%.0f" text-anchor="middle" fill="%s"
        font-family="Inter Display SemiBold, Inter SemiBold, sans-serif"
        font-weight="600" font-size="168" letter-spacing="4">epimixr</text>
</svg>
'

for (theme in themes) {
  age_cols <- rgb(
    ramp(seq(theme$stops[1], theme$stops[2], length.out = n_ages)),
    maxColorValue = 255
  )
  svg <- sprintf(
    template,
    width, height, width, height,
    hexagon(1), theme$border,
    hexagon(1 - 58 / width), theme$background,
    make_bands(age_cols),
    x_left - 12, baseline, x_right - x_left + 24, theme$axis_col,
    cx, 1175, theme$text_col
  )

  svg_file <- paste0(theme$file, ".svg")
  writeLines(svg, svg_file)

  system2("inkscape", c(
    shQuote(svg_file), "--export-type=png", "--export-width=1200",
    paste0("--export-filename=", shQuote(paste0(theme$file, ".png")))
  ))

  ## keep the SVG readable without Inter installed
  system2("inkscape", c(
    shQuote(svg_file), "--export-type=svg", "--export-text-to-path",
    "--export-plain-svg", paste0("--export-filename=", shQuote(svg_file))
  ))
}
