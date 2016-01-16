library(leaflet)
library(rCharts)


shinyUI(
<<<<<<< HEAD
  navbarPage( 
  title = 'V3LO-SCAPE - Tracking the quality of bicycle infrastructure in your area',
  tabPanel('Classification',
           includeScript("spin.min.js"),
           fluidRow(column(12,uiOutput('pleaseClick'),
                          leafletOutput("mymap"),    tags$script("var spinner = new Spinner().spin();
                                                              $( 'div#mymap' ).append(spinner.el);"),
                          tags$script('
  Shiny.addCustomMessageHandler("map_done",
        function(s) {
          spinner.stop();
          $( "div#mymap" ).remove(spinner);
        });')
                          
                          ),
# test
tags$div(
  HTML('<a href="https://github.com/fozy81/bikr"><img style="position: absolute; top: 25; right: 0; border: 0;" src="https://camo.githubusercontent.com/652c5b9acfaddf3a9c326fa6bde407b87f7be0f4/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6f72616e67655f6666373630302e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png"></a>')),
htmlOutput("details"),
                    fluidRow(column(7, offset = 1,tags$style(type="text/css",
                                                 ".shiny-output-error { visibility: hidden; }",
                                                 ".shiny-output-error:before { visibility: hidden; }"
                    ),hr(),
                    h4("This site uses bicycle infrastructure data from",tags$a(href="http://www.openstreetmap.org/#map=10/55.9496/-3.8809&layers=C","OpenStreetMap"), "to classify the level of provision in a given area. The classification is created by standardising against data from Amsterdam region as a reference condition of 'High' status."),
                    h4("Find out more, get the data and contribute to the project", tags$a(href="https://github.com/fozy81/bikr","here")),
                    htmlOutput('description'),
                    selectInput("adminLevel","Switch admin level in Scotland",choices = c("Scottish Parliamentary Constituencies" = "scotlandMsp","Scottish Councils Areas" = "scotlandCouncil"),selected = 'scotlandMsp'), 
                    uiOutput('rankStatusTable'),
                     uiOutput('areaSelect'), 
                    uiOutput('comparisonTable')),
                    
                    fluidRow(column(7, offset = 1, uiOutput("comparisonStatusChart")
                    )))
=======
  navbarPage( theme = "bootstrap.min.css",
  title = 'Track the quality of bicycle infrastructure in your area',
  tabPanel('Current Status', 
           fluidRow(column(6, htmlOutput("description"),   htmlOutput('details')),
             column(6, wellPanel(uiOutput('pleaseClick'),
                          leafletOutput("map"))),

tags$div()),
 # HTML('<a href="https://github.com/fozy81/bikr"><img style="position: absolute; top: 25; right: 0; border: 0;" src="https://camo.githubusercontent.com/652c5b9acfaddf3a9c326fa6bde407b87f7be0f4/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6f72616e67655f6666373630302e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png"></a>')),

hr(),
                    fluidRow(
                    column(6, wellPanel(
                      htmlOutput('scotlandDetails'), uiOutput('areaSelect'), uiOutput('comparisonTable'), uiOutput('comparisonMetric'),   uiOutput("comparisonStatusChart")  
                    )),
                    column(6, tags$style(type="text/css",
                                         ".shiny-output-error { visibility: hidden; }",
                                         ".shiny-output-error:before { visibility: hidden; }"
                    ),
                    wellPanel(
                      #h4("This site uses bicycle infrastructure data from",tags$a(href="http://www.openstreetmap.org/#map=10/55.9496/-3.8809&layers=C","OpenStreetMap"), "to classify the level of provision in a given area. The classification is created by standardising against data from Amsterdam region as a reference condition of 'High' status."),
                       #         h4("Find out more, get the data and contribute to the project", tags$a(href="https://github.com/fozy81/bikr","here")),
                               selectInput("adminLevel","Switch admin level in Scotland",choices = c("Scottish Parliamentary Constituencies" = "scotlandMsp","Scottish Councils Areas" = "scotlandCouncil"),selected = 'scotlandMsp'), 
                               uiOutput('rankStatusTable'), uiOutput('rank_select') ))
                    )
>>>>>>> dev
                    
           ),tabPanel("Costing Improvements", fluidRow( column(6, p("The table below displays the target length in km of extra cycle path required to reach 80% level of provision found in Amsterdam region or in other words 'Good' status according to this classification scheme. By altering the values selected below, you can control how quickly you wish to reach 'Good status' and set a default for the average cost of creating cycle path per km. These values determine the 'Projected Cost per year in GBP'."),
                                                      
                                                      numericInput("num", 
                                                                   label = p("Set the number of years to reach objective:"), 
                                                                   value = 15))),hr(),
                       fluidRow( column(6, (numericInput("cost", 
                                                         label = p("Set the value for the average cost £ per km of cycle path:"), 
                                                         value = 150000)))),
                       htmlOutput('description2'),
                       fluidRow(column(9, dataTableOutput('table2')))),   
          
### Future features for UI commented out below: 
 # ,tabPanel("Measures", fluidRow(column(6, p("Future forecast - based on proposed and under construction roads and cycle paths in OpenStreetMap"),dataTableOutput('measuresTable')))   
#  )
 # ,tabPanel("Outcomes", fluidRow(column(7, "This page is still in development. It will show how the classification relates to the % of public cycling and accident information etc. Only works with MSP areas for % communting - scottish census stats for council areas for % commuting by bicycle will be added in future",plotOutput("chartOutcome")))),
# tabPanel("Sandbox", fluidRow(column(7, "Each of the three factors assessed (Length of cycle path, length of NCN and bicycle parking) are given subjective weightings to increase or decrease their relative importance in the overall status. This page allows you to control all the weighting values and create your own weightings",
 #                                   numericInput("bicyclePathWeight", "Cycle path length weighting:", 4,min = 0, max = 100, step = 0.1),
  #                                  numericInput("routeWeight", "National cycle network route length weighting:", 0.8,min = 0, max = 100, step = 0.1),
   #                                 numericInput("bicyleParkingWeight", "Bicycle parking spaces weighting:", 1.5,min = 0, max = 100, step = 0.1),
    #                                "The default ruralness weighting decreases the amount of provision required in rural areas as there tends to be much more road length per person in rural areas and thus quieter roads",
     #                               numericInput("ruralWeight", "Ruralness weighting:", 2,min = 0, max = 100, step = 0.1),
      #                              dataTableOutput('sandboxTable')))),
#tabPanel("Scenario Planning", fluidRow(column(7, "This page is still in development. It's hoped it will highlight areas of the most benefit to improve")))))

tabPanel("About", fluidRow(column(7, h4("This site uses bicycle infrastructure data from",tags$a(href="http://www.openstreetmap.org/#map=10/55.9496/-3.8809&layers=C","OpenStreetMap"), "to classify the level of provision in a given area. The classification is created by standardising against data from Amsterdam region as a reference condition of 'High' status."),
                                           h4("Find out more, get the data and contribute to the project", tags$a(href="https://github.com/fozy81/bikr","here"))
                                  )))

))
