library(leaflet)
library(rCharts)


shinyUI(
  navbarPage( 
  title = 'V3LO-SCAPE - powered by OpenStreetMap data',
  tabPanel('Classification',
           fluidRow(column(12,uiOutput('pleaseClick'),
                          leafletOutput("map")),

tags$div(
  HTML('<a href="https://github.com/fozy81/bikr"><img style="position: absolute; top: 25; right: 0; border: 0;" src="https://camo.githubusercontent.com/652c5b9acfaddf3a9c326fa6bde407b87f7be0f4/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6f72616e67655f6666373630302e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png"></a>')),
htmlOutput("details"),
                    fluidRow(column(7,tags$style(type="text/css",
                                                 ".shiny-output-error { visibility: hidden; }",
                                                 ".shiny-output-error:before { visibility: hidden; }"
                    ),hr(),
                    p("This site uses bicycle infrastructure data from OpenStreetMap to classify the level of provision in a given area. The classification is created by standardising against data from Amsterdam region as a reference condition of 'High' status."),
                    selectInput("adminLevel","Admin Level",choices = c("Scottish Parliamentary Constituencies" = "scotlandMsp","Scottish Councils Areas" = "scotlandCouncil"),selected = 'scotlandCouncil'), 
                    htmlOutput('description'),
                    uiOutput('rankStatusTable'),
                     uiOutput('areaSelect'), 
                    uiOutput('comparisonTable')),
                    
                    fluidRow(column(7,uiOutput("comparisonStatusChart")
                    )))
                    
           )),tabPanel("Objectives", fluidRow( column(6, p("Target objective of Good status (80% of Amsterdam level) based on number of years selected and cost per km of cycle path"),
                                                      htmlOutput('description2'),
                                                      numericInput("num", 
                                                                   label = p("Number of years to reach objective:"), 
                                                                   value = 7))),hr(),
                       fluidRow( column(6, (numericInput("cost", 
                                                         label = p("Average Cost £ per km of cycle path:"), 
                                                         value = 200000)))),           
                       fluidRow(column(9, dataTableOutput('table2')))   
           )
  ,tabPanel("Measures", fluidRow(column(6, p("Future forecast - based on proposed and under construction roads and cycle paths in OpenStreetMap"),dataTableOutput('measuresTable')))   
  )
  ,tabPanel("Outcomes", fluidRow(column(7, "This page is still in development. It will show how the classification relates to the % of public cycling and accident information",showOutput("chartOutcome","dimple")))),
tabPanel("Sandbox", fluidRow(column(7, "This page allows you to control all the weighting values and create your own weightings",
                                    numericInput("bicyclePathWeight", "Length cycle path separated from traffic:", 4,min = 0, max = 10, step = 0.1),
                                    numericInput("routeWeight", "National cycle network route length:", 0.8,min = 0, max = 10, step = 0.1),
                                    numericInput("bicyleParkingWeight", "Bicycle parking areas:", 1.5,min = 0, max = 10, step = 0.1),
                                    "The default ruralness weighting decreases the amount of provision required in rural areas as there tends to be much more road length per person in rural areas and thus quieter roads",
                                    numericInput("ruralWeight", "Ruralness weighting:", 2,min = 0, max = 10, step = 0.1),
                                    dataTableOutput('sandboxTable')))),
tabPanel("Scenario Planning", fluidRow(column(7, "This page is still in development. It's hoped it will highlight area of the most benefit to improve")))))
