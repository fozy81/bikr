library(rCharts)
library(leaflet)
library(bikr)
library(ggplot2)
library(DT)

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
         scotlandMsp <- scotlandMsp[with(scotlandMsp, order(name)), ]
      d1 <- d1[with(d1, order(name)), ]
      return(merge(scotlandMsp,d1,by.x = c('name','areacode','commutingbybicycle','version'), by.y = c('name','areacode','commutingbybicycle','version')))
      
    }
    
    if(input$adminLevel == 'scotlandCouncil'){
      scotlandCouncil <- scotlandCouncil[with(scotlandCouncil, order(name)), ]
      d2 <- e1[with(e1, order(name)), ]
      return(cbind(scotlandCouncil,d2))
      
    }
    
  })
  
  
  output$areaSelect <- renderUI({
    if(!is.null(values$selectedFeature)){
      d <-sumdata() 
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
    d <-sumdata()
    col_areas = factor(c("High","Good","Moderate","Poor","Bad"),levels = c("High","Good","Moderate","Poor","Bad"),ordered=TRUE)
    pal <- colorFactor(c("#ffffb2","#fecc5c","#fd8d3c","#f03b20","#bd0026"),levels =  col_areas ,ordered=TRUE)
    for (i in 1:length(d[,1])){
      
      geojson$features[[i]]$properties$style   <-  list(weight = 5, stroke = "true",
                                                        fill = "true", opacity = 0.8,
                                                        fillOpacity = 0.8, color= paste(d$fillcolor[d$name == geojson$features[[i]]$properties$name]),
                                                        fillColor = paste(d$fillcolor[d$name == geojson$features[[i]]$properties$name]))
    }
    Areas <- geojson 
    m = leaflet()  %>%  
      addTiles(group = "Dark CartoDB (default)", 'http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
               attribution=HTML('&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors,
                                &copy; <a href="http://cartodb.com/attributions">CartoDB</a>
                                &copy; <a href="http://www.thunderforest.com/">Thunderforest</a>
                                &copy; <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA 2.0</a>')) %>%
      addGeoJSON( Areas , group = "Areas") %>% 
      addTiles(group = "OpenCycleMap", 'https://c.tile.thunderforest.com/cycle/{z}/{x}/{y}.png',
               attribution=HTML('&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors,
                                &copy; <a href="http://cartodb.com/attributions">CartoDB</a>
                                &copy; <a href="http://www.thunderforest.com/">Thunderforest</a>
                                &copy; <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA 2.0</a>')) %>%
      addLayersControl(
        baseGroups = c("Dark CartoDB (default)", "OpenCycleMap"),
        overlayGroups = c("Areas"),
        
        options = c(layersControlOptions(collapsed = TRUE), fillOpacity = 1)
      ) %>%
      setView(3.911, 56.170, zoom = 5 ) %>%
      
      addLegend("bottomright", pal = pal,
                values = col_areas,
                title = "Overall Status",
                opacity = 0.8
      ) 

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
    data <- bicycleTarget(summary= bicycleStatus(eval(parse(text=paste(input$adminLevel)))),status= eval(parse(text=paste(input$adminLevel))),
                          completion=input$num, cost=input$cost)
    data <- sum(as.numeric(as.character(data$'Projected Cost per year Million GBP'[data$Code == 'COU' | data$Code == 'UTA'])))
    data
  })
  
  datasetTarget <- reactive({
    datas <- bicycleTarget(summary= bicycleStatus(eval(parse(text=paste(input$adminLevel)))),status= eval(parse(text=paste(input$adminLevel))),
                           completion=input$num, cost=input$cost)
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
                                           0.8, 1), include.lowest = TRUE, labels = c("color:#bd0026", "color:#f03b20","color:#fd8d3c", "color:#fecc5c","color:#ffffb2"
                                           )))
  }
  
  
  output$description  <- renderText({
    if( is.null(values$selectedFeature)){
      d1 <- sumdata()
      
      tx <- mean(d1[,c('Total normalised')])
      statusOverall <- quintileFunc(tx)
      mx <- mean(d1[,c('Map Data Quality version norm')])
      dataQualityOverall <- quintileFunc(mx)
      textColour <- colourFunc(tx) 
      description <- paste(p("Area: ",tags$span(style="color:#ffffff", "Scotland")),
                           p("Overall Status: ",tags$span(style= textColour, statusOverall, opacity= 0.8)),
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
    d <- sumdata()
  #  s <- sumdata()
   # s <- s[with(s, order(name)), ]
    d <- d[with(d, order(name)), ]
    #d <- cbind(s,d)
    d$commutingbybicycle[d$commutingbybicycle == 0] <- "<1"
    d <- d[with(d, order(Rank)), ]
    rankTable <- d[,c('name','commutingbybicycle','Status','Rank')]
    names(rankTable) <- c('Name','% Commuting by bicycle','Status','Rank')
    datatable( rankTable ,rownames = FALSE,selection = 'single', 
               options = list(searching = TRUE,paging = FALSE,info = FALSE)) %>% 
      formatStyle(names(rankTable[1:4]),  color = 'white',backgroundColor = '#303030 ',borderColor = '#404040 ') 
    
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
      data <-sumdata()
      data <- data[with(data,order(Rank)),]
      evt <- data$name[evt]
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
      h3("Select an area from map or table for more detail")
    }
  })
  
  output$pleaseClick <- renderUI({
    
    pleaseClickMap()
  })
  
  output$details <- renderText({
    if (is.null(values$selectedFeature)){
      return(NULL)  }
    d <-sumdata()
    s <- sumdata()
    s$'commutingbybicycle'[s$'commutingbybicycle' == 0] <- "<1"
    tx <- d$'Total normalised'[d[,c('name')] == values$selectedFeature$name]
    x <- d$'Map Data Quality version norm'[d[,c('name')] == values$selectedFeature$name]
    dataQualityOverall <- quintileFunc(x)
    textColour <- colourFunc(tx) 
    mapColour <- colourFunc(x) 
    description <- paste(
      p("Area: ",tags$span(style="color:#ffffff", values$selectedFeature$name)),
      p("Rank: ", tags$span(style="color:#ffffff", d$'Rank'[d[,c('name')] == values$selectedFeature$name]," out of ",length(d[,c('name')]))),
      p("Overall Status: ",tags$span(style= textColour, d$'Status'[d[,c('name')] == values$selectedFeature$name])),
      p("Traffic-free cycle paths: ",tags$span(style="color:#ffffff", s$'cyclepath'[s[,c('name')] == values$selectedFeature$name]),("km")),
      p("Bicycle parking spaces: ",tags$span( style="color:#ffffff",s$'bicycleparking'[s[,c('name')] == values$selectedFeature$name])),
      p("NCN length: ",tags$span(style="color:#ffffff", s$'routes'[s[,c('name')] == values$selectedFeature$name]), "km"),
      hr(),
      h4("Confidence in map data quality: ", tags$span(style=  mapColour, dataQualityOverall)),
      h4("% communting by bicycle: ", tags$span(style="color:#ffffff", s$'commutingbybicycle'[s[,c('name')] == values$selectedFeature$name])),
      actionButton('scotlandOverview', h4('Return to Scotland overview'))
    )
    
    return(description)
  })

  
  output$tabs <- renderUI({
    if (!is.null(values$selectedFeature)){
      tabsetPanel(
        tabPanel("Overall Status", uiOutput('comparisonTable')),
        tabPanel ("Cyclepath", uiOutput('comparisonMetric')), 
        tabPanel("Bicycle parking", uiOutput("comparisonParking")),
        tabPanel("National Cycle Network", uiOutput("comparisonNCN")),
        tabPanel("Map data quality", uiOutput("comparisonMap"))
      )
    }
  })
  
  output$comparisonStatusTable = DT::renderDataTable({
    d <-sumdata()
    x <- d$'Map Data Quality version norm'[d[,c('name')] == values$selectedFeature$name]
    dataQualityOverall <- data.frame(quintileFunc(x))
    rownames(dataQualityOverall) <- c('Map Data Quality')
    names( dataQualityOverall) <- c("Key Elements")
    x <- d$'Map Data Quality version norm'[d[,c('name')] == input$areaName]
    dataQualityOverallAmsterdam <- data.frame(quintileFunc(x))
    rownames(dataQualityOverallAmsterdam) <- c('Map Data Quality')
    names( dataQualityOverallAmsterdam) <- c("Key Elements")
    data3 <- data.frame(t(d[d[,'name'] == input$areaName,c('Status','Cycle path status','Bicycle parking status','National cycle network status')]))
    names(data3) <- c("Key Elements")
    data3 <- rbind(data3, dataQualityOverallAmsterdam)
    data4 <- data.frame(t(d[d[,'name'] == values$selectedFeature$name,c('Status','Cycle path status','Bicycle parking status','National cycle network status')]))
    names(data4) <- c("Key Elements")
    data4 <- rbind(data4, dataQualityOverall)
    
    data <- cbind(rownames(data3),data4,data3)
    
    names(data) <- c("Key Elements",values$selectedFeature$name,input$areaName)
    data[,1] <- as.character(data[,1])
    data[1,1] <- "Overall Status" 
    row.names(data) <- NULL
      datatable(data,rownames = FALSE, options = list(searching = FALSE,paging = FALSE,info = FALSE,
                                                    server = FALSE,processing = FALSE))  %>%
      formatStyle(names(data[1:3]),  color = 'white',backgroundColor = '#303030 ',borderColor = '#404040 ' )
    
  })
  
  output$comparisonTable <- renderUI({
    if (!is.null(values$selectedFeature)){
      
      list(DT::dataTableOutput('comparisonStatusTable'),
           h4("The overall status is calculated by combining all sub elements excluding the map quality element. The 
              elements are all normalised against the amount of infrastructure found in the Amsterdam region. Some allowances are
              made for rural areas and a weighting is used to balance in favour of total Cycle Path element. See the other tabs for further 
              information on how each individual element is calculated" ))
    }
    })
  
  output$comparisonMetric <- renderUI({
    if (!is.null(values$selectedFeature)){
      
      list( DT::dataTableOutput('comparisonTableMetric'),h4("The cycle path status is calculated based on the ratio
                                                            of road to cycle path. Rural areas, where road traffic is much
                                                            lower won't necessarily require such a high ratio of cycle path to 
                                                            road therefore road density (road/area) is used to biase in favour of 
                                                            rural areas. Cycle paths are defined as paths separated from traffic, with a paved surface which may or may not be shared
                                                            with pedestrians. Roads are defined as any paved road with vehicle access exlcuding
                                                            'service' roads such as car park aisles or driveways."))
    }
    })
  
  output$comparisonTableMetric = DT::renderDataTable({
    s_d <- sumdata()
    metricTable <- data.frame(t(s_d[s_d$name == values$selectedFeature$name | s_d$name == input$areaName ,c('Cycle path status','cyclepath','road','area')]))
    col_names <- data.frame(c('Cycle path status','Cylepath (km)','Road (km)','Area (meters)'))  #data.frame(rownames(metricTable)) - need units in dataframe
    metricTable <- cbind(col_names, metricTable)
    areaNames <- c(values$selectedFeature$name, input$areaName)
    areaNames <- areaNames[order(areaNames)]
    names(metricTable) <- c('Sub elements',areaNames[1], areaNames[2])
    row.names(metricTable) <- NULL
      datatable(metricTable,rownames = FALSE,    
                            options = list(searching = FALSE,paging = FALSE,info = FALSE,server = FALSE,processing = FALSE))  %>% 
                  formatStyle(names(metricTable[1:3]),  color = 'white',backgroundColor = '#303030 ',borderColor = '#404040 ')
    })
  
  
  output$comparisonParking <- renderUI({
    if (!is.null(values$selectedFeature)){
      
      list( DT::dataTableOutput('comparisonTableParking'),h4("The bicycle parking status is calculated based on the ratio
                                                             of bicycle parking points divided by area."))
    }
    })
  
  output$comparisonTableParking = DT::renderDataTable({
   
    s_d <- sumdata()
    metricTable <- t(s_d[s_d$name == values$selectedFeature$name | s_d$name == input$areaName ,c('Bicycle parking status','bicycleparking','area','area to bicycle parking ratio norm')])
    col_names <- data.frame(c('Bicycle parking status','No. bicyle parking points','Area (meters)','area to bicycle parking ratio normalised'))  #data.frame(rownames(metricTable)) - need units in dataframe
    metricTable <- cbind(col_names, metricTable)
    areaNames <- c(values$selectedFeature$name, input$areaName)
    areaNames <- areaNames[order(areaNames)]
    names(metricTable) <- c('Sub elements',areaNames[1], areaNames[2])
    table_sum <- datatable(metricTable,rownames = FALSE,selection = 'none', style= 'default', 
                           options = list(processing = FALSE, searching = FALSE,paging = FALSE,info = FALSE))  %>% 
      formatStyle(names(metricTable[1:3]),  color = 'white',backgroundColor = '#303030 ',borderColor = '#404040 ')
  })
  
  output$comparisonNCN <- renderUI({
    if (!is.null(values$selectedFeature)){
      
      list( DT::dataTableOutput('comparisonTableNCN'),h4("The National Cycle Network status is calculated based on the ratio
                                                         of NCN route divided by road total road length within area. This is normalised
                                                         against the ratio found in Amsterdam"))
    }
    })
  
  output$comparisonTableNCN = DT::renderDataTable({
    
    s_d <- sumdata()
    metricTable <- t(s_d[s_d$name == values$selectedFeature$name | s_d$name == input$areaName ,c('National cycle network status','routes','road','cycle route to road ratio norm')])
    col_names <- data.frame(c('National cycle network status','Length of NCN (km)','Road (km)','cycle route to road ratio normalised'))  #data.frame(rownames(metricTable)) - need units in dataframe
    metricTable <- cbind(col_names, metricTable)
    areaNames <- c(values$selectedFeature$name, input$areaName)
    areaNames <- areaNames[order(areaNames)]
    names(metricTable) <- c('Sub elements',areaNames[1], areaNames[2])
        table_sum <- datatable(metricTable,rownames = FALSE,selection = 'none', style= 'default', 
                               options = list(processing = FALSE, searching = FALSE,paging = FALSE,info = FALSE))  %>% 
          formatStyle(names(metricTable[1:3]),  color = 'white',backgroundColor = '#303030 ',borderColor = '#404040 ')
     })
  
  output$comparisonMap <- renderUI({
    if (!is.null(values$selectedFeature)){
      
      list( DT::dataTableOutput('comparisonTableMap'),h4("The map quality status is calculated based on the number of OpenStreetMap editors, 
                                                         the date of last edit, and the average number of updates made to bicycle infrastructure features. Allowances are made for area size and ruralness. The
                                                         value is then normalised against Amsterdam region"))
    }
    })
  
  output$comparisonTableMap = DT::renderDataTable({
     s_d <- sumdata()
    s_d$'Map Data Quality' <- quintileFunc(s_d$'Map Data Quality version norm')
    s_d$'lasteditdate' <- as.Date(s_d$'lasteditdate')
    metricTable <- t(s_d[s_d$name == values$selectedFeature$name | s_d$name == input$areaName ,c('Map Data Quality','editors','version','lasteditdate')])
    col_names <- data.frame(c('Map Data Quality status','No. map editors','Average updates per map feature','Date of last map edit'))  #data.frame(rownames(metricTable)) - need units in dataframe
    metricTable <- cbind(col_names, metricTable)
    areaNames <- c(values$selectedFeature$name, input$areaName)
    areaNames <- areaNames[order(areaNames)]
    names(metricTable) <- c('Sub elements',areaNames[1], areaNames[2])
    
    table_sum <- datatable(metricTable,rownames = FALSE,selection = 'none', style= 'default', 
                           options = list(processing = FALSE, searching = FALSE,paging = FALSE,info = FALSE))  %>% 
      formatStyle(names(metricTable[1:3]),  color = 'white',backgroundColor = '#303030 ',borderColor = '#404040 ')
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
    d <-sumdata()
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
  
  output$descriptionCosts  <- renderText({
    
    description2 <- paste("Based on the values set above, 
                          the total cost of improving cycle infrastructure in Scotland to Good status is:",
                          p(h3('£', datasetTargetTotal(), " Million per year")),p("This includes a 'rural bias' which is a reduction in cost for rural areas which require less cyclepaths
                          due to generally quieter roads and lower population density."),sep="") 
    description2 
  })
  
  output$tableCosts <- DT::renderDataTable({
    datas <-  datasetTarget() 
    datas$Code <- NULL
    datatable(datas, rownames = FALSE,selection = 'none', style= 'default', options = list(searching = TRUE,paging = FALSE,info = FALSE))  %>% 
      formatStyle(names(datas[1:5]),  color = 'white',backgroundColor = '#303030 ',borderColor = '#404040 ')
  }  )
  
  output$measuresTable <- renderDataTable({
    sumdata <- eval(parse(text=paste(input$adminLevel)))
    data <- bicycleMeasures(sumdata)
    data
  },options = list(searching = TRUE,paging = FALSE))
  
  output$chartOutcome <- renderPlot({
    d <-sumdata()  
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

