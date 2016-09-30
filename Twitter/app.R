install.packages("twitteR")
install.packages("tm")
install.packages("wordcloud")
install.packages("RColorBrewer")

library(twitteR)
library(tm)
library(wordcloud)
library(RColorBrewer)

api_key <- "TplDnL2Z1Fid7gCsHolTomxQT"
api_secret <- "IgPFawGXN13LJ2iQj1rSKYekMwaOkT8tvV5H3wQ6ANDADDc0XI"
access_token <- "237631092-NMov8Bzx069RmnQdypCU5K0mBSz0diCIoOAzRywE"
access_token_secret <-
  "NWGeKvundNCbb2i2iaxTm2BzaZUNxAtL7UDl50Qyac1Wx"
setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)

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