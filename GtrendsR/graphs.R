source('../common/common.R')
loadPackages(c('rjson', 'RMySQL', 'ggplot2', 'scales'))

config <- fromJSON(file = '../config.json')
settings <- fromJSON(file = '../settings.json')

conn <- dbConnect(RMySQL::MySQL(),
                  host = config$mysql$host,
                  dbname = config$mysql$database,
                  user = config$mysql$user,
                  password = config$mysql$password)
data <- dbReadTable(conn, 'google_trends')
dbDisconnect(conn)

p <- ggplot(final_trend_df[final_trend_df$keyword == 'koffie',], aes(x = time, y = percentage))+ geom_line()
p + theme(axis.text.x = element_text(angle = 30, hjust = 1)) + ggtitle("Interest over time for keyword weer(weather)") +ylab("Search hits")
last_plot()+ scale_x_datetime(breaks = date_breaks("14 hours"))
