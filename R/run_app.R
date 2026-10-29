#' Launch the Trash Wheel rubbish explorer
#'
#' Opens a Shiny app for Healthy Harbor volunteers and community educators.
#' It helps them see which kinds of rubbish each Trash Wheel collects most
#' per dumpster load, and whether that is going up or down over time. The
#' app uses the [trash_loads] data, [summarise_rubbish()] and
#' [plot_rubbish()] from this package, so it needs no other files.
#'
#' @return No return value. The function is called to open the app.
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#' @importFrom bslib bs_theme
#' @export
run_app <- function() {
  # system.file() finds the app folder inside the installed package,
  # wherever the package is installed on this computer
  app_dir <- system.file("app", package = "trashwheels")

  if (app_dir == "") {
    stop("Could not find the app. Try reinstalling trashwheels.", call. = FALSE)
  }

  # Open in the web browser, which gives the chart more room than
  # the RStudio Viewer pane
  shiny::runApp(app_dir, display.mode = "normal", launch.browser = TRUE)
}
