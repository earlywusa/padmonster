rm(list=ls())
library(data.table)
library(rvest)

setwd("//Users/yawenliang/Documents/PadMonster/app/img/AwokenSkill")
url <- 'http://pad.skyozora.com/skill/%E8%A6%BA%E9%86%92%E6%8A%80%E8%83%BD%E4%B8%80%E8%A6%BD/'
webpage <- read_html(url)
webnodes <- html_nodes(webpage, '.tooltip')

awokenskillname <- lapply(webnodes, function(x) xml_attr(x, "title"))
iconpath <- lapply(webnodes, function(x) xml_attr(xml_child(x), "src"))

awokenskillname.dt <- data.table(awokenskillname)
iconpath.dt <- data.table(iconpath)

awokenskill.dt <- cbind(awokenskillname.dt, iconpath.dt)
awokenskill.dt <- awokenskill.dt[-1,]
awokenskill.dt[ , AwokenSkillId := 1:nrow(awokenskill.dt)]
setnames(awokenskill.dt,"awokenskillname", "AwokenSkillName")
setnames(awokenskill.dt,"iconpath", "AwokenSkillIconDownload")

#for(i in 1:length(awokenskill.dt$AwokenSkillIconDownload)){
#download.file(paste0(awokenskill.dt$AwokenSkillIconDownload[i]),paste0(awokenskill.dt[i,AwokenSkillId], ".png"))
#}

awokenskill.dt[ ,AwokenSkillIconPath := paste0("img/AwokenSkill/", AwokenSkillId,".png")]

fwrite(awokenskill.dt, file = "//Users/yawenliang/Documents/PadMonster/db/AwokenSkill.csv")

