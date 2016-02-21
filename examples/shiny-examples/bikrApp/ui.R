library(leaflet)
library(rCharts)



shinyUI(
  navbarPage( theme = "bootstrap.min.css",
              title = 'Rate bicycle infrastructure in your area!',
              tabPanel('Ranking', 
                       fluidRow(column(5,  tags$style(HTML("body { background-image: url('pop14.jpg');  background-size: 1800px; }")), 
                                       htmlOutput("description"),   htmlOutput('details')),
                                column(7, wellPanel(uiOutput('pleaseClick'),
                                                    leafletOutput("map"))),
                                
                                tags$div()),

                       hr(),
                       fluidRow(
                         column(7,  htmlOutput('scotlandDetails'),  uiOutput('areaSelect'), uiOutput('tabs')),
                         column(5, tags$style(type="text/css",
                                              ".shiny-output-error { visibility: hidden; }",
                                              ".shiny-output-error:before { visibility: hidden; }"
                         ),
                         wellPanel(
                        
                           selectInput("adminLevel","Switch admin level in Scotland",choices = c("Scottish Parliamentary Constituencies" = "scotlandMsp","Scottish Councils Areas" = "scotlandCouncil"),selected = 'scotlandMsp'), 
                           uiOutput('rankStatusTable'), uiOutput('rank_select') ))
                       )
                       
              ),tabPanel("Cost Improvements", fluidRow( column(6, h3("How much will it cost to match Amsterdam bicycle infrastructure?"), 
                                                                p("The table below displays the target length in km of extra cycle path 
                                                                required to reach 80% level of provision found in Amsterdam region 
                                                                or in other words 'Good' status according to this classification scheme. 
                                                                By altering the values selected below, you can control how quickly you wish
                                                                to reach 'Good status' and set a default for the average cost of creating
                                                                cycle path per km. These values determine the 'Projected Cost per year in GBP'.",align = "justify")),
                                                      
                                                     column(6,numericInput("num", 
                                                                   label = p("Set the number of years to reach objective:"), 
                                                                   value = 15),
                  numericInput("cost", 
                                                         label = p("Set the value for the average cost £ per km of cycle path:"), 
                                                         value = 150000),
                       htmlOutput('descriptionCosts'))),
                       fluidRow(column(12, hr(), DT::dataTableOutput('tableCosts')))),   
          
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

tabPanel("About", fluidRow(column(8, h4("This site uses bicycle infrastructure data from",
                                        tags$a(href="http://www.openstreetmap.org/#map=10/55.9496/-3.8809&layers=C","OpenStreetMap"),
                                        "to classify the level of provision in a given area. The classification is created by standardising 
                                        against data from Amsterdam region as a reference condition of 'High' status. Please take these figures
                                      with a pitch of salt - we are only just getting started. The development of this website started at",
                                        tags$a(href="http://www.cyclehack.com/catalogue/veloscapr/", "Cyclehack Glasgow"),
                                        "with contributions from Joel, Neil & Sunil.",align = "justify"),
                                    h4("Find out more, get the data and contribute to the project", 
                                       tags$a(href="https://github.com/fozy81/bikr","here.")), h4("Contact us on twitter ", 
                                                                                          tags$a(href="https://twitter.com/fozy81","here."))
                                  )))


))