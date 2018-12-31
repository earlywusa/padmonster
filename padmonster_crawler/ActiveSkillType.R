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
ActiveSkill.ls <- lapply(webnodes2, function(x) html_text(html_nodes(x, "tr td")))
text3 <- text2[4:(length(text2)-1)]

text3_upgrade <- lapply(text3, data.table)


text1.dt <- data.table(text1)
text3.dt <- data.table(text3)

miao <- combine.lists(text1, text3)






url <- 'http://pad.skyozora.com/pets/'
webpage <- read_html(url)
webnodes <- html_nodes(webpage, '#skill option')



ActiveSkillType <- sapply(webnodes, function(x) xml_attr(x, "value"))
ActiveSkillType.dt <- data.table(ActiveSkillType)
ActiveSkillType.dt <- ActiveSkillType.dt[2:nrow(ActiveSkillType.dt), ]

# Categorize active skills
conn <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")
ActiveSkill <- dbReadTable(conn, "ActiveSkill")

# Write into database