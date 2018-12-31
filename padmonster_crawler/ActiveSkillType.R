rm(list=ls())
library(data.table)
library(rvest)
library(DBI)
library(RSQLite)

setwd("//Users/yawenliang/Documents/PadMonster")

# Get active skill type list

url <- 'http://pad.skyozora.com/skill/%E4%B8%BB%E5%8B%95%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/'
webpage <- read_html(url)
webnodes1 <- html_nodes(webpage, 'h3')
webnodes2 <- html_nodes(webpage, 'table')

ActiveSkillType.ls <- as.list(html_text(webnodes1))
ActiveSkillType.dt <- data.table(ActiveSkillType.ls)
ActiveSkillContent.ls_ <- lapply(webnodes2, function(x) html_text(html_nodes(x, "tr td")))
ActiveSkillContent.ls_ <- ActiveSkillContent.ls_[4:(length(ActiveSkillContent.ls_ )-1)]


wide <- function(x){
  name_index <- seq(from = 1, to = length(x)-1, by = 2)
  description_index <- name_index+1
  name <- x[name_index]
  description <- x[description_index]
  data.table(ActiveSkillName = name, ActiveSkillDescription = description)
}
ActiveSkillContent.ls <- lapply(ActiveSkillContent.ls_, wide)


ActiveSkillType.ls <- list()
for (i in 1:length(ActiveSkillType.ls)){
  ActiveSkillType.ls[[i]] <- ActiveSkillContent.ls[[i]][, ActiveSkillType := ActiveSkillType.ls[[i]]]
}

ActiveSkillType.dt1 <- rbindlist(ActiveSkillType.ls)


# Get ActiveSkillId

conn <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")
miao <- dbReadTable(conn,"ActiveSkill")
