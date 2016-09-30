# Install
devtools::install_github("PMassicotte/gtrendsR")
library(gtrendsR)

# Connect to Google
ch <- gconnect("trendstrends23@gmail.com", "trends23")

# The Google trends query
trend <- gtrends("Wekker", geo = "NL", res = "7d")
# Get only the trends dataset
trend_df <- as.data.frame(trend[['trend']])

plot(trend)
  