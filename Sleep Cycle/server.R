library(shiny)
library(e1071)

stringToMinutes <- function(x) {
  x <- as.numeric(x)
  x[1] * 60 + x[2]
}

sleepCalculation <- function(x){
  sleep_bayes <- x[,c("quality", "in_bed", "temp", "wind")]
  
  sleep_bayes$Sleep.quality[sleep_bayes$quality > 85] <- "Good"
  sleep_bayes$Sleep.quality[sleep_bayes$quality <= 85] <- "Bad"
  
  sleep_bayes$Time.in.bed[sleep_bayes$in_bed > 520] <- "Long"
  sleep_bayes$Time.in.bed[sleep_bayes$in_bed <= 550] <- "Short"
  
  sleep_bayes$temp[sleep_bayes$temp > 5] <- "Warm"
  sleep_bayes$temp[sleep_bayes$temp <= 5] <- "Cold"
  
  sleep_bayes$wind[sleep_bayes$wind > 2] <- "Heavy"
  sleep_bayes$wind[sleep_bayes$wind <= 2] <- "Light"
  
  model <- naiveBayes(Sleep.quality ~ ., data = sleep_bayes)
  
  x <- subset(sleep_bayes, sleep_bayes$Sleep.quality == "Good") 
  y <- subset(sleep_bayes, sleep_bayes$Sleep.quality == "Bad")
  
  Long_Cold_Heavy <- (nrow(x) / (nrow(x)+ nrow(y))) * model$tables$in_bed[2,1] * model$tables$temp[1,2] * model$tables$wind[1,2]
  
  Long_Cold_Light <- (nrow(x) / (nrow(x)+ nrow(y))) * model$tables$in_bed[2,1] * model$tables$temp[1,2] * model$tables$wind[2,2]
  
  Long_Warm_Heavy <- (nrow(x) / (nrow(x)+ nrow(y))) * model$tables$in_bed[2,1] * model$tables$temp[2,2] * model$tables$wind[1,2]
  
  Long_Warm_Light <- (nrow(x) / (nrow(x)+ nrow(y))) * model$tables$in_bed[2,1] * model$tables$temp[2,2] * model$tables$wind[2,2]
  
  Short_Cold_Heavy <- (nrow(x) / (nrow(x)+ nrow(y))) * model$tables$in_bed[2,2] * model$tables$temp[1,2] * model$tables$wind[1,2]
  
  Short_Cold_Light <- (nrow(x) / (nrow(x)+ nrow(y))) * model$tables$in_bed[2,2] * model$tables$temp[1,2] * model$tables$wind[2,2]
  
  Short_Warm_Light <- (nrow(x) / (nrow(x)+ nrow(y))) * model$tables$in_bed[2,2] * model$tables$temp[2,2] * model$tables$wind[2,2]
  
  Short_Warm_Heavy <- (nrow(x) / (nrow(x)+ nrow(y))) * model$tables$in_bed[2,2] * model$tables$temp[2,2] * model$tables$wind[1,2]
  
  sleep_well <- data.frame(Long_Cold_Heavy, Long_Cold_Light, Long_Warm_Heavy, Long_Warm_Light, Short_Cold_Heavy, Short_Cold_Light, Short_Warm_Light, Short_Warm_Heavy)
  
  best_option <- names(sleep_well)[which(sleep_well==max(sleep_well))]
  return(best_option)
}

toDataFrame <- function(data, username) {
  if (nrow(data) > 1) {
    names(data) <- tolower(names(data))
    
    for (tag in settings$sleepcycleTags) {
      if (is.null(data[[tag]])) {
        data[[tag]] <- NA
      }
      
      if (tag == "time.in.bed") {
        data[[tag]] <-
          sapply(strsplit(as.character(data[[tag]]), ":"), stringToMinutes)
      }
      
      if (tag == "sleep.quality") {
        data[[tag]] <- as.integer(gsub("%", "", as.character(data[[tag]])))
      }
    }
    
    data$username <- username
    
    
    colnames(data) <-
      c(
        'start',
        'end',
        'quality',
        'in_bed',
        'wake_up',
        'note',
        'heart',
        'activity',
        'username'
      )
    
    return(data)
  } else{
    warning("Doesn't seem like a proper CSV, or does it?")
  }
}

insertIntoDatabase <- function(data) {
  conn <- getDatabaseConnection()
  dbWriteTable(conn,
               'sleep_cycle',
               data,
               append = T,
               row.names = F)
  
  dbDisconnect(conn)
}

getAllData <- function() {
  conn <- getDatabaseConnection()
  data <- dbReadTable(conn, 'sleep_cycle')
  dbDisconnect(conn)
  return(data)
}

getWeatherData <- function(sleep, summarise) {
  conn <- getDatabaseConnection()
  data <- dbGetQuery(conn,'SELECT * FROM knmi WHERE `temperature` > -90 AND `temperature` < 60 AND `wind` > 0')
  dbDisconnect(conn)
  
  sleep$End <- as.character(sleep$end)
  sleep$Date <- sapply(strsplit(sleep$End, " "), "[[", 1)
  
  weather <- data
  
  weather$Date <- as.Date(weather$date)
  weather$Time <-
    format(as.POSIXct(weather$date), format = "%H:%M:%S")
  
  # Take the average weather, from Utrecht
  weather <- subset(weather, source = "INOORDBR196")
  
  meanTempDay <-
    weather %>% group_by(Date) %>% summarise(temp = mean(temperature), wind = mean(wind))
  
  sleep$Date < as.character(sleep$Date)
  meanTempDay$Date <- as.character(meanTempDay$Date)
  
  merged <- merge(x = sleep, y = meanTempDay, by = "Date")
  
  merged$Week_Number <-
    strftime(as.POSIXlt(merged$Date), format = "%W")
  
  if (summarise == T) {
    dataSet <-
      merged %>% group_by(Week_Number) %>% summarise(temp = mean(temp), quality = mean(quality))
    
    return(dataSet)
  } else{
    return(merged)
  }
}

removeDatabaseDuplicates <- function(data, username) {
  conn <- getDatabaseConnection()
  rs <-
    dbSendQuery(
      conn,
      sprintf(
        "SELECT `start` FROM `sleep_cycle` WHERE `username` LIKE '%s' ORDER BY `start` DESC LIMIT 0,1",
        dbEscapeStrings(conn, username)
      )
    )
  data <- fetch(rs, n = -1)
  dbDisconnect(conn)
  return(data)
}

getWakeupTimes <- function(data) {
  bedtimeFreq <- table(format(df$endTime, "%H"))
  timeLabels <-
    factor(names(bedtimeFreq), levels = names(bedtimeFreq))
  wakeup_time <- data.frame(Count = bedtimeFreq, Time = timeLabels)
}

contentsSleepCycle <- function(input, output) {
  renderTable({
    inFile <- input$file1
    
    if (is.null(inFile)) {
      return(NULL)
    }
    
    sleepy <-
      read.csv(inFile$datapath,
               header = TRUE, sep = ";")
    
    frame <- toDataFrame(sleepy, input$username)
    
    insertIntoDatabase(frame)
    return(frame)
  })
  
}

outbedSleepCycle <- function(input, output) {
  renderPlotly({
    inFile <- input$file1
    
    if (is.null(inFile)) {
      return(NULL)
    }
    
    sleepy <-
      read.csv(inFile$datapath,
               header = TRUE, sep = ";")
    
    frame <- toDataFrame(sleepy, input$username)
    
    bedtimeFreq <- table(format(as.POSIXct(frame$end), "%H"))
    timeLabels <-
      factor(names(bedtimeFreq), levels = names(bedtimeFreq))
    wakeup_time <-
      data.frame(Count = bedtimeFreq, Time = timeLabels)
    
    p <-
      ggplot(data = wakeup_time, aes(x = Time, y = Count.Freq)) +
      geom_bar(stat = "identity",
               color = "black",
               fill = "lightblue") +
      xlab("Time you got out of bed") +
      ylab("Frequency") +
      ggtitle("Got out of bed") +
      theme_bw()
    
    p <- ggplotly(p)
    
    return(p)
  })
}

generalTimeInBed <- function(input, output) {
  renderPlotly({
    p <- ggplot(getAllData(), aes(in_bed, quality)) + theme_bw()
    p <-
      p + geom_point() + ggtitle("Sleep Quality vs. Time in Bed") + xlab("Time in Bed in Minutes") + ylab("Sleep Quality in %")
    p <- p + geom_smooth()
    
    return(ggplotly(p))
  })
}

generalTimeInBedMonth <- function(input, output) {
  renderPlotly({
    data <- getAllData()
    data$end <- as.character(data$end)
    
    data$Date <- sapply(strsplit(data$end, " "), "[[", 1)
    data$Date <- strptime(data$Date, format = "%Y-%m-%d")
    
    df <- data.frame(date = data$Date,
                     x = data$quality)
    df$my <- floor_date(df$date, "month")
    group <- ddply(df, "my", summarise, x = mean(x))
    
    
    p <- ggplot(group, aes(my, x)) + theme_bw()
    p <-
      p + ggtitle("Sleep Quality by Month Time in Bed") + xlab("Month") + ylab("Sleep Quality in %")
    p <- p + geom_bar(stat = "identity",
                      colour = "black",
                      fill = "lightblue")
    
    return(ggplotly(p))
  })
}

avgTempPerWeek <- function(input, output) {
  renderPlotly({
    inFile <- input$file1
    
    if (is.null(inFile)) {
      return(NULL)
    }
    
    sleepy <-
      read.csv(inFile$datapath,
               header = TRUE, sep = ";")
    
    weather <-
      getWeatherData(toDataFrame(sleepy, input$username), T)
    
    p <-
      ggplot(data = weather, aes(x = Week_Number, y = temp, fill = quality)) +
      geom_bar(stat = "identity") +
      theme_bw() +
      ggtitle("Average temperature per Week") +
      xlab("Week number") +
      ylab("Temperature (in degrees)")
    
    return(ggplotly(p))
  })
}

inputFileToWeatherData <- function(input) {
  inFile <- input$file1
  
  if (is.null(inFile)) {
    return(NULL)
  }
  
  sleepy <-
    read.csv(inFile$datapath,
             header = TRUE, sep = ";")
  
  weather <- getWeatherData(toDataFrame(sleepy, input$username), F)
  
  return(weather)
}

tempWindSleepQuality <- function(input, output) {
  renderPlotly({
    weather <- inputFileToWeatherData(input)
    
    p <-
      ggplot(data = weather, aes(x = temp, y = wind, color = quality)) +
      geom_point() +
      xlab("Temperature (in degrees)") +
      ylab("Wind (in km/h)") +
      ggtitle("Effects of temperature and wind on sleep quality") +
      theme_bw()
    
    return(ggplotly(p))
  })
}

generalAvgTempPerWeek <- function(input, output) {
  renderPlotly({
    data <- getAllData()
    data$end <- as.character(data$end)
    
    data$Date <- sapply(strsplit(data$end, " "), "[[", 1)
    data$Date <- strptime(data$Date, format = "%Y-%m-%d")
    
    weather <- getWeatherData(data, T)
    
    p <-
      ggplot(data = weather, aes(x = Week_Number, y = temp, fill = quality)) +
      geom_bar(stat = "identity") +
      theme_bw() +
      ggtitle("Average temperature per Week") +
      xlab("Week number") +
      ylab("Temperature (in degrees)")
    
    return(ggplotly(p))
  })
}

generalTempWindSleepQuality <- function(input, output) {
  renderPlotly({
    data <- getAllData()
    data$end <- as.character(data$end)
    
    data$Date <- sapply(strsplit(data$end, " "), "[[", 1)
    data$Date <- strptime(data$Date, format = "%Y-%m-%d")
    
    weather <- getWeatherData(data, F)
    
    p <-
      ggplot(data = weather, aes(x = temp, y = wind, color = quality)) +
      geom_point() +
      xlab("Temperature (in degrees)") +
      ylab("Wind (in km/h)") +
      ggtitle("Effects of temperature and wind on sleep quality") +
      theme_bw()
    
    return(ggplotly(p))
  })
}

sleepQualityTempPerDate <- function(input, output) {
  renderPlotly({
    
    weather <- inputFileToWeatherData(input)
    
    p <-
      ggplot(data = weather, aes(x = Date, y = quality, fill = temp)) +
      geom_bar(stat = "identity") +
      coord_flip() +
      xlab("Sleep quality") +
      ylab("Date") +
      ggtitle("Sleep quality per date") +
      theme_bw()
    
    return(ggplotly(p))
  })
}

sleepAnalytics <- function(input, output){
  renderText({
    weather <- inputFileToWeatherData(input)
    
    result <- sleepCalculation(weather)
    split <- strsplit(result, "_")
    split <- split[[1]]
    
    return(sprintf("The best way for you to sleep is to make %s nights, with a %s temperature and a %s wind.", tolower(split[1]), tolower(split[2]), tolower(split[3])))
  })
}

generalSleepDuration <- function(input, output) {
  renderPlotly({
    data <- getAllData()
    data$end <- as.character(data$end)
    
    data$Date <- sapply(strsplit(data$end, " "), "[[", 1)
    data$Date <- strptime(data$Date, format = "%Y-%m-%d")
    
    p <- ggplot(data, aes(Date, in_bed)) + theme_bw()
    p <-
      p + geom_point(aes(colour = quality), size = 3.5) + scale_colour_gradient(
        limits = c(30, 100),
        low = "red",
        high = "green",
        space = "Lab"
      )
    p <-
      p + ggtitle("Sleep Duration Over Time") + xlab("Date") + ylab("Duration in Minutes")
    p <- p + geom_smooth(method = loess)
    return(ggplotly(p))
  })
}