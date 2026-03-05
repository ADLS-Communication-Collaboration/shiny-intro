library(shiny)
library(lubridate)

get_percent <- function(x) {
  now <- Sys.time()
  diff <- ((hour(now) + minute(now) / 60 + second(now) / 3600) / 24) * 100
  return(diff)
}

ui <- tagList(
  h1("Tagesfortschritt"),
  p("Wie Weit ist der Tag fortgeschritten?"),
  textOutput("progress"),
  uiOutput("progress_bar") # placeholder for dynamic UI — can hold any HTML, not just text
)


server <- function(input, output, session) {
  output$progress <- renderText({
    invalidateLater(100)
    get_percent()
  })

  output$progress_bar <- renderUI({
    # renderUI() returns arbitrary HTML elements

    invalidateLater(100) # keep re-running every 100 ms
    percent <- get_percent()
    tags$progress(id = "progress", value = percent, max = 100) # native HTML <progress> element
  })
}


shinyApp(ui, server)
