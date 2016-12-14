library(shiny)

shinyServer(function(input, output) {
  observeEvent(input$do, {
    output$contents <- renderTable({
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
    
    output$outbed <- renderPlot({
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
  })
})