rm(list=ls())
library(DBI)
library(RSQLite)

setwd("/Users/yawenliang/Documents/PadMonster")
con <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")

awoken_skills <- dbReadTable(con, "awoken_skills")