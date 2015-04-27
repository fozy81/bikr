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
# 
 geojsonFile <- RJSONIO::fromJSON('scotlandMsp.json')
geojsonFile2 <- RJSONIO::fromJSON('scotlandCouncil.json')
# d <<- reactive({
#   admin <-  bicycleStatus(eval(parse(text = paste(input$adminLevel))))
#   admin$fillcolor <- ifelse( admin$Status == "High","#ffffb2","")
#   admin$fillcolor <- ifelse( admin$Status == "Good","#fecc5c", admin$fillcolor)
#   admin$fillcolor <- ifelse( admin$Status == "Moderate","#fd8d3c", admin$fillcolor)
#   admin$fillcolor <- ifelse( admin$Status == "Poor","#f03b20", admin$fillcolor)
#   admin$fillcolor <- ifelse( admin$Status == "Bad","#bd0026", admin$fillcolor)
#   return(admin)
# })
# 
# 
#  geojsonFile <- reactive({
#    geojsonFile <- RJSONIO::fromJSON(paste(input$adminLevel,'.json',sep=""))
#  })
#  


shinyServer(function(input, output, session) {
 
  dstatus <- reactive({
    if(input$adminLevel == 'scotlandMsp'){
      return(d1)
      }
            if(input$adminLevel == 'scotlandCouncil'){
              return(e1)
            }
   })
 
  
   geojsondata <- reactive({
    if(input$adminLevel == 'scotlandMsp'){
     return(geojsonFile)}
     if(input$adminLevel == 'scotlandCouncil'){
       return(geojsonFile2)
       
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
    
    m = leaflet()  %>%  addTiles("//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png") %>%
    addGeoJSON(geojson) %>%
    addCircles(-60, 60, radius = 5e5, layerId = "circle") %>%
    setView(3.911, 56.170, zoom = 5 )
  })
  
#   map <- createLeafletMap(session, "map")
# 
#   session$onFlushed(once=TRUE, function() {
#     
#       for (i in 1:length(d[,1])){
#       
#       geojsonFile$features[[i]]$properties$style   <-  list(weight = 5, stroke = "true",
#                                                             fill = "true", opacity = 0.9,
#                                                             fillOpacity = 0.9, color= paste(d$fillcolor[d$name == geojsonFile$features[[i]]$properties$name]),
#                                                             fillColor = paste(d$fillcolor[d$name == geojsonFile$features[[i]]$properties$name]))
#     }
# 
#     map$addGeoJSON(geojsonFile)
# 
#    })
  
  
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
    data <- bicycleTarget(summary=scotlandAmsterdam,status=d,completion=input$num, cost=input$cost)
    data <- sum(as.numeric(as.character(data$'Projected Cost per year £M')))
    data
  })
  
  datasetTarget<- reactive({
    d <- dstatus()
    datas <- bicycleTarget(summary=scotlandAmsterdam,status=d,completion=input$num, cost=input$cost)
    datas
  })
  

  output$description  <- renderText({
    if (is.null(values$selectedFeature))
      d <- dstatus()
      description <- paste("The cycle infrastructure in Scotland consists of ",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('cyclepath')]),
                           "km of cycle path (separated from motor-vehicle traffic), ",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('bicycleparking')]), 
                           " bicycle parking areas and ",sum(scotlandAmsterdam[scotlandAmsterdam$areacode == 'COU',c('routes')]),
                           "km of National Cycle Network routes. The ratio of paved road highway to cycle path is ", round(mean(d$'cyclepath to road ratio' * 100,digits=0)),
                           "%, this compares to ", round(max(d$'cyclepath to road ratio') * 100,digits=0),"% in the Amsterdam region.",
                           sep="")   
    
  })
  
  
  output$rankTable  <- renderDataTable({
    if (is.null(values$selectedFeature))
      d <- dstatus()
      rankTable <- d[,c('name','Status','Rank')]
    rankTable
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
  
  
  output$table <- renderDataTable({
    d <- dstatus()
    data <- data.frame(cbind(names(d[c(6,10,14,19,20,21,22)]), t(d[d[,1] == values$selectedFeature$name,c(6,10,14,19,20,21,22)])))
    data <- data.frame("Quality Element"=data[,1],"Value"=data[,2])
    data
  },options = list(searching =FALSE,paging = FALSE))
  
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
    d <- d[d[,1] == values$selectedFeature$name | d[,1] == 'Stadsregio Amsterdam', ]
    
    ifelse(is.null(values$selectedFeature$name), p2 <- NULL,
           p <-  qplot(x = d[,1],  y = d[,18], geom="bar",stat="identity",fill=d[,1],xlab="City",ylab="Bicycle Quality Ratio")) 
    p <- p + scale_fill_manual(values= sort(d[,23],decreasing=F), name="City", labels=sort(d[,1],decreasing=F))
    return(p)
    
  })
  
  
  
  output$description2  <- renderText({
    
    description2 <- paste("The total cost of improving cycle infrastructure to Good status is £ ", datasetTargetTotal()," Million per year",sep="") 
    description2 
  })
  
  output$table2 <- renderDataTable({
    datasetTarget() 
  },options = list(searching = TRUE,paging = FALSE))
  
  output$measuresTable <- renderDataTable({
    data <- bicycleMeasures(scotlandAmsterdam)
    data
  },options = list(searching = TRUE,paging = FALSE))
  
  output$chartOutcome <- renderChart2({
    d <- dstatus()
    d <-   merge(d,scotlandAmsterdam,by.x="name",by.y="name")
    
    d$'Name' <- d$name
    
    p2 <- dPlot(
      
      y = "commuting_by_bicycle.x",
      x = "Status",
      data = d,
      type = "bar",
      bounds = list(x = 50, y = 50, height = 250, width = 300)
    )
    p2$set(dom = "chartOutcome")
    return(p2)
  })
  
  
  
})







