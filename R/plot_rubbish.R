#' Plot rubbish counts over time for each Trash Wheel
#'
#' Draws one line per Trash Wheel from the output of [summarise_rubbish()].
#' Each line is labelled at its last year, so no legend lookup is needed.
#' Hollow points mark years where fewer than five loads were counted,
#' because an average built on so few loads can jump around a lot.
#'
#' @param summary A data frame returned by [summarise_rubbish()].
#' @param measure What to show on the vertical axis: `"per_load"` for the
#'   average number of items per dumpster load (the fair comparison), or
#'   `"total"` for the estimated total number of items each year.
#'
#' @return A ggplot object. Years where the item was not counted are left
#'   out of the plot.
#'
#' @examples
#' bottles <- summarise_rubbish(trash_loads, item = "Plastic bottles")
#'
#' # The fair comparison: average plastic bottles per dumpster load
#' plot_rubbish(bottles, measure = "per_load")
#'
#' # Yearly totals depend on how many loads were collected each year
#' plot_rubbish(bottles, measure = "total")
#' @importFrom dplyr filter mutate if_else group_by slice_max ungroup
#' @importFrom ggplot2 ggplot aes geom_line geom_point scale_colour_manual
#'   scale_shape_manual scale_x_continuous scale_y_continuous expansion
#'   labs theme_minimal theme element_blank element_text coord_cartesian
#' @export
plot_rubbish <- function(summary, measure = "per_load") {
  if (!measure %in% c("per_load", "total")) {
    stop('`measure` must be "per_load" or "total".', call. = FALSE)
  }

  # Only years where the item was actually counted can be plotted
  plot_data <- summary |>
    filter(loads_counted > 0) |>
    mutate(
      value = if (measure == "per_load") items_per_load else total_items,
      short_name = sub(" Trash Wheel", "", wheel),
      reliability = if_else(
        loads_counted < 5,
        "Fewer than 5 loads",
        "5 or more loads"
      )
    )

  if (nrow(plot_data) == 0) {
    stop("There are no counted loads to plot.", call. = FALSE)
  }

  # One label per Trash Wheel, placed at its last year
  end_points <- plot_data |>
    group_by(wheel) |>
    slice_max(year, n = 1, with_ties = FALSE) |>
    ungroup()

  # A named vector keeps each Trash Wheel's colour fixed,
  # whatever order the data are in (Okabe-Ito colour-blind safe palette)
  wheel_colours <- c(
    "Mister Trash Wheel" = "#0072B2",
    "Professor Trash Wheel" = "#D55E00",
    "Captain Trash Wheel" = "#009E73",
    "Gwynnda Trash Wheel" = "#CC79A7"
  )

  point_shapes <- c(
    "5 or more loads" = 16,
    "Fewer than 5 loads" = 21
  )

  # Label every year for short periods, every second year for long ones,
  # so the year labels never run into each other
  first_year <- min(plot_data$year)
  last_year <- max(plot_data$year)
  year_step <- if (last_year - first_year > 6) 2 else 1

  y_label <- if (measure == "per_load") {
    "Average items per dumpster load"
  } else {
    "Estimated items collected per year"
  }

  ggplot(plot_data, aes(x = year, y = value, colour = wheel)) +
    geom_line(linewidth = 1.1) +
    geom_point(aes(shape = reliability), size = 3.2, stroke = 1.3, fill = "white") +
    ggrepel::geom_text_repel(
      data = end_points,
      aes(label = short_name),
      hjust = 0,
      # Put the names just right of the last year, in the margin,
      # and only move them up or down to stop them overlapping
      xlim = c(last_year + 0.3, Inf),
      direction = "y",
      min.segment.length = Inf,
      size = 4.8,
      fontface = "bold",
      show.legend = FALSE,
      seed = 5523
    ) +
    scale_colour_manual(values = wheel_colours, guide = "none") +
    scale_shape_manual(values = point_shapes, name = "Counted in:") +
    scale_x_continuous(
      breaks = seq(first_year, last_year, by = year_step),
      expand = expansion(mult = c(0.03, 0.03))
    ) +
    scale_y_continuous(
      labels = scales::label_comma(),
      expand = expansion(mult = c(0, 0.08))
    ) +
    coord_cartesian(ylim = c(0, NA), clip = "off") +
    labs(x = NULL, y = y_label) +
    theme_minimal(base_size = 15) +
    theme(
      legend.position = "top",
      legend.justification = "left",
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      # Space on the right for the Trash Wheel names
      plot.margin = ggplot2::margin(10, 95, 10, 10),
      axis.title.y = element_text(margin = ggplot2::margin(r = 10))
    )
}
