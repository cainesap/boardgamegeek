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
  titlePanel("BoardGameGeek Data Explorer"),

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
        textInput("minyear", label = "Earliest year of publication (>=-3500 [yes, 3500 B.C.!])", value = "1977"),
        textInput("maxyear", label = "Latest year of publication (<= 2014)", value = "2014"),
        sliderInput("owned", "Number of copies owned", 0, 60000, value = c(0, 60000), step = 1000),
        sliderInput("timed", "Duration of game (mins)", 0, 720, value = c(0, 720), step = 10),
        sliderInput("maxplyrs", "Maximum number of players", 0, 20, value = c(0, 10), step = 1)
      )
    ),

    ## RH COLUMN
    column(9,

      ## INFO PANEL
      wellPanel(
        span("Number of boardgames selected:", textOutput("n_games"),
        tags$small(paste0(
          "There are a total of 5060 games in this dataset."))
        )
      ),

      ## PLOTS PANEL
      ggvisOutput("plot1"),
      wellPanel(
        textInput("bgname", "Name contains (e.g. Monopoly)")
      ),

      ## SOURCES / LINKS
      wellPanel(
        span(
  	  "inspiration: ", tags$a(href="http://fivethirtyeight.com/features/designing-the-best-board-game-on-the-planet/", "@ollie on FiveThirtyEight"),
	  " | ",
  	  "data source: ", tags$a(href="https://github.com/rasmusgreve/BoardGameGeek", "@rasmusgreve on GitHub"),
	  " | ",
  	  "code: ", tags$a(href="https://github.com/cainesap/boardgamegeek", "@cainesap on GitHub"),
	  " | ",
	  "original design: ", tags$a(href="http://shiny.rstudio.com/gallery/movie-explorer.html", "@garrettgman's Shiny Movie Explorer")
        )
      ),

      ## MECHANICS
      wellPanel(
        h6("Mechanics:"),
	checkboxInput("mechBool", "Show mechanics?", value = FALSE),
        column(3,
	  uiOutput("mechDynRadio")
	),
	column(6,
	  uiOutput("mechDynChecks")
	)
      )
    )

  )
))
