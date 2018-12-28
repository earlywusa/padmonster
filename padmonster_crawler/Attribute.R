rm(list=ls())
library(data.table)
library(rvest)

setwd("//Users/yawenliang/Documents/PadMonster")


## 1. Scrape awoken skill data

url <- 'http://pad.skyozora.com/pets/'
webpage <- read_html(url)
webnodes <- html_nodes(webpage, '#property1 label img')

AttributeIconDownload <- sapply(webnodes, function(x){xml_attr(x,"src")})
Attribute.dt <- data.table(AttributeIconDownload)
Attribute.dt[ , Id := 1:nrow(Attribute.dt)]


Attribute.dt[ , AttributeName := c("火", "水", "木", "光", "暗")]
# Attribute.dt[ , AttributeIconPath := paste0("img/Attribute/", AttributeFileName,".png")]
Attribute.dt[ , AttributeIconDownload := paste0("http://pad.skyozora.com/",Attribute.dt$AttributeIconDownload)]

for(i in 1:length(Attribute.dt$AttributeIconDownload)){
  download.file(Attribute.dt$AttributeIconDownload[i], 
                paste0("app/img/Attribute/", Attribute.dt[i,Id], ".png"))
}

setcolorder(Attribute.dt, c("Id", "AttributeName", "AttributeIconDownload"))

## 2. Write the data into database
conn <- dbConnect(drv = RSQLite::SQLite(), "db/padmonster.sqlite3")
dbWriteTable(conn, "Attribute", Attribute.dt, overwrite = TRUE)
dbDisconnect(conn) 

