TWITTER <- new.env()
GTRENDS <- new.env()
SLEEPCYCLE <- new.env()
KNMI <- new.env()

wd <- getwd()

setwd('../Twitter/shiny')
source('global.R', local = TWITTER)
twitterData <- TWITTER$analyzeData(TWITTER$readData())

setwd(wd)

setwd('../GtrendsR/shiny')
source('global.R', local = GTRENDS)
gtrendsData <- GTRENDS$loadData()

setwd(wd)

setwd('../Sleep Cycle')
source('global.R', local = SLEEPCYCLE)
databaseConnection <- SLEEPCYCLE$conn

setwd(wd)

settings <- TWITTER$settings
config <- TWITTER$config

KNMI$TWITTER <- TWITTER
KNMI$GTRENDS <- GTRENDS
KNMI$config <- config
KNMI$settings <- settings

setwd('../KNMI/shiny')
source('global.R', local = KNMI)

setwd(wd)


getDatabaseConnection <- function() {
  dbConnect(
    RMySQL::MySQL(),
    host = config$mysql$host,
    dbname = config$mysql$database,
    user = config$mysql$user,
    password = config$mysql$password
  )
}