rm(list=ls())
library(data.table)

setwd("//Users/yawenliang/Documents/PadMonster")

conn <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")
Monster.db <- dbReadTable(conn,"Monster")
Monster.dt <- data.table(Monster.db)
MonsterIcon.dt <- Monster.dt[ , c("MonsterId", "MonsterIconPathDownload")]
for (i in 1:nrow(MonsterIcon.dt)){
  download.file(MonsterIcon.dt$MonsterIconPathDownload[i],
                paste0("app/img/MonsterIcon/", MonsterIcon.dt[i,MonsterId], ".png"))
}
