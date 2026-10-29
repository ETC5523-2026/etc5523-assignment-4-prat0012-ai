# Summarise rubbish counts by Trash Wheel and year

Adds up the estimated number of items of one kind of rubbish for each
Trash Wheel and year, then divides by the number of dumpster loads in
which that item was counted. The average per load is a fairer way to
compare years and Trash Wheels than the yearly total, because the number
of loads collected changes a lot from year to year.

## Usage

``` r
summarise_rubbish(
  data,
  item,
  wheels = unique(data$wheel),
  years = range(data$year)
)
```

## Arguments

- data:

  A data frame with the same columns as
  [trash_loads](https://etc5523-2026.github.io/etc5523-assignment-4-prat0012-ai/reference/trash_loads.md),
  usually `trash_loads` itself.

- item:

  One kind of rubbish, for example `"Plastic bottles"`. Run
  `unique(trash_loads$rubbish_type)` to see all seven options.

- wheels:

  One or more Trash Wheel names. The default uses every Trash Wheel in
  `data`.

- years:

  Two years giving the first and last year to include, for example
  `c(2018, 2023)`. The default uses every year in `data`.

## Value

A data frame with one row per Trash Wheel and year, and these columns:

- `wheel`: name of the Trash Wheel.

- `year`: year of collection.

- `loads_collected`: number of dumpster loads collected that year.

- `loads_counted`: number of those loads in which `item` was counted.

- `total_items`: estimated number of items in the counted loads.

- `items_per_load`: `total_items` divided by `loads_counted`.

`total_items` and `items_per_load` are `NA` when `item` was not counted
in any load that year. This means "not recorded", not zero. A Trash
Wheel with no loads in the chosen years has no rows.

## Examples

``` r
# Plastic bottles per dumpster load at every Trash Wheel
summarise_rubbish(trash_loads, item = "Plastic bottles")
#> # A tibble: 26 × 6
#>    wheel           year loads_collected loads_counted total_items items_per_load
#>    <chr>          <int>           <int>         <int>       <dbl>          <dbl>
#>  1 Captain Trash…  2018               6             6       10340          1723.
#>  2 Captain Trash…  2019               5             5        6233          1247.
#>  3 Captain Trash…  2020               6             6        8190          1365 
#>  4 Captain Trash…  2021               6             6        7420          1237.
#>  5 Captain Trash…  2022               3             3        4480          1493.
#>  6 Captain Trash…  2023               4             4        7200          1800 
#>  7 Gwynnda Trash…  2021              51            51       58232          1142.
#>  8 Gwynnda Trash…  2022              83            83      119310          1437.
#>  9 Gwynnda Trash…  2023              86            86      151870          1766.
#> 10 Mister Trash …  2014              44            44       82590          1877.
#> # ℹ 16 more rows

# Cigarette butts at Mister Trash Wheel from 2019 to 2023
summarise_rubbish(
  trash_loads,
  item = "Cigarette butts",
  wheels = "Mister Trash Wheel",
  years = c(2019, 2023)
)
#> # A tibble: 5 × 6
#>   wheel            year loads_collected loads_counted total_items items_per_load
#>   <chr>           <int>           <int>         <int>       <dbl>          <dbl>
#> 1 Mister Trash W…  2019              66            66      329120          4987.
#> 2 Mister Trash W…  2020              72            72      335900          4665.
#> 3 Mister Trash W…  2021              58            58      213100          3674.
#> 4 Mister Trash W…  2022              57            57      205000          3596.
#> 5 Mister Trash W…  2023              62            62      212080          3421.

# Gwynnda never counted glass bottles, so the averages are NA
summarise_rubbish(
  trash_loads,
  item = "Glass bottles",
  wheels = "Gwynnda Trash Wheel"
)
#> # A tibble: 3 × 6
#>   wheel            year loads_collected loads_counted total_items items_per_load
#>   <chr>           <int>           <int>         <int>       <dbl>          <dbl>
#> 1 Gwynnda Trash …  2021              51             0          NA             NA
#> 2 Gwynnda Trash …  2022              83             0          NA             NA
#> 3 Gwynnda Trash …  2023              86             0          NA             NA
```
