#' Rubbish collected by Baltimore's Trash Wheels
#'
#' Estimated counts of seven kinds of rubbish in each dumpster load
#' collected by the four Trash Wheels in Baltimore's harbour, from May 2014
#' to December 2023. Each row is one kind of rubbish in one dumpster load.
#'
#' @format A data frame with 6,951 rows and 8 columns:
#' \describe{
#'   \item{wheel}{Name of the Trash Wheel, for example "Mister Trash Wheel".}
#'   \item{dumpster}{Dumpster number. Numbering starts at 1 for each
#'     Trash Wheel.}
#'   \item{date}{Date the dumpster load was collected.}
#'   \item{year}{Year the load was collected, taken from `date`.}
#'   \item{weight_tons}{Weight of the whole dumpster load, in US tons.}
#'   \item{volume_cubic_yards}{Volume of the whole dumpster load, in cubic
#'     yards.}
#'   \item{rubbish_type}{Kind of rubbish counted, for example
#'     "Plastic bottles".}
#'   \item{count}{Estimated number of items of that kind in the load.
#'     `NA` means the item was not counted for that load.}
#' }
#'
#' @details
#' Item counts are estimates made from samples taken during collection,
#' not exact counts.
#'
#' A missing count (`NA`) means the item was not counted for that load. It
#' does not mean that no items were collected. Captain and Gwynnda Trash
#' Wheels never recorded glass bottles or sports balls, Professor Trash Wheel
#' never recorded sports balls, and wrappers were recorded for only some
#' Captain and Gwynnda loads.
#'
#' The number of dumpster loads changes a lot between Trash Wheels and years,
#' so yearly totals can be misleading. The average count per dumpster load
#' gives a fairer comparison.
#'
#' @source TidyTuesday, 5 March 2024,
#'   <https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-03-05>.
#'   Original data from Mr. Trash Wheel, Baltimore's Healthy Harbor
#'   initiative, <https://www.mrtrashwheel.com/>.
#'
#' @examples
#' head(trash_loads)
#'
#' # Number of dumpster loads collected by each Trash Wheel
#' plastic_bottles <- trash_loads[trash_loads$rubbish_type == "Plastic bottles", ]
#' table(plastic_bottles$wheel)
"trash_loads"
