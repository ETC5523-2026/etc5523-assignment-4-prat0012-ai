# Column names used inside dplyr and ggplot2 code in this package.
# Listing them here tells R CMD check that they are columns, not
# undefined variables.
utils::globalVariables(c(
  "rubbish_type", "wheel", "year", "count",
  "loads_counted", "total_items", "items_per_load",
  "value", "short_name", "reliability"
))
