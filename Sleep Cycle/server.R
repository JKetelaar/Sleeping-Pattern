library(shiny)

stringToMinutes <- function(x) {
  x <- as.numeric(x)
  x[1] * 60 + x[2]
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
  renderPlot({
    inFile <- input$file1
    
    if (is.null(inFile)) {
      return(NULL)
    }
    
    sleepy <-
      read.csv(inFile$datapath,
               header = TRUE)
    
    frame <- toDataFrame(sleepy, input$username)
    
    bedtimeFreq <- table(format(as.POSIXct(frame$end), "%H"))
    timeLabels <-
      factor(names(bedtimeFreq), levels = names(bedtimeFreq))
    wakeup_time <-
      data.frame(Count = bedtimeFreq, Time = timeLabels)
    
    ggplot(data = wakeup_time, aes(x = wakeup_time$Time, y = wakeup_time$Count.Freq)) +
      geom_bar(stat = "identity",
               color = "black",
               fill = "lightblue") +
      xlab("Time you got out of bed") +
      ylab("Frequency") +
      ggtitle("Got out of bed") +
      theme_bw()
  })
}

generalTimeInBed <- function(input, output) {
  renderPlot({
    p <- ggplot(getAllData(), aes(in_bed, quality)) + theme_bw()
    p <-
      p + geom_point() + ggtitle("Sleep Quality vs. Time in Bed") + xlab("Time in Bed in Minutes") + ylab("Sleep Quality in %")
    p + geom_smooth(method = lm)
  })
}

generalTimeInBedMonth <- function(input, output) {
  renderPlot({
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
    p + geom_bar(stat = "identity",
                 colour = "black",
                 fill = "lightblue")
  })
}

generalSleepDuration <- function(input, output) {
  renderPlot({
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
    p + geom_smooth(method = loess)
  })
}