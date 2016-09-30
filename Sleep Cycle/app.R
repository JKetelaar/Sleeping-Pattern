install.packages("lubridate")
install.packages("plyr")
install.packages("ggplot2")

library(ggplot2)
library(lubridate)
library(plyr)

sleep <-
  read.csv(file = "../data/sleep-cycle/sleepdata.csv", header = T, sep = ";")

#split end time
sleep$End <- as.character(sleep$End)

#get the date
sleep$Date <- sapply(strsplit(sleep$End, " "), "[[", 1)
sleep$Date <- strptime(sleep$Date, format = "%Y-%m-%d")

#fix sleep quality
sleep$Sleep.quality <-
  as.integer(gsub("%", "", as.character(sleep$Sleep.quality)))

#convert Time in bed to minutes
StringToMinutes <- function(x) {
  # Converts a String with format HH:MM:SS to a decimal minutes representation
  #
  # Args:
  #   x: String with format HH:MM
  #
  # Returns:
  #   Float minutes
  x <- as.numeric(x)
  x[1] * 60 + x[2]
}

sleep$Time.in.bed <-
  sapply(strsplit(as.character(sleep$Time.in.bed), ":"), StringToMinutes)

#correlation sleep quality and time in bed
p <- ggplot(sleep, aes(Time.in.bed, Sleep.quality)) + theme_bw()
p <-
  p + geom_point(aes(colour = Sleep.Notes)) + ggtitle("Sleep Quality vs. Time in Bed") + xlab("Time in Bed in Minutes") + ylab("Sleep Quality in %")
p + geom_smooth(method = lm)

#plot sleep duration over time
p <- ggplot(sleep, aes(Date, Time.in.bed)) + theme_bw()
p <-
  p + geom_point(aes(colour = Sleep.quality), size = 3.5) + scale_colour_gradient(
    limits = c(30, 100),
    low = "red",
    high = "green",
    space = "Lab"
  )
p <-
  p + ggtitle("Sleep Duration Over Time") + xlab("Date") + ylab("Duration in Minutes")
p + geom_smooth(method = loess)

#group sleep quality by month
df <- data.frame(date = sleep$Date,
                 x = sleep$Sleep.quality)
df$my <- floor_date(df$date, "month")

group <- ddply(df, "my", summarise, x = mean(x))

p <- ggplot(group, aes(my, x)) + theme_bw()
p <-
  p + ggtitle("Sleep Quality by Month Time in Bed") + xlab("Month") + ylab("Sleep Quality in %")
p + geom_bar(stat = "identity",
             colour = "black",
             fill = "lightblue")


# Playing with the library
# sleep$Sleep.quality
# head(x) <- as.numeric(sub("%", "", sleep$Sleep.quality))
# boxplot(x)
# 
# plot(x, sleep$Time.in.bed)
# substr(sleep$Start, 12, 16)
# 
# as.numeric(as.POSIXct(sleep$Start))
# y <- gsub("[^[:digit:]]", "", x)
# x <- substr(sleep$Start, 12, 16)
# as.numeric(x)
# y <- as.numeric(y)
# str(y)
# hed
# y
# boxplot(y, ylim = c(2000, 2400))
# 
# plot(sleep$Start, xaxt = "n")
# axis.POSIXct(side = 1,
#              at = cut(sleep$Start, "hours"),
#              format = "%h/%m")
# df$Date <- as.Date(df$Date, '%m/%d/%Y')
# sleep$Start <- as.Date(sleep$Start, '%Y/%m/%d')
# str(sleep$Time.in.bed)
# head(sleep$Time.in.bed)
# as.numeric(as.character(sleep$Time.in.bed))
# 
# 
# sleep$TTime_in_bed <- sapply(strsplit(sleep$Time.in.bed, ":"),
#                              function(x) {
#                                x <- as.numeric(x)
#                                x[1] + x[2] / 60
#                              })
# 
# mean(sleep_Time_in_bed)
# qplot(sleep_Time_in_bed, y, xlim = c(6, 10))
# ggplot(data = sleep, aes(x = factor(sleep$Sleep.quality, y = sleep$T))) +
#   boxplot(sleep_Time_in_bed)
# 
# plot(
#   y ~ sleep_Time_in_bed,
#   ylim = c(2000, 2400),
#   xlab = "Time slept in bed",
#   ylab = "Time went to bed",
#   main = "Amount of time in bed"
# )