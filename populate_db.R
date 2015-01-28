## Pre-processing for BoardGameGeek Data Explorer
## from https://github.com/rasmusgreve/BoardGameGeek
## see also http://fivethirtyeight.com/features/designing-the-best-board-game-on-the-planet/

library(dplyr)
library(RSQLite)

## read csv file downloaded from URL
bgg <- read.csv('boardgamegeek.csv', sep=";")

## open a new db connection
my_db <- src_sqlite("bgg.sqlite3", create=T)

## populate db with boardgamegeek data URL
bgg_sqlite <- copy_to(my_db, bgg, temporary = FALSE, indexes = list("year_published", "name"))
