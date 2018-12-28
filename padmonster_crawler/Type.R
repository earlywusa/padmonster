rm(list=ls())
library(data.table)
library(rvest)
library(stringr)

setwd("//Users/yawenliang/Documents/PadMonster")


## 1. Scrape awoken skill data

url <- 'http://pad.skyozora.com/pets/'
webpage <- read_html(url)
webnodes <- html_nodes(webpage, '#type1 label img')

TypeIconDownload <- sapply(webnodes, function(x){xml_attr(x,"src")})
Type.dt <- data.table(TypeIconDownload)
Type.dt[ , Id := 1:nrow(Type.dt)]
Type.dt[ , TypeId := 1:nrow(Type.dt)]
Type.dt[ , TypeName := str_match(Type.dt$TypeIconDownload, "\\/(\\w+)\\.png")[,2]]
Type.dt[ ,TypeIconDownload := paste0("http://pad.skyozora.com/",Type.dt$TypeIconDownload)]
#Type.dt[ ,TypeIconPath := paste0("img/Type/", TypeId,".png")]


for(i in 1:length(Type.dt$TypeIconDownload)){
  download.file(Type.dt$TypeIconDownload[i],
                paste0("app/img/Type/", Type.dt[i,TypeId], ".png"))
}

setcolorder(Type.dt, c("Id", "TypeId", "TypeName", "TypeIconDownload"))

## 2. Write the data into database
conn <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")

dbWriteTable(conn, "Type", Type.dt, overwrite = TRUE)
dbDisconnect(conn) 
