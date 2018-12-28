rm(list=ls())
library(data.table)
library(rvest)
library(DBI)
library(RSQLite)

setwd("//Users/yawenliang/Documents/PadMonster")

## 1. Scrape awoken skill data

url <- 'http://pad.skyozora.com/skill/%E8%A6%BA%E9%86%92%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/'
webpage <- read_html(url)
webnodes <- html_nodes(webpage, '.tooltip')

AwokenSkillName <- sapply(webnodes, function(x) xml_attr(x, "title"))
AwokenSkillIconDownload <- sapply(webnodes, function(x) xml_attr(xml_child(x), "src"))

AwokenSkillName.dt <- data.table(AwokenSkillName)
AwokenSkillIconDownload.dt <- data.table(AwokenSkillIconDownload)

AwokenSkill.dt <- cbind(AwokenSkillName.dt, AwokenSkillIconDownload.dt)
AwokenSkill.dt <- AwokenSkill.dt[-1,]
AwokenSkill.dt[ , AwokenSkillId := 1:nrow(AwokenSkill.dt)]
#AwokenSkill.dt[ ,AwokenSkillIconPath := paste0("img/AwokenSkill/", AwokenSkillId,".png")]


for(i in 1:length(AwokenSkill.dt$AwokenSkillIconDownload)){
download.file(paste0(AwokenSkill.dt$AwokenSkillIconDownload[i]), 
              paste0("app/img/AwokenSkill/", AwokenSkill.dt[i,AwokenSkillId], ".png"))
}



## 2. Write the data into database
conn <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")

# a <- dbListTables(conn)
# for (i in 1:length(a)) {
#   assign(a[i], value = dbReadTable(conn, a[i]))
# }
# AwokenSkill <- dbReadTable(conn, "AwokenSkill")

AwokenSkill.dt[, AwokenSkillDescription := NA]
AwokenSkill.dt[, Id:= 1:nrow(AwokenSkill.dt) ]
setcolorder(AwokenSkill.dt, c("Id", "AwokenSkillId"))

dbWriteTable(conn, "AwokenSkill", AwokenSkill.dt, overwrite = TRUE)
dbDisconnect(conn) 
