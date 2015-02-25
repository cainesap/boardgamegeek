## SERVER for BoardGameGeek Data Explorer
## from https://github.com/rasmusgreve/BoardGameGeek
## see also http://fivethirtyeight.com/features/designing-the-best-board-game-on-the-planet/


## Required libraries; use install.packages() if needed
library(ggvis)
library(dplyr)
library(RSQLite)


## Fetch data from database pre-populated by the 'populate_db.R' script
bgdb <- src_sqlite("bgg.sqlite3")  # db connection
bgtbl <- tbl(bgdb, "bgg")  # load 'bgg' table from db

# filter out games with fewer than 50 reviews, selecting specified columns
bgg_games <- filter(bgtbl, users_rated > 49) %>% 
  select(id, name, year_published, min_players, max_players, playingtime, min_age, users_rated,
    average_rating, rating_stddev, num_owned, mechanics)


## Server commands, to run app in conjunction with 'ui.R'
shinyServer(function(input, output, session) {

  ## Filter the data, reacting according to user input
  games <- reactive({
    reviews <- input$reviews
    minyear <- input$minyear
    maxyear <- input$maxyear
    lowermaxplyrs <- input$maxplyrs[1]
    uppermaxplyrs <- input$maxplyrs[2]
    minowned <- input$owned[1]
    maxowned <- input$owned[2]
    mindur <- input$timed[1]
    maxdur <- input$timed[2]

    # apply filters
    g <- bgg_games %>%
      filter(
        users_rated >= reviews,
        year_published >= minyear,
        year_published <= maxyear,
        max_players >= lowermaxplyrs,
        max_players <= uppermaxplyrs,
        num_owned >= minowned,
        num_owned <= maxowned,
        playingtime >= mindur,
        playingtime <= maxdur
      ) %>%
      arrange(year_published)

    # filter by name, if in the input
    if (!is.null(input$bgname) && input$bgname != "") {
      namesearch <- paste0("%", input$bgname, "%")
      g <- g %>% filter(name %like% namesearch)
    }

    # convert to data frame
    g <- as.data.frame(g)

    # filter by mechanics, if selected
    if (!is.null(input$mech) && input$mech != "") {
      mechs <- input$mech
      mechlen <- length(mechs)
      # how many mechanics given? if only 1, a straightfwd grep...
      if (mechlen == 1) {
        g <- g[grep(mechs, g$mechanics, perl = TRUE), ]
      } else {  # if > 1, is it a conjunctive or disjunctive match?
        if (input$mechLogic == "disj") {
	  # build regex for disjunctive grep
      	  regex <- mechs[1]
	  for (n in (2:mechlen)) {
	    regex <- paste0(regex, "|", mechlen[n])
	  }
          g <- g[grep(regex, g$mechanics, perl = TRUE), ]
	} else {
	  # build regex for conjunctive grepl
	  regex <- paste0("(?=.*", mechs[1], ")")
	  for (n in (2:mechlen)) {
	    regex <- paste0(regex, "(?=.*", mechlen[n], ")")
	  }
          g <- g[grepl(regex, g$mechanics, perl = TRUE), ]
	}
      }
    }

    # after all filtering, return data.frame 'g'
    g

  })

  ## Function for generating tooltips, used below on mouse hover
  game_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$id)) return(NULL)

    # pick out the game with this ID
    bgg_games <- isolate(games())
    game <- bgg_games[bgg_games$id == x$id, ]

    # the format and layout of the text in the tooltip
    paste0("<b>", game$name, "</b><br>",
      "year: ", game$year_published, "<br>",
      "ratings: ", game$users_rated, "<br>",
      "ave.rating: ", format(game$average_rating, big.mark = ",", scientific = FALSE)
    )
  }

  ## Reactive visualisation using ggvis
  vis <- reactive({

    # axis labels
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]
    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))

    # if year-of-pub on x-axis, keep limits as the years selected (rather than reacting to data)
    if (input$xvar == "year_published") {
      minx <- as.numeric(input$minyear)
      maxx <- as.numeric(input$maxyear)
      games %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200,
        fillOpacity := 0.2, fillOpacity.hover := 0.5,
        fill = ~year_published, stroke = 1, key := ~id) %>%
      add_tooltip(game_tooltip, "hover") %>%
      add_axis("x", title = xvar_name, format = "####") %>%
      add_axis("y", title = yvar_name, format = "####") %>%
      scale_numeric("x", domain = c(minx, maxx)) %>%
      add_legend("fill", format = "####") %>% hide_legend("stroke")

    } else {  # and otherwise, allow axis limits to adapt to the current data
      games %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200,
        fillOpacity := 0.2, fillOpacity.hover := 0.5,
        fill = ~year_published, stroke = 1, key := ~id) %>%
      add_tooltip(game_tooltip, "hover") %>%
      add_axis("x", title = xvar_name, format = "####") %>%
      add_axis("y", title = yvar_name, format = "####") %>%
      add_legend("fill", format = "####") %>% hide_legend("stroke")
    }
  })

  ## Plot
  vis %>% bind_shiny("plot1")

  ## Number of games in the current dataset [reactive]
  output$n_games <- renderText({ nrow(games()) })

})
