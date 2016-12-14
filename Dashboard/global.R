TWITTER <- new.env()
GTRENDS <- new.env()
SLEEPCYCLE <- new.env()

wd <- getwd()

setwd('../Twitter/shiny')
source('global.R', local = TWITTER)
twitterData <- TWITTER$analyzeData(TWITTER$readData())

setwd(wd)

setwd('../GtrendsR/shiny')
source('global.R', local = GTRENDS)
gtrendsData <- GTRENDS$originalData

setwd(wd)

setwd('../Sleep Cycle')
source('global.R', local = SLEEPCYCLE)
databaseConnection <- SLEEPCYCLE$conn

setwd(wd)

settings <- TWITTER$settings
config <- TWITTER$config