# Install.
source('../common/common.R')
loadPackages(c('rjson', 'RMySQL', 'devtools', 'XML'))
devtools::install_github("PMassicotte/gtrendsR")
library(gtrendsR)

# Setup.
settings <- fromJSON(file='../settings.json')
config <- fromJSON(file = '../config.json')

# Connect to Google.
ch <- gconnect(config$gtrends$email, config$gtrends$ww)
countries <- as.numeric(length(settings$countries))

gtrends_terms <- settings$countries[[countries]]$gtrendsTerms

# Split gtrends_terms in groups of 4.
splitted_terms <- split(gtrends_terms, ceiling(seq_along(gtrends_terms) / 4))

# Add specialTerm to every query so we get relatively results to compare.
special_term <- settings$countries[[countries]]$specialTerm


final_trend_df <- NULL

# The Google trends query. We loop through our splitted terms.
for (country in settings$countries) {
  special_term_query <- gtrends(special_term, geo = settings$countries[[countries]]$geoCountryCode, res = "7d")
  special_term_df <- as.data.frame(special_term_query[['trend']])
  final_trend_df <- rbind(special_term_df, final_trend_df)
  
  for (term in splitted_terms) {
    trend <- gtrends(c(term, special_term), geo = settings$countries[[countries]]$geoCountryCode, res = "7d")
    trend_df <- as.data.frame(trend[['trend']])
    
    # Multiplier for special term.
    mult <- mean(special_term_df$hits / trend_df[trend_df$keyword == special_term,]$hits)
    trend_df$hits <- trend_df$hits * mult
    
    # Combine data frame to finaal trend data frame.
    final_trend_df <- rbind(trend_df[trend_df$keyword != special_term,], final_trend_df)
  }
}

# Save in database.

colnames(final_trend_df) <- c("time", "keyword", "percentage", "location")

conn <- dbConnect(RMySQL::MySQL(),
                  host = config$mysql$host,
                  dbname = config$mysql$database,
                  user = config$mysql$user,
                  password = config$mysql$password)

dbWriteTable(conn, 'google_trends', final_trend_df, append = T, row.names = F)

dbDisconnect(conn)
