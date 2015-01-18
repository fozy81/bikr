library(leaflet)
library(jsonlite)
library(rCharts)

library(ggplot2)

d <- data.frame(fromJSON('/home/tim/github/cycle-map-stats/Rscript/summary.json',flatten=T))

bicycleClass <- function(x){
  
  x$'Road Vs cycle path' <-   round(x$features.properties.off_road_cycleway / x$features.properties.highways,digits=3)
  x$'Bicycle parking to area' <- round(x$features.properties.bicycle_parking / x$features.properties.area,digits=10)
  x$'Ruralness weighting' <- round(x$features.properties.area / x$features.properties.highways,digits=4) / 3000 
  x$'NCN Vs highway' <- round(x$features.properties.ncn / x$features.properties.highways, digits=3)
  x$'BQR total' <-   round(x$'Road Vs cycle path' +  x$'NCN Vs highway' +  x$'Bicycle parking to area' + x$'Ruralness weighting', digits=2)
  x$'BQR normalised' <- round(x$'BQR total' / max(x$'BQR total'),digits=2)
  x$'Status' <- ifelse(x$'BQR normalised' <= 0.8, "Good", "High")
  x$'Status' <- ifelse(x$'BQR normalised' <= 0.6, "Moderate", x$'Status')
  x$'Status' <- ifelse(x$'BQR normalised' <= 0.4, "Poor",  x$'Status')
  x$'Status' <- ifelse(x$'BQR normalised' <= 0.2, "Bad",   x$'Status')
  return(x)
}

d$'Bicycle parking points' <- d$features.properties.bicycle_parking
d$'Name' <- d$features.properties.name
d <- bicycleClass(d)

CoC <- function(x){
  
  x$'Confidence of class' <- (x$features.properties.editors + as.numeric(substr(x$features.properties.edit_date,1,4))) - 2010
  x$'Confidence of class' <- (round(x$'Confidence of class' / max(x$'Confidence of class'),digits=2) * 100) + 40 #mhmm the smell of fudge
  x$'Confidence of class' <- ifelse(x$'Confidence of class' > 100,paste("100%"), paste(x$'Confidence of class',"%",sep=""))
  return(x)
} 

d <- CoC(d)

fileName <- '/home/tim/github/cycle-map-stats/Rscript/summary.json'

seattle_geojson <- readChar(fileName, file.info(fileName)$size)


shinyServer(function(input, output, session) {
  
  map <- createLeafletMap(session, "map")
  
  session$onFlushed(once=TRUE, function() {
    map$addGeoJSON(seattle_geojson)
                   
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
  
  output$details <- renderText({
    # Render values$selectedFeature, if it isn't NULL.
    if (is.null(values$selectedFeature))
      return(NULL)
    
    as.character(tags$div(
      tags$h3(values$selectedFeature$name),
      tags$div(
        "Region:",
        values$selectedFeature$name,hr(),
        "Bicycle path:",d$features.properties.status[d$features.properties.name == values$selectedFeature$name]
       
      )
    ))
  })
  
  
  output$table <- renderDataTable({
  
    data <- data.frame(cbind(names(d[c(28,25:27,29)]), t(d[d$'Name' == values$selectedFeature$name,c(28,25:27,29)])))
    data <- data.frame("Quality Element"=data[,1],"Value"=data[,2])
    data
  },options = list(searching = FALSE,paging = FALSE))
 
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
    d <- d[d$'Name' == values$selectedFeature$name | d$'Name' == 'Stadsregio Amsterdam', ]
    
    ifelse(is.null(values$selectedFeature$name), p2 <- NULL,
    p2 <-  qplot(x = d$'Name',  y = d$'BQR normalised', geom="bar",stat="identity",fill=d$'Name'))
   
    return(p2)
    
  })

})


#d$features.properties.name == 'Aberdeen Donside P Const',]
# d[d$features.properties.name == 'Aberdeen Donside P Const' | d$features.properties.name == 'Stadsregio Amsterdam',c(5,24) ]
