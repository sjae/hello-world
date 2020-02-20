#this is first R script to parse web page in API 
install.packages("dplyr")
library(dplyr)

#data upload
d <- getwd()
setwd(d)

data <- read.csv("soccer_game.csv")

KK <- data %>% group_by(team) %>% tally() %>% arrage


write.csv(KK,"C:/Users/user/Desktop/testdata/myfirstfile2.csv")

# test file works fine upto here!!

