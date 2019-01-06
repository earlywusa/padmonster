rm(list=ls())
library(data.table)
library(DBI)

if (Sys.info()[["nodename"]] == "JUTONG-X1C") {
  setwd("C:/Users/Jutong/Documents/padmonster")
} else {
  setwd("//Users/yawenliang/Documents/PadMonster")
}

conn <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")
Monster.db <- dbReadTable(conn, "Monster")
Monster.dt <- data.table(Monster.db)
MonsterIcon.dt <- Monster.dt[ , c("MonsterId", "MonsterIconPathDownload")]
for (i in 1:nrow(MonsterIcon.dt)){
  if (file.exists(paste0("app/img/MonsterIcon/", MonsterIcon.dt[i, MonsterId], ".png")) == FALSE) {
      download.file(MonsterIcon.dt$MonsterIconPathDownload[i],
                    paste0("app/img/MonsterIcon/", MonsterIcon.dt[i, MonsterId], ".png"),
                    mode = "wb")
  }
}
