# Plot rubbish counts over time for each Trash Wheel

Draws one line per Trash Wheel from the output of
[`summarise_rubbish()`](https://etc5523-2026.github.io/etc5523-assignment-4-prat0012-ai/reference/summarise_rubbish.md).
Each line is labelled at its last year, so no legend lookup is needed.
Hollow points mark years where fewer than five loads were counted,
because an average built on so few loads can jump around a lot.

## Usage

``` r
plot_rubbish(summary, measure = "per_load")
```

## Arguments

- summary:

  A data frame returned by
  [`summarise_rubbish()`](https://etc5523-2026.github.io/etc5523-assignment-4-prat0012-ai/reference/summarise_rubbish.md).

- measure:

  What to show on the vertical axis: `"per_load"` for the average number
  of items per dumpster load (the fair comparison), or `"total"` for the
  estimated total number of items each year.

## Value

A ggplot object. Years where the item was not counted are left out of
the plot.

## Examples

``` r
bottles <- summarise_rubbish(trash_loads, item = "Plastic bottles")

# The fair comparison: average plastic bottles per dumpster load
plot_rubbish(bottles, measure = "per_load")


# Yearly totals depend on how many loads were collected each year
plot_rubbish(bottles, measure = "total")
```
