

In R shiny we

- generate HTML from R
- CSS is still written in CSS
- JavaScript is replaced by R.

For a shiny app you need at least 3 things:

- A user interface in HTML
- A "server logic" (previously JS, now an R function with 3 arguments)
- the function `shinyApp()`, which combines the user interface and the server logic.


Let's start by creating an R file with these elements:

```r
library(shiny)

ui <- c()

server <- function(input, output, session){}

shinyApp(ui, server)
```

We can execute the script line by line and view the various objects.


Without a user interface, the whole thing still looks very empty.


```diff
library(shiny)

-ui <- c()
+ui <- h1("Todays Progress") # shiny provides HTML tag functions: h1() renders as <h1>

server <- function(input, output, session){}

shinyApp(ui, server)
```


```diff
library(shiny)

-ui <- h1("Tagesfortschritt")
+ui <- tagList(               # tagList() combines multiple elements without adding a wrapper tag
+   h1("Todays Progress"),
+   p("How far has this day progressed?") # p() renders as an HTML <p> paragraph
+)


server <- function(input, output, session){}

shinyApp(ui, server)
```

Now, we want to determine and display the daily progress.


```diff
library(shiny)
+ library(lubridate)          # provides hour(), minute(), second() helpers for time objects

ui <- tagList(
     h1("Tagesfortschritt"),
     p("Wie Weit ist der Tag fortgeschritten?"),
  )


server <- function(input, output, session){
+  now <- Sys.time()          # get the current date-time
+
+  percent <- ((hour(now) + minute(now)/60 + second(now)/3600)/24)*100  # convert time to % of day
+
+ print(percent)              # only prints to the R console, not visible in the app!

}

shinyApp(ui, server)
```


It is much more elegant, especially to keep the overview later, if we outsource the calculation to a function.

```diff
library(shiny)
library(lubridate)

+get_percent <- function(){   # encapsulate the logic in a reusable function
+  now <- Sys.time()
+  diff <- ((hour(now) + minute(now)/60 + second(now)/3600)/24)*100
+  return(diff)               # explicitly return the computed value
+}

ui <- tagList(
  h1("Tagesfortschritt"),
  p("Wie Weit ist der Tag fortgeschritten?"),
)


server <- function(input, output, session){
-      now <- Sys.time()
-
-      percent <- ((hour(now) + minute(now)/60 + second(now)/3600)/24)*100

+      get_percent()           # cleaner, but result still only goes to the console
}


shinyApp(ui, server)

```


How do I get the percentage value into the HTML?


```diff
library(shiny)
library(lubridate)

get_percent <- function(x){
  now <- Sys.time()
  diff <- ((hour(now) + minute(now)/60 + second(now)/3600)/24)*100
  return(diff)
}

ui <- tagList(
  h1("Tagesfortschritt"),
  p("Wie Weit ist der Tag fortgeschritten?"),
+ textOutput("progress")     # UI placeholder — reserves a spot to display the output named "progress"
)


server <- function(input, output, session){
+  output$progress <- renderText(get_percent()) # renderText() connects the R value to the UI placeholder
}


shinyApp(ui, server)
```

To update the app, we need to use the `invalidateLater()` function.


```diff
library(shiny)
library(lubridate)

get_percent <- function(x){
  now <- Sys.time()
  diff <- ((hour(now) + minute(now)/60 + second(now)/3600)/24)*100
  return(diff)
}

ui <- tagList(
  h1("Tagesfortschritt"),
  p("Wie Weit ist der Tag fortgeschritten?"),
  textOutput("progress")
)


server <- function(input, output, session){
  output$progress <- renderText({
+   invalidateLater(100)      # tell Shiny to re-run this block every 100 ms → live updates
+   get_percent()
    })
}


shinyApp(ui, server)

```


If we want to add a Progressbar, we have to do the following step
the following step:


```diff

library(shiny)
library(lubridate)

get_percent <- function(x){
  now <- Sys.time()
  diff <- ((hour(now) + minute(now)/60 + second(now)/3600)/24)*100
  return(diff)
}

ui <- tagList(
  h1("Tagesfortschritt"),
  p("Wie Weit ist der Tag fortgeschritten?"),
  textOutput("progress"),
+ uiOutput("progress_bar")   # placeholder for dynamic UI — can hold any HTML, not just text
)


server <- function(input, output, session){
  output$progress <- renderText({
   invalidateLater(100)
   get_percent()
    })

+ output$progress_bar <- renderUI({   # renderUI() returns arbitrary HTML elements
+
+     invalidateLater(100)             # keep re-running every 100 ms
+     percent <- get_percent()
+     tags$progress(id = "progress", value = percent, max = 100) # native HTML <progress> element
+
+   })
}


shinyApp(ui, server)

```
