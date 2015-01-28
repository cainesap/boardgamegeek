## UI for BoardGameGeek Data Explorer
## from https://github.com/rasmusgreve/BoardGameGeek
## see also http://fivethirtyeight.com/features/designing-the-best-board-game-on-the-planet/


## Required library; use install.packages() if necessary
library(ggvis)


## Javascript for the dropdown menu
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}


## UI
shinyUI(fluidPage(

  ## TITLE
  titlePanel("Boardgamegeek Data Explorer"),

  ## NEW ROW
  fluidRow(

    ## LH COLUMN
    column(3,

      ## AXIS CHOICES
      wellPanel(
        h4("Axes"),
        selectInput("xvar", "X-axis variable", axis_vars, selected = "year_published"),
        selectInput("yvar", "Y-axis variable", axis_vars, selected = "average_rating")
      ),

      ## FILTERS PANEL
      wellPanel(
        h4("Filters"),
        sliderInput("reviews", "Minimum number of ratings on BoardGameGeek (>99)",
          100, 45000, 3000, step = 100),
        textInput("minyear", label = "Earliest year of publication (>=0)", value = "1977"),
        textInput("maxyear", label = "Latest year of publication (<=2014)", value = "2014"),
        sliderInput("owned", "Number of copies owned", 0, 60000, value = c(0, 60000), step = 1000),
        sliderInput("timed", "Duration of game (mins)", 0, 60000, value = c(0, 60000), step = 10),
        sliderInput("maxplyrs", "Max number of players", 0, 20, value = 6, step = 1)
      )
    ),

    ## RH COLUMN
    column(9,

      ## INFO PANEL
      wellPanel(
        span("Number of boardgames selected:", textOutput("n_games"),
        tags$small(paste0(
          "Note: there are a total of 5067 games in this dataset, extracted from boardgamegeek via @rasmusgreve on GitHub [https://github.com/rasmusgreve/BoardGameGeek]"
        ))
        )
      ),

      ## PLOTS PANEL
      ggvisOutput("plot1"),
      wellPanel(
        textInput("bgname", "Name contains (e.g. Monopoly)")
      )

    )
  )
))
