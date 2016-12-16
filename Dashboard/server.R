library(shiny)

source("../Sleep Aggregate/server.R")
source("../Sleep Cycle/server.R")

shinyServer(function(input, output) {
  # Sleep Aggregate
  output$regionC <- regionCAggregate(input, output)
  output$sleep <- sleepAggregate(input, output)
  output$totals <- totalsAggregate(input, output)
  
  # Your Sleep Cycle
  observeEvent(input$do, {
    output$outbed <- outbedSleepCycle(input, output)
    output$contents <- contentsSleepCycle(input, output)
  })
  
  # General Sleep Cycle
  output$gTimeInBed <- generalTimeInBed(input, output)
  output$gSleepDuration <- generalSleepDuration(input, output)
  output$gTimeInBedMonth <- generalTimeInBedMonth(input, output)
})
