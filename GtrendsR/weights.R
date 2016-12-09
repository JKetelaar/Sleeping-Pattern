source('../common/common.R')
loadPackages(c('rjson', 'RMySQL'))

config <- fromJSON(file = '../config.json')
settings <- fromJSON(file = '../settings.json')

conn <- dbConnect(RMySQL::MySQL(),
                  host = config$mysql$host,
                  dbname = config$mysql$database,
                  user = config$mysql$user,
                  password = config$mysql$password)

keywords <- c(settings$countries[[1]]$gtrendsTerms, settings$countries[[1]]$specialTerm) 

data <- dbGetQuery(conn, 'SELECT HOUR(`time`) AS `hour`, DAYOFWEEK(`time`) AS `day`, `keyword`, `percentage` FROM google_trends WHERE `location` = "NL"')

plot(0, 0, xlim = c(0, 23), ylim = c(0, 1), xlab = 'Hour', ylab = 'Percentage')

colors <- rainbow(length(keywords))
meanHours <- NULL
i <- 1

for(keyword in keywords) {
  trendData <- data[data$keyword == keyword,]
  trendData$percentage <- norm(trendData$percentage)
  trendData <- aggregate(trendData$percentage, list(hour = trendData$hour), mean)
  points(trendData$hour, trendData$x, type = 'l', col = colors[i])
  trendWeight <- sum(trendData$x * trendData$hour) / sum(trendData$x)
  meanHours <- rbind(meanHours, data.frame(Hour = trendWeight, Keyword = keyword))
  i <- i + 1
}

meanHours <- meanHours[order(meanHours$Hour),]

weights <- na.omit(meanHours)
weights$Weight <- norm(weights$Hour) * -2 + 1
weights$Hour <- NULL

dbDisconnect(conn)

# Calculate the weights for every keyword in the final dataset
data$weight <- 0
for(keyword in unique(data$keyword)) {
  data$weight <- data$weight + (data$keyword == keyword) * data$percentage * settings$countries[[1]]$gtrendsWeights[[keyword]]
}
