# Build the `trash_loads` dataset that ships with the package.
#
# Run this script from the package folder with:
#   source("data-raw/trash_loads.R")
#
# Source: TidyTuesday, 5 March 2024. The data were first published by
# Mr. Trash Wheel, part of Baltimore's Healthy Harbor initiative
# (https://www.mrtrashwheel.com/).

library(dplyr)
library(tidyr)
library(readr)
library(lubridate)

# 1. Import the raw data ----------------------------------------------

url <- paste0(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/",
  "main/data/2024/2024-03-05/trashwheel.csv"
)

raw <- read_csv(url, show_col_types = FALSE)

# The raw file has one row per dumpster load: 993 loads in total.
stopifnot(nrow(raw) == 993)

# 2. Clean the columns ------------------------------------------------

loads <- raw |>
  mutate(
    # Dates are written two ways in the raw file, for example
    # "5/16/2014" and "6/30/18". mdy() reads both correctly.
    date = mdy(Date),
    # The raw Year column disagrees with the date in 3 rows
    # (for example, Gwynnda loads from December 2021 are labelled 2022),
    # so the year is taken from the date instead.
    year = as.integer(year(date))
  ) |>
  # Keep only the columns the package needs, with clear names.
  # The raw Month column is dropped because its spelling is
  # inconsistent ("July" and "july") and the date already holds it.
  select(
    wheel = Name,
    dumpster = Dumpster,
    date,
    year,
    weight_tons = Weight,
    volume_cubic_yards = Volume,
    PlasticBottles:SportsBalls
  )

# Every date should now be readable.
stopifnot(!anyNA(loads$date))

# 3. Reshape: one row per dumpster load and rubbish type ---------------

trash_loads <- loads |>
  pivot_longer(
    cols = PlasticBottles:SportsBalls,
    names_to = "rubbish_type",
    values_to = "count"
  ) |>
  mutate(
    rubbish_type = case_when(
      rubbish_type == "PlasticBottles" ~ "Plastic bottles",
      rubbish_type == "Polystyrene" ~ "Polystyrene",
      rubbish_type == "CigaretteButts" ~ "Cigarette butts",
      rubbish_type == "GlassBottles" ~ "Glass bottles",
      rubbish_type == "PlasticBags" ~ "Plastic bags",
      rubbish_type == "Wrappers" ~ "Wrappers",
      rubbish_type == "SportsBalls" ~ "Sports balls"
    )
  ) |>
  arrange(wheel, date, dumpster, rubbish_type)

# A missing count (NA) means that item was not counted for that load.
# It does NOT mean zero items were collected, so NA is kept as NA.
# Gwynnda has two different loads both numbered 21; both are kept
# because they were collected on different dates.

# 4. Check the result -------------------------------------------------

# 993 loads x 7 rubbish types = 6,951 rows
stopifnot(nrow(trash_loads) == 993 * 7)
stopifnot(all(trash_loads$count >= 0, na.rm = TRUE))

# 5. Save the package data --------------------------------------------

usethis::use_data(trash_loads, overwrite = TRUE)
