## Pre-processing for BoardGameGeek Data Explorer
## from https://github.com/rasmusgreve/BoardGameGeek
## see also http://fivethirtyeight.com/features/designing-the-best-board-game-on-the-planet/

library(dplyr)
library(RSQLite)

## read csv file downloaded from URL
bgg <- read.csv('boardgamegeek.csv', sep=";")

## extract 'best' number of players
bgg$num_players_best <- as.character(bgg$num_players_best)
rows <- nrow(bgg)
bestplyrs <- vector()
for (r in (1:rows)) {
  if (nchar(bgg$num_players_best[r]) > 0) {
    allvotes <- as.numeric(unlist(strsplit(bgg$num_players_best[r], ",|:")))  # split string of voting info
    votes <- allvotes[seq(2, length(allvotes), by = 2)]  # get the number of votes (the even numbered vector items)
    optimal <- which(votes == max(votes))  # find the most popular number(s) of players for this game
    if (length(optimal) > 1) {
      bestplyrs[r] <- paste(min(optimal):max(optimal), collapse = ",")  # if several equal values, add as comma-separated list
    } else {
      bestplyrs[r] <-  optimal  # if single clear favourite
    }
  } else {
    bestplyrs[r] <- 'unknown'  # if no votes registered
  }
}
bgg$best_num_players <- bestplyrs


## open a new db connection
my_db <- src_sqlite("bgg.sqlite3", create=T)

## populate db with boardgamegeek data URL
bgg_sqlite <- copy_to(my_db, bgg, temporary = FALSE, indexes = list("year_published", "name"))
