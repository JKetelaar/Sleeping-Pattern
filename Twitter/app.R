install.packages("twitteR")
install.packages("tm")
install.packages("wordcloud")
install.packages("RColorBrewer")
install.packages("rjson")

# Set config from config.json
library("rjson")
config <- fromJSON(file="../config.json");

library(twitteR)
library(tm)
library(wordcloud)
library(RColorBrewer)

setup_twitter_oauth(config$twitter$api_key, config$twitter$api_secret, config$twitter$access_token, config$twitter$access_token_secret)

ecoli = searchTwitter(
  "\"trusten\"",
  lang = "nl",
  n = 200,
  since = '2016-09-28',
  until = '2016-09-29',
  geocode = '51.9,4.4,500mi'
)

ecoli2 = do.call(rbind, lapply(ecoli, function(x) {
  c(
    tweet = x$getText(),
    date = x$getCreated(),
    retweet = x$getIsRetweet(),
    longitude = x$getLongitude(),
    latitude = x$getLatitude(),
    name = x$getScreenName(),
    id = x$getId()
  )
}))

x <- as.data.frame(ecoli2)

id <- as.character(x$id)
date <- as.numeric(as.character(x$date))
retweet <- as.integer(as.logical(x$retweet))
name <- as.character(x$name)
tweet <- as.character(x$tweet)

# Convert timestamp into a date object
# $date <- as.Date(as.POSIXct(timestamp, origin="1970-01-01"))