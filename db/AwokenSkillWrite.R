rm(list=ls())
library(DBI)
library(RSQLite)

setwd("/Users/yawenliang/Documents/PadMonster")
conn <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")

# a <- dbListTables(conn)
# for (i in 1:length(a)) {
#   assign(a[i], value = dbReadTable(conn, a[i]))
# }

AwokenSkill <- dbReadTable(conn, "AwokenSkill")
AwokenSkill.dt <- fread("//Users/yawenliang/Documents/PadMonster/db/AwokenSkill.csv")
AwokenSkill.dt[, AwokenSkillIconDownload := NULL]
AwokenSkill.dt[, AwokenSkillDescription := NA]
AwokenSkill.dt[, Id:= 1:nrow(AwokenSkill.dt) ]
setcolorder(AwokenSkill.dt, c("Id", "AwokenSkillId"))

dbWriteTable(conn, "AwokenSkill", AwokenSkill.dt, overwrite = TRUE)
dbDisconnect(conn) 
