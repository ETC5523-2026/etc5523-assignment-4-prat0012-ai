# Trash Wheel rubbish explorer
#
# Intended user: a volunteer or community educator with Baltimore's
# Healthy Harbor initiative.
# Question: which kinds of rubbish does each Trash Wheel collect most
# per dumpster load, and is that going up or down over time?
#
# All data come from the installed trashwheels package. The app does not
# read any CSV or other file when it runs.

library(shiny)
library(bslib)
library(trashwheels)

# Choices for the controls, taken from the package data
item_choices <- sort(unique(trash_loads$rubbish_type))
wheel_choices <- c(
  "Mister Trash Wheel",
  "Professor Trash Wheel",
  "Captain Trash Wheel",
  "Gwynnda Trash Wheel"
)
first_year <- min(trash_loads$year)
last_year <- max(trash_loads$year)

# Turns a number into readable text, for example 12345.6 -> "12,346"
nice_number <- function(x) {
  format(round(x), big.mark = ",", scientific = FALSE, trim = TRUE)
}

# UI: what the user sees ---------------------------------------------

ui <- page_sidebar(
  title = "Trash Wheel rubbish explorer",
  theme = bs_theme(
    version = 5,
    primary = "#1b365d",
    bg = "#faf9f6",
    fg = "#1f2933"
  ),
  tags$head(tags$link(rel = "stylesheet", href = "styles.css")),

  sidebar = sidebar(
    width = 320,
    selectInput(
      "item",
      "1. Choose a kind of rubbish",
      choices = item_choices,
      selected = "Plastic bottles"
    ),
    p(class = "control-help",
      "The chart shows only this kind of rubbish."),

    checkboxGroupInput(
      "wheels",
      "2. Choose the Trash Wheels to compare",
      choices = wheel_choices,
      selected = wheel_choices
    ),
    p(class = "control-help",
      "Each ticked Trash Wheel gets its own line. They started at",
      "different times: Mister in 2014, Professor in 2017, Captain in",
      "2018 and Gwynnda in 2021."),

    sliderInput(
      "years",
      "3. Choose the years",
      min = first_year,
      max = last_year,
      value = c(first_year, last_year),
      step = 1,
      sep = ""
    ),
    p(class = "control-help",
      "Drag either end to narrow the period."),

    radioButtons(
      "measure",
      "4. Choose what to measure",
      choices = c(
        "Average items per dumpster load" = "per_load",
        "Total items per year" = "total"
      ),
      selected = "per_load"
    ),
    p(class = "control-help",
      "The average is the fair comparison. Totals grow when a Trash Wheel",
      "fills more dumpsters, so a busy year can look worse even if each",
      "load holds less rubbish.")
  ),

  div(
    class = "intro-box",
    p(class = "intro-user",
      "For Healthy Harbor volunteers and community educators"),
    p(class = "intro-question",
      "Which kinds of rubbish does each Trash Wheel collect most, and is it",
      "going up or down over time?"),
    p("Pick a kind of rubbish on the left. The chart and table update to",
      "show how much of it each Trash Wheel pulls out of the water.")
  ),

  navset_card_tab(
    nav_panel(
      "Trend over time",
      h4(class = "headline", textOutput("headline", inline = TRUE)),
      p(class = "how-to-read", textOutput("how_to_read", inline = TRUE)),
      plotOutput("trend_plot", height = "430px"),
      uiOutput("data_notes")
    ),
    nav_panel(
      "Yearly numbers",
      p(class = "how-to-read",
        "Each row is one Trash Wheel in one year. 'Loads counted' can be",
        "smaller than 'Loads collected' when the item was not counted in",
        "every load. 'Not counted' means no record, not zero."),
      tableOutput("summary_table")
    ),
    nav_panel(
      "About the data",
      h4("What the fields mean"),
      tags$dl(
        class = "field-list",
        tags$dt("Trash Wheel"),
        tags$dd("A water wheel in Baltimore's harbour that lifts floating",
                "rubbish out of the water and drops it into a dumpster."),
        tags$dt("Dumpster load"),
        tags$dd("One full dumpster of rubbish, emptied and recorded by",
                "the Trash Wheel team."),
        tags$dt("Items counted"),
        tags$dd("Estimated number of items of the chosen kind. The team",
                "counts a sample of each dumpster and scales it up, so",
                "every number is an estimate."),
        tags$dt("Average items per dumpster load"),
        tags$dd("Total items divided by the number of loads in which the",
                "item was counted."),
        tags$dt("Loads counted"),
        tags$dd("Loads in which this kind of rubbish was counted. Some",
                "Trash Wheels never counted some items, for example",
                "Gwynnda never counted glass bottles.")
      ),
      h4("Source and limits"),
      p("Data from Mr. Trash Wheel, part of Baltimore's Healthy Harbor",
        "initiative, shared through TidyTuesday (5 March 2024). It covers",
        "993 dumpster loads from May 2014 to December 2023."),
      p("The data show what was collected, not why. A change over time",
        "could come from less litter, different weather and rainfall, or",
        "changes in how the counts were made.")
    )
  )
)

# Server: how the outputs respond to the inputs ------------------------

server <- function(input, output, session) {

  # 1. One shared calculation. Every output below reads from this, so the
  #    headline, chart, notes and table always describe the same selection.
  selected_summary <- reactive({
    if (length(input$wheels) == 0) {
      return(NULL)
    }
    summarise_rubbish(
      trash_loads,
      item = input$item,
      wheels = input$wheels,
      years = input$years
    )
  }, label = "selected_summary")

  # 2. Explain what is wrong when there is nothing fair to show.
  #    An empty string means the selection is fine.
  problem <- reactive({
    summary <- selected_summary()

    if (is.null(summary)) {
      "Tick at least one Trash Wheel on the left to see results."
    } else if (nrow(summary) == 0) {
      paste0(
        "None of the chosen Trash Wheels collected any loads between ",
        input$years[1], " and ", input$years[2], ". Mister Trash Wheel has ",
        "records from 2014, Professor from 2017, Captain from 2018 and ",
        "Gwynnda from 2021. Try a wider range of years or tick another ",
        "Trash Wheel."
      )
    } else if (all(summary$loads_counted == 0)) {
      paste0(
        input$item, " were not counted by ",
        paste(input$wheels, collapse = " or "), " in these years. ",
        "A blank record means 'not counted', not zero, so there is nothing ",
        "fair to show. Try another kind of rubbish, or tick Mister Trash ",
        "Wheel, which counted all seven kinds."
      )
    } else {
      ""
    }
  }, label = "problem")

  # 3. The Trash Wheel with the highest value for the chosen measure
  wheel_totals <- reactive({
    req(problem() == "")
    summary <- selected_summary()
    counted <- summary[summary$loads_counted > 0, ]

    totals <- aggregate(
      cbind(total_items, loads_counted) ~ wheel,
      data = counted,
      FUN = sum
    )
    totals$items_per_load <- totals$total_items / totals$loads_counted
    totals
  }, label = "wheel_totals")

  top_wheel <- reactive({
    totals <- wheel_totals()
    if (input$measure == "per_load") {
      totals[which.max(totals$items_per_load), ]
    } else {
      totals[which.max(totals$total_items), ]
    }
  }, label = "top_wheel")

  # Headline: states the result for the current selection
  output$headline <- renderText({
    top <- top_wheel()
    item <- tolower(input$item)
    period <- paste0("from ", input$years[1], " to ", input$years[2])

    if (input$measure == "per_load") {
      paste0(
        top$wheel, " collected the most ", item, " per dumpster load ",
        period, ": about ", nice_number(top$items_per_load), " per load"
      )
    } else {
      paste0(
        top$wheel, " collected the most ", item, " in total ", period,
        ": about ", nice_number(top$total_items), " items"
      )
    }
  })

  # How to read the chart, plus the change at the top Trash Wheel
  output$how_to_read <- renderText({
    summary <- selected_summary()
    top <- top_wheel()

    if (input$measure == "per_load") {
      measure_text <- paste(
        "Each line shows the average number of items in one dumpster load.",
        "A higher line means more of this rubbish in every load, and a",
        "falling line means each load holds less of it."
      )
      value_column <- "items_per_load"
      value_name <- "the average per load"
    } else {
      measure_text <- paste(
        "Each line shows the estimated total for each year. Totals rise",
        "when more dumpsters are filled, so switch to the average to",
        "compare Trash Wheels fairly."
      )
      value_column <- "total_items"
      value_name <- "the yearly total"
    }

    # Compare the first and last counted year for the top Trash Wheel
    rows <- summary[summary$wheel == top$wheel & summary$loads_counted > 0, ]
    first_row <- rows[which.min(rows$year), ]
    last_row <- rows[which.max(rows$year), ]

    change_text <- ""
    if (nrow(rows) > 1) {
      first_value <- first_row[[value_column]]
      last_value <- last_row[[value_column]]
      direction <- if (last_value < first_value) "fell" else "rose"
      change_text <- paste0(
        " At ", top$wheel, ", ", value_name, " ", direction, " from ",
        nice_number(first_value), " in ", first_row$year, " to ",
        nice_number(last_value), " in ", last_row$year, "."
      )
    }

    paste0(measure_text, change_text)
  })

  # The chart. If there is a problem, validate() shows the message here
  # instead of an empty chart.
  output$trend_plot <- renderPlot({
    validate(need(problem() == "", problem()))
    plot_rubbish(selected_summary(), measure = input$measure)
  }, res = 100, height = 430, width = function() {
    # Never draw the chart smaller than 500 by 430 pixels. In a very
    # narrow window, or while its tab is hidden, the margins would not
    # fit and R would stop with an error. The chart scrolls sideways
    # instead.
    max(session$clientData$output_trend_plot_width, 500)
  })

  # Warnings about weak evidence in the current selection
  output$data_notes <- renderUI({
    req(problem() == "")
    summary <- selected_summary()
    item <- tolower(input$item)
    notes <- list()

    # Ticked Trash Wheels that have no line
    not_shown <- setdiff(input$wheels, summary$wheel[summary$loads_counted > 0])
    for (wheel in not_shown) {
      notes <- c(notes, list(tags$li(paste0(
        wheel, " has no counted ", item, " in these years, so it has no line."
      ))))
    }

    # Averages built on very few loads
    few <- summary[summary$loads_counted > 0 & summary$loads_counted < 5, ]
    if (nrow(few) > 0) {
      few_text <- paste(sub(" Trash Wheel", "", few$wheel), few$year)
      notes <- c(notes, list(tags$li(paste0(
        "Hollow points use fewer than 5 counted loads (",
        paste(few_text, collapse = ", "),
        "). One unusual load can move these a lot, so treat them with care."
      ))))
    }

    # Years where the item was counted in only some loads
    partial <- summary[summary$loads_counted > 0 &
                         summary$loads_counted < summary$loads_collected, ]
    if (nrow(partial) > 0) {
      worst <- partial[which.min(partial$loads_counted / partial$loads_collected), ]
      notes <- c(notes, list(tags$li(paste0(
        "Some years count this item in only part of the loads. For example, ",
        worst$wheel, " counted ", item, " in ", worst$loads_counted, " of ",
        worst$loads_collected, " loads in ", worst$year,
        ". See the Yearly numbers tab."
      ))))
    }

    notes <- c(notes, list(tags$li(paste(
      "Counts are estimates from samples of each dumpster. Source: Mr. Trash",
      "Wheel (Healthy Harbor) via TidyTuesday."
    ))))

    div(class = "data-notes", h5("Read with care"), tags$ul(notes))
  })

  # Table of the same summary that the chart uses
  output$summary_table <- renderTable({
    validate(need(problem() == "", problem()))
    summary <- selected_summary()

    data.frame(
      "Trash Wheel" = summary$wheel,
      "Year" = as.character(summary$year),
      "Loads collected" = summary$loads_collected,
      "Loads counted" = summary$loads_counted,
      "Total items" = ifelse(
        is.na(summary$total_items), "Not counted",
        nice_number(summary$total_items)
      ),
      "Items per load" = ifelse(
        is.na(summary$items_per_load), "Not counted",
        nice_number(summary$items_per_load)
      ),
      check.names = FALSE
    )
  }, align = "llrrrr", striped = TRUE)
}

shinyApp(ui, server)
