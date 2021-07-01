# clears console
cat("\014")  

library(dplyr)
library(stargazer)
library(maptools)
library(rgeos)
library(tidyverse)
library(rgdal)
library(ggthemes)
library(gridExtra)
library(viridis)

# read data
data <- read.csv("C:\Users\gelly\Desktop\Github\LondonHousing\Output\London Merged Data.csv", header=TRUE)

# lag crime variable
data <- 
	data %>%
	group_by(borough) %>%
	mutate(lag_totalCrime = lag(totalCrime, n = 1, default = NA))

# change date into factor
data$date_factor <- factor(data$date)

# OLS with fixed effects
model1 = lm(average_price ~ lag_totalCrime + borough-1 + date_factor, data=data)
model2 = lm(houses_sold ~ lag_totalCrime + borough-1 + date_factor, data=data)
sustargazer(model1, model2)

# only keep most recent data
data <-
	data %>% 
	group_by(borough) %>% 
	arrange(date) %>%  
	slice(n())

# read London map
londonMap <- readOGR("C:\Users\gelly\Desktop\Github\LondonHousing\Raw Data\London Spatial Data\", "London_Borough_Excluding_MHW") %>%
  spTransform(CRS("+proj=longlat +datum=WGS84"))

londonMap@data$id <- row.names(londonMap@data)
londonMap.points <- fortify(londonMap , region = "id")
londonMap.df <- merge(londonMap.points, londonMap@data, by = "id")

# merge data with london map
londonMap.df <- merge(londonMap.df, data, by.x="NAME", by.y="borough", all=TRUE)
londonMap.df <- londonMap.df[order(londonMap.df$order),]

# plot data on London map
plot1 <- ggplot(londonMap.df, aes(long, lat, group = group, fill=average_price))+geom_polygon()+coord_map()+labs(fill="Housing Price")+scale_fill_continuous(trans='reverse', guide=guide_legend(reverse=TRUE))
ggsave("C:\Users\gelly\Desktop\Github\Output\LondonHousing/House Prices.png")
plot2 <- ggplot(londonMap.df, aes(long, lat, group = group, fill=totalCrime))+geom_polygon()+coord_map()+labs(fill="Total Crime")+scale_fill_viridis(option="rocket", trans='reverse', breaks=c(500,1000,1500,2000), guide=guide_legend(reverse=TRUE))
ggsave("C:\Users\gelly\Desktop\Github\Output\LondonHousing/Total Crime.png")
grid.arrange(plot1, plot2, ncol=2)