# Rubbish collected by Baltimore's Trash Wheels

Estimated counts of seven kinds of rubbish in each dumpster load
collected by the four Trash Wheels in Baltimore's harbour, from May 2014
to December 2023. Each row is one kind of rubbish in one dumpster load.

## Usage

``` r
trash_loads
```

## Format

A data frame with 6,951 rows and 8 columns:

- wheel:

  Name of the Trash Wheel, for example "Mister Trash Wheel".

- dumpster:

  Dumpster number. Numbering starts at 1 for each Trash Wheel.

- date:

  Date the dumpster load was collected.

- year:

  Year the load was collected, taken from `date`.

- weight_tons:

  Weight of the whole dumpster load, in US tons.

- volume_cubic_yards:

  Volume of the whole dumpster load, in cubic yards.

- rubbish_type:

  Kind of rubbish counted, for example "Plastic bottles".

- count:

  Estimated number of items of that kind in the load. `NA` means the
  item was not counted for that load.

## Source

TidyTuesday, 5 March 2024,
<https://github.com/rfordatascience/tidytuesday/tree/main/data/2024/2024-03-05>.
Original data from Mr. Trash Wheel, Baltimore's Healthy Harbor
initiative, <https://www.mrtrashwheel.com/>.

## Details

Item counts are estimates made from samples taken during collection, not
exact counts.

A missing count (`NA`) means the item was not counted for that load. It
does not mean that no items were collected. Captain and Gwynnda Trash
Wheels never recorded glass bottles or sports balls, Professor Trash
Wheel never recorded sports balls, and wrappers were recorded for only
some Captain and Gwynnda loads.

The number of dumpster loads changes a lot between Trash Wheels and
years, so yearly totals can be misleading. Use
[`summarise_rubbish()`](https://etc5523-2026.github.io/etc5523-assignment-4-prat0012-ai/reference/summarise_rubbish.md)
to compare the average count per dumpster load instead.

## Examples

``` r
head(trash_loads)
#> # A tibble: 6 × 8
#>   wheel    dumpster date        year weight_tons volume_cubic_yards rubbish_type
#>   <chr>       <dbl> <date>     <int>       <dbl>              <dbl> <chr>       
#> 1 Captain…        1 2018-06-30  2018        0.96                 10 Cigarette b…
#> 2 Captain…        1 2018-06-30  2018        0.96                 10 Glass bottl…
#> 3 Captain…        1 2018-06-30  2018        0.96                 10 Plastic bags
#> 4 Captain…        1 2018-06-30  2018        0.96                 10 Plastic bot…
#> 5 Captain…        1 2018-06-30  2018        0.96                 10 Polystyrene 
#> 6 Captain…        1 2018-06-30  2018        0.96                 10 Sports balls
#> # ℹ 1 more variable: count <dbl>

# Number of dumpster loads collected by each Trash Wheel
plastic_bottles <- trash_loads[trash_loads$rubbish_type == "Plastic bottles", ]
table(plastic_bottles$wheel)
#> 
#>   Captain Trash Wheel   Gwynnda Trash Wheel    Mister Trash Wheel 
#>                    30                   220                   629 
#> Professor Trash Wheel 
#>                   114 
```
