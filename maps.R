####################################################################
# Employment Density Maps for HSI                                  #
# M. Miller, UCLA, 16X                                             #
####################################################################

#Packages requires ggmap, ggplot2
#install.packages("ggmap")
#install.packages("ggplot2")
#install.packages("doBy")
#install.packages("foreign")
#install.packages("maptools")
#install.packages("raster")
#install.packages("rgdal")
#install.packages("rgeos")
#install.packages("dplyr")
install.packages("gpclib", type = "source")

library(ggmap)
library(ggplot2)
library(raster)
library(rgeos)
library(maptools)
library(rgdal)
library(foreign)
library(dplyr)

setwd("C:/Users/Matthew/Dropbox/Research/Urban/Papers/Heat Eq and Urban Structure/Data")

shp <- "C:/Users/Matthew/Desktop/ECON/Research/Urban/Papers/City Center Resurgence/GIS/Working Files/Output"
dta <- "C:/Users/Matthew/Dropbox/Research/Urban/Papers/Delayed Marriage/Draft"

#Load in shapefiles

test <- readOGR(shp,"ua_lehd_acs_0")

#NY example of gentrification and gender plot

test.ny <- fortify(test, region = "GEOID")

ny_map <- get_map(location = "New York, NY", zoom=12)

ncdb_path <- paste(dta, "/ncdb_fortableau.csv", sep = "")

data <- read.csv(ncdb_path, stringsAsFactors = FALSE)
test.ny$id <- as.numeric(test.ny$id)
data$id <- data$geo2010

MapData <- left_join(data, test.ny)

MD.2010 <- MapData[MapData$year == 2010,]
MD.2010 <- MD.2010[MD.2010$mf_rat < 10,]

ggplot() + geom_polygon(data = MD.2010, aes(x=long,y=lat,group=group, fill = MD.2010$mf_rat)) 

persp(test$INTPTLON, test$INTPTLAT, test$EMP_DENS)

#Load in employment LEHD data (Worker Area Characteristics - WAC)

wac <- read.dta("wac_trct_12.dta")

