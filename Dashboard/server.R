library(shiny)

source("../Sleep Aggregate/server.R")
source("../Sleep Cycle/server.R")
source("../KNMI/shiny/server.R")

shinyServer(function(input, output) {
  withProgress(message = "Loading data",
               detail = "Downloading dank memes",
               value = 0,
               {
                 incProgress(0.1, detail = "Create observe events")
                 # Your Sleep Cycle
                 observeEvent(input$do, {
                   output$outbed <- outbedSleepCycle(input, output)
                   output$contents <-
                     contentsSleepCycle(input, output)
                 })
                 
                 # Sleep Aggregate
                 incProgress(0.2, detail = "Plotting region aggregate")
                 output$regionC <- regionCAggregate(input, output)
                 
                 incProgress(0.3, detail = "Plotting sleep aggregate")
                 output$sleep <- sleepAggregate(input, output)
                 
                 incProgress(0.4, detail = "Plotting total aggregate")
                 output$totals <- totalsAggregate(input, output)
                 output$weather <- weatherWithAnalyticsData(input, output)
                 output$frequency <- weatherWithFrequency(input, output)
                 
                 # General Sleep Cycle
                 incProgress(0.6, detail = "Plotting time in bed")
                 output$gTimeInBed <-
                   generalTimeInBed(input, output)
                 
                 incProgress(0.8, detail = "Plotting sleep duration")
                 output$gSleepDuration <-
                   generalSleepDuration(input, output)
                 
                 incProgress(1, detail = "Plotting time in bed, monthly")
                 output$gTimeInBedMonth <-
                   generalTimeInBedMonth(input, output)
               })
})
