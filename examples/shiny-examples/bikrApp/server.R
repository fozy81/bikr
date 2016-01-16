library(rCharts)
library(leaflet)
#library(jsonlite)
library(RJSONIO)
#devtools::install_github("fozy81/mypackage")
library(bikr)
library(ggplot2)
library(DT)
# 
 d1 <- bicycleStatus(scotlandMsp)
d1$fillcolor <- ifelse(d1$Status == "High","#ffffb2","")
d1$fillcolor <- ifelse(d1$Status == "Good","#fecc5c",d1$fillcolor)
d1$fillcolor <- ifelse(d1$Status == "Moderate","#fd8d3c",d1$fillcolor)
d1$fillcolor <- ifelse(d1$Status == "Poor","#f03b20",d1$fillcolor)
d1$fillcolor <- ifelse(d1$Status == "Bad","#bd0026",d1$fillcolor)

e1 <- bicycleStatus(scotlandCouncil)
e1$fillcolor <- ifelse(e1$Status == "High","#ffffb2","")
e1$fillcolor <- ifelse(e1$Status == "Good","#fecc5c",e1$fillcolor)
e1$fillcolor <- ifelse(e1$Status == "Moderate","#fd8d3c",e1$fillcolor)
e1$fillcolor <- ifelse(e1$Status == "Poor","#f03b20",e1$fillcolor)
e1$fillcolor <- ifelse(e1$Status == "Bad","#bd0026",e1$fillcolor)

#d <- data.frame(fromJSON('examples/shinyapp/scotlandAmsterdam.json',flatten=T))
#geojsonFile <- fromJSON('examples/shinyapp/scotlandAmsterdam.json')
#fileName <- fromJSON'scotlandAmsterdam.json'
#geojsonFile <- readChar(fileName, file.info(fileName)$size)
 


shinyServer(function(input, output, session) {
 
 
   sumdata <- reactive({
            if(input$adminLevel == 'scotlandMsp'){
       return(scotlandMsp)
    }
    if(input$adminLevel == 'scotlandCouncil'){
         return(scotlandCouncil)
    }
 
  })
  
  
  dstatus <- reactive({
    if(input$adminLevel == 'scotlandMsp'){
      return(d1)
      }
            if(input$adminLevel == 'scotlandCouncil'){
              return(e1)
            }
   })
 
  output$areaSelect <- renderUI({
    if(!is.null(values$selectedFeature)){
    d <- dstatus() 
    selectInput("areaName","Compare against:",choices = c(sort(d$name,decreasing=F)),selected = 'Stadsregio Amsterdam')
    } 
     })
  
  
   geojsondata <- reactive({
     
            if(input$adminLevel == 'scotlandMsp'){
     return(RJSONIO::fromJSON('scotlandMsp.json'))
        
          }
     if(input$adminLevel == 'scotlandCouncil'){
       return(RJSONIO::fromJSON('scotlandCouncil.json'))
  
     }
     
   })
  
  
  output$map <- renderLeaflet({
    
      geojson <- geojsondata()
      Areas <- geojson 
    d <- dstatus()
    for (i in 1:length(d[,1])){
      
      geojson$features[[i]]$properties$style   <-  list(weight = 5, stroke = "true",
                                                            fill = "true", opacity = 0.8,
                                                            fillOpacity = 0.8, color= paste(d$fillcolor[d$name == geojson$features[[i]]$properties$name]),
                                                            fillColor = paste(d$fillcolor[d$name == geojson$features[[i]]$properties$name]))
    }
    Areas <- geojson 
    m = leaflet()  %>%  addTiles()  %>%
      addTiles(group = "Dark CartoDB (default)", '//{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', attribution=HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a> Map Data (c) <a href="http://www.openstreetmap.org/copyright">OpenStreetMap Contibutors </a>')) %>%
              addGeoJSON( Areas , group = "Areas") %>% 
      addLayersControl(
        baseGroups = c("Dark CartoDB (default)", "OSM"),
        overlayGroups = c("Areas"),
       
        options = c(layersControlOptions(collapsed = TRUE), fillOpacity = 1)
      ) %>%
    setView(3.911, 56.170, zoom = 5 ) 
   # addMarkers(~Long, ~Lat, popup = ~htmlEscape(geojson$features))
    })
  

  values <- reactiveValues(selectedFeature = NULL)
  
  observe({
    evt <- input$map_click
    if (is.null(evt))
      return()
    
    isolate({
      # An empty part of the map was clicked.
      # Null out the selected feature.
      values$selectedFeature <- NULL
    })
  })
  
  observe({
    evt <- input$map_geojson_click
    if (is.null(evt))
      return()
    
    isolate({
      # A GeoJSON feature was clicked. Save its properties
      # to selectedFeature.
      values$selectedFeature <- evt$properties
    })
  })


  
  datasetTargetTotal <- reactive({
    d <- dstatus()
    sumdata <- sumdata() 
    data <- bicycleTarget(summary=sumdata,status=d,completion=input$num, cost=input$cost)
    data <- sum(as.numeric(as.character(data$'Projected Cost per year Million GBP'[data$Code == 'COU' | data$Code == 'UTA'])))
    data
  })
  
  datasetTarget <- reactive({
    d <- dstatus()
    sumdata <- sumdata() 
    datas <- bicycleTarget(summary=sumdata,status=d,completion=input$num, cost=input$cost)
    datas
  })
  
  observeEvent(input$scotlandOverview, {
    values$selectedFeature <- NULL
 
  })
  
  
  quintileFunc <- function(x) {
    test <- as.character(cut(x, breaks = c(0, 0.2, 0.4, 0.6, 
                                           0.8, 1), include.lowest = TRUE, labels = c("Bad", 
                                                                                      "Poor", "Moderate", "Good", "High")))
  }
  
  
 colourFunc <- function(x) {
    test <- as.character(cut(x, breaks = c(0, 0.2, 0.4, 0.6, 
                                           0.8, 1), include.lowest = TRUE, labels = c("color:#bd0026", 
                                                                                      "color:#f03b20", "color:#fd8d3c", "color:#fecc5c", "color:#ffffb2")))
  }

  
  output$description  <- renderText({
    if(is.null(values$selectedFeature)){
      d <- dstatus()
      
      x <- mean(d1[,c('Total normalised')])
#       quintileFunc <- function(x) {
#         test <- as.character(cut(x, breaks = c(0, 0.2, 0.4, 0.6, 
#                                                0.8, 1), include.lowest = TRUE, labels = c("Bad", 
#                                                                                         "Poor", "Moderate", "Good", "High")))
#       }
      statusOverall <- quintileFunc(x)
      x <- mean(d1[,c('Map Data Quality version norm')])
      dataQualityOverall <- quintileFunc(x)
      textColour <- colourFunc(x) 
      description <- paste(p("Area: ",tags$span(style="color:#ffffff", "Scotland")),
                          p("Overall Status: ",tags$span(style= textColour, statusOverall)),
                           p("Traffic-free cycle paths: ",tags$span(style = "color:#ffffff", sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('cyclepath')])),("km")),
                          p("Bicycle parking spaces: ",tags$span(style= "color:#ffffff",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('bicycleparking')]))),
                           p("NCN length: ",tags$span(style="color:#ffffff",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('routes')])),"km"),
                          hr(),
                          h4("Confidence in map data quality: ",  dataQualityOverall)
                          )
      
#       description <- paste("The cycle infrastructure in Scotland consists of ",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('cyclepath')]),
#                            "km of cycle path (separated from motor-vehicle traffic), approximately ",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('bicycleparking')]), 
#                            " bicycle parking spaces and ",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('routes')]),
#                            "km of National Cycle Network routes. The ratio of paved road highway to cycle path is ", round(mean(d$'cyclepath to road ratio'[d$areacode == 'COU' | d$areacode == 'UTA'] * 100,digits=0)),
#                            "%, this compares to ", round(max(d$'cyclepath to road ratio'[d$name == 'Stadsregio Amsterdam'] * 100,digits=0)),"% in the Amsterdam region.",
#                            sep="")   
    return(description)
      }
  })
  
  
  output$rankTable  <- DT::renderDataTable({
         d <- dstatus()
      rankTable <- d[,c('name','Status','Rank')]
  #  return(rankTable)
      datatable( rankTable ,rownames = FALSE,selection = 'single') %>% formatStyle(names(rankTable[1:3]),  color = 'black')
      
  })

  
  output$rankStatusTable <- renderUI({
  #  if (is.null(values$selectedFeature)){
    list(h3("Overall Status and Rank"),DT::dataTableOutput('rankTable'))
    #}
    })
  
  
  observe({
    evt <- input$rankTable_row_last_clicked
    if (is.null(evt))
      return()
    
    isolate({
      # A rank tablewas clicked. Save its properties
      # to selectedFeature.
      data <- dstatus()
      values$selectedFeature$name <-  evt
    })
  })
  
#   output$rank_select = renderPrint({
#     s = input$rankTable_rows_selected
#     if (length(s)) {
#       cat('These rows were selected:\n\n')
#       cat(s, sep = ', ')
#     }
#   })
  
  pleaseClickMap <- reactive({
  if ( is.null(input$scotlandOverview)){
    return(h3("Please select area on the map:"))
  }
  }
  )
  
  output$scotlandDetails <- renderUI({
      if (is.null(values$selectedFeature)){
   p("Scotland is currently at Poor status when compared to Amsterdam...")
    }
  })
  
  output$pleaseClick <- renderUI({
    
 pleaseClickMap()
  })
  
  output$details <- renderText({
    if (is.null(values$selectedFeature))
      return(NULL)  
    d <- dstatus()
    s <- sumdata()

    x <- d$'Map Data Quality version norm'[d[,c('name')] == values$selectedFeature$name]
    dataQualityOverall <- quintileFunc(x)
    textColour <- colourFunc(x) 
    description <- paste(
      p("Area: ",tags$span(style="color:#ffffff", values$selectedFeature$name)),
      p("Rank: ", tags$span(style="color:#ffffff", d$'Rank'[d[,c('name')] == values$selectedFeature$name]," out of ",length(d[,c('name')]))),
                         p("Overall Status: ",tags$span(style= textColour, d$'Status'[d[,c('name')] == values$selectedFeature$name])),
                         p("Traffic-free cycle paths: ",tags$span(style="color:#ffffff", s$'cyclepath'[d[,c('name')] == values$selectedFeature$name]),("km")),
                         p("Bicycle parking spaces: ",tags$span( style="color:#ffffff",s$'bicycleparking'[d[,c('name')] == values$selectedFeature$name])),
                         p("NCN length: ",tags$span(style="color:#ffffff", s$'routes'[d[,c('name')] == values$selectedFeature$name]), "km"),
                         hr(),
                         h4("Confidence in map data quality: ", tags$span(style= textColour, dataQualityOverall)),
                         actionButton('scotlandOverview', h4('Return to Scotland overview'))
    )
    
    return(description)
  })
    # Render values$selectedFeature, if it isn't NULL.
#     if (is.null(values$selectedFeature))
#       return(NULL)  
#     d <- dstatus()
#     as.character(tags$div(
#       tags$h3(values$selectedFeature$name),
#       tags$h3(
#         "Rank:",paste(d$'Rank'[d[,c('name')] == values$selectedFeature$name]," out of ",length(d[,c('name')]))),
#       tags$p(paste(d$'Description'[d[,c('name')] == values$selectedFeature$name])),
#        actionButton('scotlandOverview', 'Return to Scotland overview')
#     ))
  
  
  
  output$comparisonStatusTable = DT::renderDataTable({
        d <- dstatus()
        x <- d$'Map Data Quality version norm'[d[,c('name')] == values$selectedFeature$name]
        dataQualityOverall <- data.frame(quintileFunc(x))
        rownames(dataQualityOverall) <- c('Map Data Quality')
        names( dataQualityOverall) <- c("Quality Element")
        x <- d$'Map Data Quality version norm'[d[,c('name')] == input$areaName]
        dataQualityOverallAmsterdam <- data.frame(quintileFunc(x))
        rownames(dataQualityOverallAmsterdam) <- c('Map Data Quality')
        names( dataQualityOverallAmsterdam) <- c("Quality Element")
  #  data <- data.frame(cbind(names(d[,c('Cycle path status','Bicycle parking status','National cycle network status','Status','Map Data Quality')]), t(d[d[,1] == values$selectedFeature$name,c('Cycle path status','Bicycle parking status','National cycle network status','Status','Map Data Quality')])))
#   data1 <- data.frame(cbind(names(d[,c('Cycle path status','Bicycle parking status','National cycle network status','Status','Map Data Quality version norm')]), t(d[d[,1] == values$selectedFeature$name,c('cyclepath to road ratio','area to bicycle parking ratio','cycle route to road ratio','Total normalised','Map Data Quality version norm')])))
   # data2 <- data.frame(t(d[d[,1] == input$areaName,c('Cycle path status','Bicycle parking status','National cycle network status','Status','Map Data Quality')]))
    data3 <- data.frame(t(d[d[,1] == input$areaName,c('Cycle path status','Bicycle parking status','National cycle network status','Status')]))
    names(data3) <- c("Quality Element")
    data3 <- rbind(data3, dataQualityOverallAmsterdam)
    data4 <- data.frame(t(d[d[,1] == values$selectedFeature$name,c('Cycle path status','Bicycle parking status','National cycle network status','Status')]))
    names(data4) <- c("Quality Element")
     data4 <- rbind(data4, dataQualityOverall)
    #   data4 <- data.frame(t(d[d[,1] == values$selectedFeature$name,c('cyclepath to road ratio','area to bicycle parking ratio','cycle route to road ratio','Total normalised','Map Data Quality version norm')]))
    
  #  data - cbind(data,data1,data2,data3)
    data <- cbind(rownames(data3),data4,data3)
        names(data) <- c("Quality Element",values$selectedFeature$name,input$areaName)
   # data <- data.frame("Quality Element"=data[,1],"Value"=data[,2])
        datatable(data,rownames = FALSE,selection = 'single')  %>% formatStyle(names(data[1:3]),  color = 'black')  
        #%>% 
      #formatStyle(data[,2:3],  color = 'red', backgroundColor = 'orange', fontWeight = 'bold')
       #  return(list(c(data, server = FALSE)))
  }
#, server = FALSE
#,options = list(searching =FALSE,paging = FALSE)
)
  
  output$comparisonTable <- renderUI({
    if (!is.null(values$selectedFeature)){
   
      list(h3("Status Table Comparison"), DT::dataTableOutput('comparisonStatusTable'))
          }
      })
  
  output$comparisonMetric <- renderUI({
    if (!is.null(values$selectedFeature)){
      
      list(h3(paste(input$comparisonStatusTable_row_last_clicked ," breakdown")), DT::dataTableOutput('comparisonTableMetric'))
    }
  })

  output$comparisonTableMetric = DT::renderDataTable({
    row_selected = input$comparisonStatusTable_row_last_clicked
    s_d <- sumdata()
    if (length(row_selected)) {
  
      metricTable <- t(s_d[s_d$name == values$selectedFeature$name | s_d$name == input$areaName ,c('name','cyclepath','road','area')])
      col_names <- data.frame(rownames(metricTable))
       metricTable <- cbind(col_names, metricTable)
       names(metricTable) <- c('Breakdown elements',values$selectedFeature$name, input$areaName)
       
   table_sum <- datatable(metricTable,rownames = FALSE,selection = 'none', style= 'default')   %>% formatStyle(names(metricTable[1:3]),  color = 'black')  
  # return(table_sum)
    }
  })
  
  # out use dimple library: doesn't render correctly:
  #   output$chart2 <- renderChart2({
  #    
  #     d$'Name' <- d$features.properties.name
  #     d <- d[d$'Name' == values$selectedFeature$name | d$'Name' == 'Stadsregio Amsterdam', ]
  #       p2 <- dPlot(
  #       x = "Name",
  #       y = "BQR total",
  #       data = d,
  #       type = "bar",
  #       bounds = list(x = 50, y = 50, height = 250, width = 300)
  #     )
  #         p2$set(dom = "chart2")
  #                return(p2)
  #   })
  
  output$chart2 <- renderPlot({
    d <- dstatus()
    d <- d[d[,1] == values$selectedFeature$name | d[,1] == input$areaName, ]
    
    ifelse(is.null(values$selectedFeature$name), p2 <- NULL,
           p <-  qplot(x = d$name,  y = d$'Total normalised', geom="bar",stat="identity",fill=d$name,xlab="Area",ylab="Bicycle Quality Ratio (Total normalised)")) 
    p <- p + scale_fill_manual(values= sort(d$fillcolor,decreasing=F), name="City", labels=sort(d$name,decreasing=F))
    return(p)
    
  })
  
  output$comparisonStatusChart <- renderUI({
    if (!is.null(values$selectedFeature)){
    list("Comparison Chart", plotOutput("chart2"))
    }
  })

    output$description2  <- renderText({
    
    description2 <- paste("Based on the values set above, the total cost of improving cycle infrastructure in Scotland to Good status is £ ", datasetTargetTotal()," Million per year. This includes a 'rural bias' which is a reduction in cost for rural areas which require less cyclepaths due to generally quieter roads and lower population density.",sep="") 
    description2 
  })
  
  output$table2 <- renderDataTable({
  data <-  datasetTarget() 
  data$Code <- NULL
  data
  },options = list(searching = TRUE,paging = FALSE))
  
  output$measuresTable <- renderDataTable({
    sumdata <- sumdata() 
    data <- bicycleMeasures(sumdata)
    data
  },options = list(searching = TRUE,paging = FALSE))
  
  output$chartOutcome <- renderPlot({
    d <- dstatus()  
    sumdata <- sumdata()
    d$'Name' <- d$name
    d <-   merge(d,sumdata,by.x="name",by.y="name")
    d$'% Commuting By Bicycle' <- d$commutingbybicycle.x
    d <- d[with(d,order(d$'Total normalised')),]
    d$name <- as.factor(d$name)
    d$name <- factor(d$name, levels = d$name[order(d$'Total normalised')])
    Overall_Status <- d$'Status'
    p2 <-  qplot(x = d$name,  y= d$'% Commuting By Bicycle', geom="bar",fill=Overall_Status, stat="identity",xlab="Area",ylab="Percentage communting by bicycle") + theme(axis.text.x = element_text(angle = 90, hjust = 1))
  

# renderChart... dimple etc
#     p2 <- dPlot(
#         y =  '% Commuting By Bicycle' ,
#       x = "Status",
#       data = d,
#       type = "bar",
#       bounds = list(x = 50, y = 50, height = 250, width = 300)
#     )
#     p2$set(dom = "chartOutcome")
#   #  p2$xAxis(orderRule = "Date")
    return(p2)
  })
  
  
  sandboxData <- reactive({
        return(bicycleStatus(sumdata(),bicycleParkingWeight=input$bicyleParkingWeight,routeWeight=input$routeWeight,cyclePathWeight=input$bicyclePathWeight,ruralWeight=input$ruralWeight))
  })
  
  output$sandboxTable <- renderDataTable({
    d <- sandboxData()
    d
  },options = list(searching = TRUE,paging = FALSE))

  
  })
  
 







