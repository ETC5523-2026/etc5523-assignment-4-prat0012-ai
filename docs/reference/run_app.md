# Launch the Trash Wheel rubbish explorer

Opens a Shiny app for Healthy Harbor volunteers and community educators.
It helps them see which kinds of rubbish each Trash Wheel collects most
per dumpster load, and whether that is going up or down over time. The
app uses the
[trash_loads](https://etc5523-2026.github.io/etc5523-assignment-4-prat0012-ai/reference/trash_loads.md)
data,
[`summarise_rubbish()`](https://etc5523-2026.github.io/etc5523-assignment-4-prat0012-ai/reference/summarise_rubbish.md)
and
[`plot_rubbish()`](https://etc5523-2026.github.io/etc5523-assignment-4-prat0012-ai/reference/plot_rubbish.md)
from this package, so it needs no other files.

## Usage

``` r
run_app()
```

## Value

No return value. The function is called to open the app.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
