rm(list=ls())
library(data.table)
library(rvest)
library(stringr)

setwd("//Users/yawenliang/Documents/PadMonster")

conn <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")
Monster.db <- dbReadTable(conn,"Monster")

MonsterIconDownload.dt <- data.table(MonsterIconDownload=character())
MonsterId.dt <- data.table(MonsterId=integer())
for (i in Monster.db$MonsterId) {
  url <- paste0("http://pad.skyozora.com/pets/", i)
  webpage <- read_html(url)
  webnodes <- html_nodes(webpage, 'link[rel="image_src"]')
  MonsterIconDownload <- sapply(webnodes, function(x) xml_attr(x, "href"))
  MonsterIconDownload.dt1 <- data.table(MonsterIconDownload)
  MonsterIconDownload.dt1 <- MonsterIconDownload.dt1[str_detect(MonsterIconDownload, "pets_icon")]
  MonsterIconDownload.dt1 <- MonsterIconDownload.dt1[1]
  MonsterIconDownload.dt <- rbind(MonsterIconDownload.dt, MonsterIconDownload.dt1)
  temp <- data.table(MonsterId=i)
  MonsterId.dt <- rbind(MonsterId.dt, temp)
}

MonsterIcon.dt <- cbind(MonsterId.dt, MonsterIconDownload.dt)

for(i in 1:nrow(MonsterIcon.dt)){
  download.file(MonsterIcon.dt$MonsterIconDownload[i],
                paste0("app/img/MonsterIcon/", MonsterIcon.dt[i,MonsterId], ".png"))
}

MonsterIcon.dt[ , MonsterIconPath := paste0("img/MonsterIcon/", MonsterId, ".png")]





