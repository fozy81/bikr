library(rCharts)
library(leaflet)
#library(jsonlite)
library(RJSONIO)
#devtools::install_github("fozy81/mypackage")
library(bikr)
library(ggplot2)
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
    d <- dstatus()
    for (i in 1:length(d[,1])){
      
      geojson$features[[i]]$properties$style   <-  list(weight = 5, stroke = "true",
                                                            fill = "true", opacity = 0.9,
                                                            fillOpacity = 0.9, color= paste(d$fillcolor[d$name == geojson$features[[i]]$properties$name]),
                                                            fillColor = paste(d$fillcolor[d$name == geojson$features[[i]]$properties$name]))
    }
    
    m = leaflet()  %>%  addTiles("//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",attribution=HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a> Map Data (c) <a href="http://www.openstreetmap.org/copyright">OpenStreetMap Contibutors </a>')) %>%
    addGeoJSON(geojson) %>%
    setView(3.911, 56.170, zoom = 5 )

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
    data <- sum(as.numeric(as.character(data$'Projected Cost per year £M')))
    data
  })
  
  datasetTarget <- reactive({
    d <- dstatus()
    sumdata <- sumdata() 
    datas <- bicycleTarget(summary=sumdata,status=d,completion=input$num, cost=input$cost)
    datas
  })
  

  output$description  <- renderText({
    if(is.null(values$selectedFeature)){
      d <- dstatus()
      description <- paste("The cycle infrastructure in Scotland consists of ",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('cyclepath')]),
                           "km of cycle path (separated from motor-vehicle traffic), ",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('bicycleparking')]), 
                           " * bicycle parking areas and ",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('routes')]),
                           "km of National Cycle Network routes. The ratio of paved road highway to cycle path is ", round(mean(d$'cyclepath to road ratio'[d$areacode == 'COU' | d$areacode == 'UTA'] * 100,digits=0)),
                           "%, this compares to ", round(max(d$'cyclepath to road ratio'[d$name == 'Stadsregio Amsterdam'] * 100,digits=0)),"% in the Amsterdam region.",
                           sep="")   
    return(description)
      }
  })
  
  
  output$rankTable  <- renderDataTable({
         d <- dstatus()
      rankTable <- d[,c('name','Status','Rank')]
    return(rankTable)
  })
  
  
  output$rankStatusTable <- renderUI({
    if (is.null(values$selectedFeature)){
    list(h3("Rank Status Table"),dataTableOutput('rankTable'))
    }
  })
  
  pleaseClickMap <- reactive({
  if (is.null(values$selectedFeature)){
    return(h3("Please select area on the map:"))
  }
  }
  )
  
  output$pleaseClick <- renderUI({
    
 pleaseClickMap()
  })
  
  output$details <- renderText({
    # Render values$selectedFeature, if it isn't NULL.
    if (is.null(values$selectedFeature))
      return(NULL)  
    d <- dstatus()
    as.character(tags$div(
      tags$h3(values$selectedFeature$name),
      tags$h3(
        "Rank:",paste(d$'Rank'[d[,c('name')] == values$selectedFeature$name]," out of ",length(d[,c('name')]))),
      tags$p(paste(d$'Description'[d[,c('name')] == values$selectedFeature$name]))
    ))
  })
  
  
  output$comparisonStatusTable <- renderDataTable({
        d <- dstatus()
    data <- data.frame(cbind(names(d[,c('Cycle path status','Bicycle parking status','National cycle network status','Status','Total normalised','Sampling Effort')]), t(d[d[,1] == values$selectedFeature$name,c('Cycle path status','Bicycle parking status','National cycle network status','Status','Total normalised','Sampling Effort')])))
    data2 <- data.frame(t(d[d[,1] == input$areaName,c('Cycle path status','Bicycle parking status','National cycle network status','Status','Total normalised','Sampling Effort')]))
    data <- cbind(data,data2)
    names(data) <- c("Quality Element",values$selectedFeature$name,input$areaName)
    #data <- data.frame("Quality Element"=data[,1],"Value"=data[,2])
    data
  },options = list(searching =FALSE,paging = FALSE))
  
  output$comparisonTable <- renderUI({
    if (!is.null(values$selectedFeature)){
   
      list(h3("Status Table Comparison"), dataTableOutput('comparisonStatusTable'))
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
    
    description2 <- paste("The total cost of improving cycle infrastructure to Good status is £ ", datasetTargetTotal()," Million per year",sep="") 
    description2 
  })
  
  output$table2 <- renderDataTable({
    datasetTarget() 
  },options = list(searching = TRUE,paging = FALSE))
  
  output$measuresTable <- renderDataTable({
    sumdata <- sumdata() 
    data <- bicycleMeasures(sumdata)
    data
  },options = list(searching = TRUE,paging = FALSE))
  
  output$chartOutcome <- renderChart2({
    d <- dstatus()
    sumdata <- sumdata()
    d <-   merge(d,sumdata,by.x="name",by.y="name")
    
    d$'Name' <- d$name
    d$'% Commuting By Bicycle' <- d$commutingbybicycle.x
    p2 <- dPlot(
        y =  '% Commuting By Bicycle' ,
      x = "Status",
      data = d,
      type = "bar",
      bounds = list(x = 50, y = 50, height = 250, width = 300)
    )
    p2$set(dom = "chartOutcome")
  #  p2$xAxis(orderRule = "Date")
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
  
 







