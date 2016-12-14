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
  dbWriteTable(databaseConnection,
               'sleep_cycle',
               data,
               append = T,
               row.names = F)
}

removeDatabaseDuplicates <- function(data, username) {
  rs <-
    dbSendQuery(
      databaseConnection,
      sprintf(
        "SELECT `start` FROM `sleep_cycle` WHERE `username` LIKE '%s' ORDER BY `start` DESC LIMIT 0,1",
        dbEscapeStrings(databaseConnection, username)
      )
    )
  data <- fetch(rs, n = -1)
  return(data)
}

getWakeupTimes <- function(data){
  bedtimeFreq <- table(format(df$endTime, "%H"))
  timeLabels <- factor(names(bedtimeFreq), levels = names(bedtimeFreq))
  wakeup_time <- data.frame(Count = bedtimeFreq, Time = timeLabels)
}

contentsSleepCycle <- function(input, output){
      renderTable({
      inFile <- input$file1
      
      if (is.null(inFile)) {
        return(NULL)
      }
      
      sleepy <-
        read.csv(inFile$datapath,
                 header = TRUE)
      
      frame <- toDataFrame(sleepy, input$username)
      
      insertIntoDatabase(frame)
      return(frame)
    });
    }

outbedSleepCycle <- function(input, output){
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
      timeLabels <- factor(names(bedtimeFreq), levels = names(bedtimeFreq))
      wakeup_time <- data.frame(Count = bedtimeFreq, Time = timeLabels)
      
      ggplot(data = wakeup_time, aes(x = wakeup_time$Time, y = wakeup_time$Count.Freq)) +
        geom_bar(stat = "identity", color = "black", fill = "lightblue") +
        xlab("Time you got out of bed") +
        ylab("Frequency") +
        ggtitle("Got out of bed") +
        theme_bw()
    })
}

shinyServer(function(input, output) {

})