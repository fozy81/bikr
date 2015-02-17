library(rCharts)
library(leaflet)
#library(jsonlite)
library(RJSONIO)
#devtools::install_github("fozy81/mypackage")
library(bikr)
library(ggplot2)

d <- bicycleStatus(scotlandAmsterdam)
d$fillcolor <- ifelse(d[,18] == "High","#ffffb2","")
d$fillcolor <- ifelse(d[,18] == "Good","#fecc5c",d$fillcolor)
d$fillcolor <- ifelse(d[,18] == "Moderate","#fd8d3c",d$fillcolor)
d$fillcolor <- ifelse(d[,18] == "Poor","#f03b20",d$fillcolor)
d$fillcolor <- ifelse(d[,18] == "Bad","#bd0026",d$fillcolor)

#d <- data.frame(fromJSON('examples/shinyapp/scotlandAmsterdam.json',flatten=T))
#geojsonFile <- fromJSON('examples/shinyapp/scotlandAmsterdam.json')
#fileName <- fromJSON'scotlandAmsterdam.json'
#geojsonFile <- readChar(fileName, file.info(fileName)$size)

geojsonFile <- RJSONIO::fromJSON('scotlandAmsterdam.json')

shinyServer(function(input, output, session) {
  
  map <- createLeafletMap(session, "map")
  
  session$onFlushed(once=TRUE, function() {
  
    for (i in 1:length(d[,1])){
          
      geojsonFile$features[[i]]$properties$style   <-  list(weight = 5, stroke = "true",
                                 fill = "true", opacity = 0.9,
                                fillOpacity = 0.9, color= paste(d$fillcolor[d$features.properties.name == geojsonFile$features[[i]]$properties$name]),
                                fillColor = paste(d$fillcolor[d$features.properties.name == geojsonFile$features[[i]]$properties$name]))
    }
    map$addGeoJSON(geojsonFile)
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
    data <- bicycleTarget(summary=scotlandAmsterdam,status=d,completion=input$num, cost=input$cost)
    data <- sum(as.numeric(as.character(data$'Projected Cost per year £M')))
    data
  })
  
  datasetTarget<- reactive({
    datas <- bicycleTarget(summary=scotlandAmsterdam,status=d,completion=input$num, cost=input$cost)
     datas
  })
  
  
  output$description  <- renderText({
    if (is.null(values$selectedFeature))
      
     description <- paste("The cycle infrastructure in Scotland consists of ",sum(scotlandAmsterdam[c(1:15,17:74),2]),
                               "km of cycle path (separated from motor-vehicle traffic), ",sum(scotlandAmsterdam[c(1:15,17:74),4]), 
                               " bicycle parking areas and ",sum(scotlandAmsterdam[c(1:15,17:74),6]),
                               "km of National Cycle Network routes. The ratio of paved road highway to cycle path is ", round(mean(d$'cyclepath to road ratio' * 100,digits=0)),
                               "%, this compares to ", round(max(d$'cyclepath to road ratio') * 100,digits=0),"% in the Amsterdam region.",
                               sep="")   
    
  })
  
  
  output$rankTable  <- renderDataTable({
    if (is.null(values$selectedFeature))
      
      rankTable <- d[,c(1,18,21)]
    rankTable
  })
  
  output$details <- renderText({
    # Render values$selectedFeature, if it isn't NULL.
    if (is.null(values$selectedFeature))
     return(NULL)  
       
    as.character(tags$div(
      tags$h3(values$selectedFeature$name),
      tags$h3(
        "Rank:",paste(d$'Rank'[d[,1] == values$selectedFeature$name]," out of ",length(d[,1]))),
      tags$p(paste(d$'Description'[d[,1] == values$selectedFeature$name]))
    ))
  })
  
  
  output$table <- renderDataTable({
  
    data <- data.frame(cbind(names(d[c(6,10,14,18,19,20,21)]), t(d[d[,1] == values$selectedFeature$name,c(6,10,14,18,19,20,21)])))
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
    d <- d[d[,1] == values$selectedFeature$name | d[,1] == 'Stadsregio Amsterdam', ]
    
    ifelse(is.null(values$selectedFeature$name), p2 <- NULL,
    p <-  qplot(x = d[,1],  y = d[,16], geom="bar",stat="identity",fill=d[,1],xlab="City",ylab="Bicycle Quality Ratio")) 
    p <- p + scale_fill_manual(values= sort(d[,22],decreasing=F), name="City", labels=sort(d[,1],decreasing=F))
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
     
  d <-   merge(d,scotlandAmsterdam,by.x="features.properties.name",by.y="features.properties.name")
  
      d$'Name' <- d$features.properties.name
   
        p2 <- dPlot(
        y = "features.properties.commuting_by_bicycle.x",
        x = "Status",
        data = d,
        type = "bar",
        bounds = list(x = 50, y = 50, height = 250, width = 300)
      )
          p2$set(dom = "chartOutcome")
                 return(p2)
    })
  


})



