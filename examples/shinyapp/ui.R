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
                    "Status Table", dataTableOutput('table')),
    fluidRow(column(7,"Status Chart", plotOutput("chart2")
    )))
          
)),tabPanel("Objectives", fluidRow( column(6, p("Target for Good status (80% of Amsterdam level) based on number of years and cost per km of cycle path"),
                                           numericInput("num", 
                                                        label = p("Number of years for objective"), 
                                                        value = 7))),hr(),
                                    fluidRow( column(6, (numericInput("cost", 
                                                        label = p("Cost per km of cycle path"), 
                                                        value = 200000)))),  fluidRow(column(6, dataTableOutput('table2')))   
)
,tabPanel("Measures"),tabPanel("Outcomes"),tabPanel("Sandbox"),tabPanel("Scenario Planning")))
