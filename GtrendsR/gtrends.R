# Install.
devtools::install_github("PMassicotte/gtrendsR")
source('../common/common.R')
loadPackages(c('rjson', 'RMySQL'))

# Setup.
settings <- fromJSON(file='../settings.json')
config <- fromJSON(file = '../config.json')

# Connect to Google.
ch <- gconnect(config$email, config$ww)
countries <- as.numeric(length(config$countries))

gtrends_terms <- settings$countries[[countries]]$gtrendsTerms

# Split gtrends_terms in groups of 4.
splitted_terms <- split(gtrends_terms, ceiling(seq_along(gtrends_terms) / 4))

# Add specialTerm to every query so we get relatively results to compare.
special_term <- settings$countries[[countries]]$specialTerm

trend_df <- NULL

# The Google trends query. We loop through our splitted terms.
for (country in settings$countries) {
  for (term in splitted_terms) {
    for (country_code in settings$countries[[countries]]$geoCountryCodes) {
      trend <- gtrends(c(term, special_term), geo = country_code, res = "7d")
      trend_df = rbind(trend_df, as.data.frame(trend[['trend']]))
    }
  }
}

# TODO

# In plaats van alles samen te voegen in 1 data.frame. Een vector van data.frames maken.
# Elke data.frame is 1 query.
# Vervolgens voor elk data.frame de facebook gegevens vergelijken met de andere data.frames
# Daarna die gegevens normaliseren en alles weer terug in 1 data.frame zetten.  



# Save in database.

colnames(trend_df) <- c("time", "keyword", "percentage", "location")

conn <- dbConnect(RMySQL::MySQL(),
                  host = config$mysql$host,
                  dbname = config$mysql$database,
                  user = config$mysql$user,
                  password = config$mysql$password)

dbWriteTable(conn, 'google_trends', trend_df, append = T, row.names = F)

dbDisconnect(conn)


