#' Summarise rubbish counts by Trash Wheel and year
#'
#' Adds up the estimated number of items of one kind of rubbish for each
#' Trash Wheel and year, then divides by the number of dumpster loads in
#' which that item was counted. The average per load is a fairer way to
#' compare years and Trash Wheels than the yearly total, because the number
#' of loads collected changes a lot from year to year.
#'
#' @param data A data frame with the same columns as [trash_loads],
#'   usually `trash_loads` itself.
#' @param item One kind of rubbish, for example `"Plastic bottles"`.
#'   Run `unique(trash_loads$rubbish_type)` to see all seven options.
#' @param wheels One or more Trash Wheel names. The default uses every
#'   Trash Wheel in `data`.
#' @param years Two years giving the first and last year to include, for
#'   example `c(2018, 2023)`. The default uses every year in `data`.
#'
#' @return A data frame with one row per Trash Wheel and year, and these
#'   columns:
#'   * `wheel`: name of the Trash Wheel.
#'   * `year`: year of collection.
#'   * `loads_collected`: number of dumpster loads collected that year.
#'   * `loads_counted`: number of those loads in which `item` was counted.
#'   * `total_items`: estimated number of items in the counted loads.
#'   * `items_per_load`: `total_items` divided by `loads_counted`.
#'
#'   `total_items` and `items_per_load` are `NA` when `item` was not
#'   counted in any load that year. This means "not recorded", not zero.
#'   A Trash Wheel with no loads in the chosen years has no rows.
#'
#' @examples
#' # Plastic bottles per dumpster load at every Trash Wheel
#' summarise_rubbish(trash_loads, item = "Plastic bottles")
#'
#' # Cigarette butts at Mister Trash Wheel from 2019 to 2023
#' summarise_rubbish(
#'   trash_loads,
#'   item = "Cigarette butts",
#'   wheels = "Mister Trash Wheel",
#'   years = c(2019, 2023)
#' )
#'
#' # Gwynnda never counted glass bottles, so the averages are NA
#' summarise_rubbish(
#'   trash_loads,
#'   item = "Glass bottles",
#'   wheels = "Gwynnda Trash Wheel"
#' )
#' @importFrom dplyr filter group_by summarise mutate arrange n if_else
#' @export
summarise_rubbish <- function(data,
                              item,
                              wheels = unique(data$wheel),
                              years = range(data$year)) {
  # Check the inputs first, so a mistake gives a clear message
  if (length(item) != 1 || !item %in% data$rubbish_type) {
    stop(
      "`item` must be one of: ",
      paste(sort(unique(data$rubbish_type)), collapse = ", "),
      call. = FALSE
    )
  }

  unknown_wheels <- setdiff(wheels, data$wheel)
  if (length(unknown_wheels) > 0) {
    stop(
      "Unknown Trash Wheel: ", paste(unknown_wheels, collapse = ", "),
      call. = FALSE
    )
  }

  if (length(years) != 2 || years[1] > years[2]) {
    stop(
      "`years` must be two years, first then last, for example c(2018, 2023).",
      call. = FALSE
    )
  }

  data |>
    filter(
      rubbish_type == item,
      wheel %in% wheels,
      year >= years[1],
      year <= years[2]
    ) |>
    group_by(wheel, year) |>
    summarise(
      loads_collected = n(),
      # A missing count means "not counted", so it is left out of the average
      loads_counted = sum(!is.na(count)),
      total_items = sum(count, na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(
      # With no counted loads there is no total to report, only "not recorded"
      total_items = if_else(loads_counted == 0, NA_real_, total_items),
      items_per_load = total_items / loads_counted
    ) |>
    arrange(wheel, year)
}
