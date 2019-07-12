# Detect proper script_path (you cannot use args yet as they are build with tools in set_env.r)
script_path <- (function() {
  args <- commandArgs(trailingOnly = FALSE)
  script_path <- dirname(sub("--file=", "", args[grep("--file=", args)]))
  if (!length(script_path)) {
    return("R")
  }
  if (grepl("darwin", R.version$os)) {
    script_path <- gsub("~\\+~", " ", script_path) # on MacOS ~+~ in path denotes whitespace
  }
  return(normalizePath(script_path))
})()

# Setting .libPaths() to point to libs folder
source(file.path(script_path, "set_env.R"), chdir = T)

config <- load_config()
args <- args_parser()

library(dplyr)
library(data.table)
library(DataPreparation)

#The  datasets

train <- read.csv("/Users/urszulabialonczyk/Documents/Wlog/Rossmann/rossmann-store-sales/train.csv", stringsAsFactors = FALSE)

glimpse(train)
summary(train)
head(train)

glimpse(test)
summary(test)

#Due to the fact that some of the stores were temporarily closed for refurbishment, I'm trying to find out when they were closed

#I'm creating a table that counts the number of stores which submitted their data on a given day
by_date <- train%>%
  group_by(Date)%>%
  summarise(num_stores = n())

summary(by_date)

unique(by_date$num_stores)
# We have 3 levels of the viariable num_stores:1114,1115,935
which(by_date$num_stores==935)
# As we can see, the dates, when some of the shops were closed are the dates with the indices from 547 to 730 which corresponds to
# 1.07.2014-31.12.2014. This is a half of a year gap and it can cause some problems while modelling the data.
which(by_date$num_stores==1114)
# Only once there were 1114 stores reporting, on 1.01.2013.

stores_reporting <- train$Store[train$Date == as.Date("2014-7-1")]
missing_stores <- train$Store[!(train$Store %in% stores_reporting)]
unique(missing_stores) # The indices of the stores that didn't report from 1.07.2014 to 31.12.2014

unique(train$Store[!(train$Store %in% train$Store[train$Date == as.Date("2013-1-1")])])
# The index of the store that didn't report on 1.01.2013

train$Sales[train$Date == as.Date("2013-1-1")]
mean(train$Sales[train$Date == as.Date("2013-1-1")])

# Due to the fact that this was a New Year's Day, for simplification we can assume that the Store which didn't report on that day
# followed the pattern and was closed. We can add the missing row then and fill it with zeros in Sales, Customers, Open, Promo

subset(train, train$Date=="2013-01-01")
missing_row <- data.frame(Store=988, DayOfWeek=2, Date=as.character("2013-01-01"), Sales=0, Customers=0, Open=0, Promo=0, StateHoliday=as.character("a"), SchoolHoliday=1)
train<-rbind(train, missing_row)

# It was shown, that due to the large variations in the Sales data, we can get beter results working with the logarithm of sales and then switching back to the number of sales
# We add a new column to our training set
train$logSales <- log(train$Sales+1)

date_gap <- seq(as.Date("2014-7-1"),as.Date("2014-12-31"),by="day")
n_missing <- length(date_gap)*length(unique(missing_stores))
missing_df <- data.frame(Store = integer(n_missing),
                                       DayOfWeek = integer(n_missing),
                                       Date = rep(date_gap,length(unique(missing_stores))),
                                       Sales = integer(n_missing),
                                       Customers = integer(n_missing),
                                       Open = integer(n_missing),
                                       Promo = integer(n_missing),
                                       StateHoliday = character(n_missing),
                                       SchoolHoliday = integer(n_missing),
                                       logSales = numeric(n_missing),
                                       stringsAsFactors=FALSE)

#Filling  in the Store column of missing_df
for (date in date_gap) {
  missing_df$Store[missing_df$Date == date] <- unique(missing_stores)
}


daily_promo <- train%>%
  group_by(Date)%>%
  filter(Date==date_gap)%>%
  summarise(mean=mean(Promo))
daily_promo$Date <- as.Date(daily_promo$Date)
missing_df<-left_join(missing_df, daily_promo, by="Date")
missing_df$Promo<-missing_df$mean
missing_df$mean<-NULL

# Sale and customer means for every day
daily_mean <- train%>%
  group_by(Date)%>%
  filter(Date==date_gap)%>%
  summarise(mean=mean(Sales))
daily_mean$Date <- as.Date(daily_mean$Date)
# Sales will be replaced by the mean of sales from other stores. Any other way could hide important trends eg seasonal ones
# When most of the shops are closed we can assume that our shops would be closed too. But there is a chance, that our shop was open.
# Therefore, even though our mean would never be 0, the small mean can make up for the mistakes when we assumed the shop would be closed, and it would be open

missing_df<-left_join(missing_df, daily_mean, by="Date")

missing_df$Sales<-missing_df$mean
missing_df$mean<-NULL
missing_df$logSales<-log(missing_df$Sales+1)

daily_mean_cus <- train%>%
  group_by(Date)%>%
  filter(Date==date_gap)%>%
  summarise(mean=mean(Customers))
daily_mean_cus$Date <- as.Date(daily_mean$Date)


missing_df<-left_join(missing_df, daily_mean_cus, by="Date")

missing_df$Customers<-missing_df$mean
missing_df$mean<-NULL

# Let's take a store which reported every day during the whole period of data gathering. Based on the information given by the store,
# we can get information about state holiday, school holiday and day of the week

first <-subset(train, train$Store==1)
sub_first<-first%>%
  select(Date,DayOfWeek, StateHoliday, SchoolHoliday)
sub <- sub_first[213:396, ]
sub$Date <-as.Date(sub$Date)
missing_df <- left_join(missing_df, sub, by="Date")
missing_df$DayOfWeek.x<-NULL
missing_df$StateHoliday.x<-NULL
missing_df$SchoolHoliday.x<-NULL

missing_df<-missing_df%>%
  rename(StateHoliday=StateHoliday.y, SchoolHoliday=SchoolHoliday.y)
missing_df<-missing_df%>%
  rename(DayOfWeek=DayOfWeek.y)
head(missing_df)

daily_open <- train%>%
  group_by(Date)%>%
  filter(Date==date_gap)%>%
  summarise(mean=round(mean(Open), 0))

daily_open$Date <- as.Date(daily_open$Date)
missing_df<-left_join(missing_df, daily_open, by="Date")
missing_df$Open<-missing_df$mean
missing_df$mean <- NULL

head(missing_df)
train <- as.data.frame(train)
train$Date <- as.Date(train$Date)
train_filled<- rbindlist(list(train,missing_df), use.names = TRUE)
train_filled <- train_filled%>%
  arrange(Date)

fwrite(train_filled,"train_filled_order.csv")

