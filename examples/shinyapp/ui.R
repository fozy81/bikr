library(leaflet)
library(rCharts)
shinyUI(navbarPage(
   title = 'Bicycle Framework Directive',
  tabPanel('Classification',
   fluidRow(column(12,
  leafletMap("map", "100%", 400, 
             initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
             initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
             options = list(
    center = c(56.170, 3.911),
    zoom = 5
  ))),
  htmlOutput("details"),hr(),
     fluidRow(column(5,tags$style(type="text/css",
                                 ".shiny-output-error { visibility: hidden; }",
                                 ".shiny-output-error:before { visibility: hidden; }"
    ),
                    "Status Table", dataTableOutput(outputId="table")),
    fluidRow(column(7,"Status Chart", plotOutput("chart2")
    )))
          
)),tabPanel("Objectives"),tabPanel("Measures"),tabPanel("Outcomes"),tabPanel("Sandbox"),tabPanel("Scenario Planning")))
